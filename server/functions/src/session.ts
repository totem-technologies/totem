import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
// eslint-disable-next-line import/no-unresolved -- https://github.com/firebase/firebase-admin-node/issues/1827#issuecomment-1226224988
import {DocumentReference, Timestamp, FieldValue} from "firebase-admin/firestore";
import * as dynamicLinks from "./dynamic-links";
import {hasAnyRole, isAuthenticated, Role} from "./auth";
import {kickUserFromSession} from "./agora";
import {
  SnapCircleData,
  SessionState,
  CircleSessionSummary,
  RepeatOptions,
  RecurringType,
  RepeatUnit,
  CreateSnapCircleArgs,
  Participant,
} from "./common-types";
import {add} from "date-fns";

// The Firebase Admin SDK to access the Firebase Realtime Database.
// make sure that this initializeApp call hasn't already
// happened
try {
  admin.initializeApp();
} catch (e) {
  console.log("re-initializing admin");
}

const firebaseDynamicLinks = new dynamicLinks.FirebaseDynamicLinks(functions.config().applinks.key);
const isDev = (process.env.GCLOUD_PROJECT || "").startsWith("totem-dev");
const NonKeeperMaxMinutes = 60;
const NonKeeperMaxParticipants = 5;

/**
 * Ends the session for the given circle
 * @param {string} circleId - the id of the circle
 * @param {SnapCircleData} snapCircle - the circle data
 * @param {DocumentReference | undefined} circleRef - optional reference to the circle document
 * @return {boolean}
 */
export async function endSessionFor(
  circleId: string,
  snapCircle: SnapCircleData,
  circleRef?: DocumentReference
): Promise<boolean> {
  circleRef = circleRef || admin.firestore().collection("snapCircles").doc(circleId);
  const {circleParticipants, state, keeper, startedDate, scheduledSessions} = snapCircle;
  const activeStates = [
    SessionState.waiting,
    SessionState.starting,
    SessionState.expiring,
    SessionState.cancelling,
    SessionState.ending,
    SessionState.live,
  ];
  if (!activeStates.includes(state)) {
    console.warn(`Circle end session called for circle ${circleId} but it is not in an active state`);
    return true;
  }
  const completedDate = Timestamp.now();
  const batch = admin.firestore().batch();
  let endState = SessionState.cancelled;
  if (state === SessionState.ending) {
    endState = SessionState.complete;
  } else if (state === SessionState.expiring) {
    endState = SessionState.expired;
  }
  if (state != SessionState.cancelling && state != SessionState.waiting) {
    // If the session went live then record it as a session
    const entry = {circleRef, completedDate};
    const sessionId = completedDate.seconds.toString();
    if (circleParticipants) {
      const sessionRef = circleRef.collection("sessions").doc(sessionId);
      // Record it in the participants' records and then make a session record for the circle
      circleParticipants.forEach((uid: string) => {
        const entryRef = admin.firestore().collection("users").doc(uid).collection("snapCircles").doc();
        const role = keeper === uid ? "keeper" : "member";
        batch.set(entryRef, {...entry, role, completedDate, sessionRef});
      });
    }
    const sessionSummary: CircleSessionSummary = {startedDate, completedDate, state: endState, circleParticipants};
    const sessionRef: DocumentReference = admin
      .firestore()
      .collection("snapCircles")
      .doc(circleId)
      .collection("sessions")
      .doc(sessionId);
    batch.set(sessionRef, sessionSummary);
  }

  // delete active circle session
  const activeRef = admin.firestore().collection("activeCircles").doc(circleId);
  batch.delete(activeRef);

  // Set the next scheduled session if there is one
  let nextSession;
  if (scheduledSessions) {
    while (scheduledSessions.length > 0 && !nextSession) {
      const session = scheduledSessions.shift();
      if (session && session > Timestamp.now()) {
        nextSession = session;
      }
    }
  }

  // if the session state was 'expired', then we don't want to update the state for the main circle
  // entry to that but instead 'complete'.
  if (endState === SessionState.expired) {
    endState = SessionState.complete;
  }

  // update the circle to completed state
  batch.update(circleRef, {
    state: nextSession ? SessionState.scheduled : endState,
    completedDate,
    expiresOn: FieldValue.delete(),
    circleParticipants: [],
    participantCount: 0,
    scheduledSessions: scheduledSessions || FieldValue.delete(),
    nextSession: nextSession || FieldValue.delete(),
  });
  await batch.commit();
  return true;
}

export const endSnapSession = functions.https.onCall(async ({circleId}, {auth}): Promise<boolean> => {
  auth = isAuthenticated(auth);
  if (circleId) {
    const circleRef = admin.firestore().collection("snapCircles").doc(circleId);
    const circleSnapshot = await circleRef.get();
    if (circleSnapshot.exists) {
      const circleData = (circleSnapshot.data() as SnapCircleData) ?? {};
      const {keeper} = circleData;
      if (auth.uid !== keeper && !hasAnyRole(auth, [Role.ADMIN])) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "The function can only be called by the keeper of the circle or an admin."
        );
      }
      return endSessionFor(circleId, circleData, circleRef);
    }
  }
  return false;
});

export const startSnapSession = functions.https.onCall(async ({circleId}, {auth}): Promise<boolean> => {
  auth = isAuthenticated(auth);
  if (circleId) {
    const ref = admin.firestore().collection("snapCircles").doc(circleId);
    const circleSnapshot = await ref.get();
    if (circleSnapshot.exists) {
      const {state, keeper, maxMinutes} = (circleSnapshot.data() as SnapCircleData) ?? {};
      if (auth.uid !== keeper) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "The function can only be called by the keeper of the circle."
        );
      }
      if (state === SessionState.starting) {
        let sessionParticipants = {};

        // start the session
        await admin.firestore().runTransaction(async (transaction) => {
          const activeRef = admin.firestore().collection("activeCircles").doc(circleId);
          const activeCircleSnapshot = await transaction.get(activeRef);
          const activeSession = activeCircleSnapshot.data() ?? {};
          const {participants, speakingOrder, reordered} = activeSession;
          activeSession["totemReceived"] = false;
          if (Object.keys(participants).length > 0 && speakingOrder.length > 0) {
            // Assert that the keeper is the first participant in the list, only if the keeper has
            // not changed the order specifically
            if (!reordered) {
              const firstId = speakingOrder[0];
              const {uid} = participants[firstId];
              if (uid !== keeper) {
                // find the keepers sessionId
                const participant = (Object.values(participants) as Array<Participant>).find((participant: Participant) => participant.uid === keeper);
                if (participant && participant.sessionUserId) {
                  const index = speakingOrder.indexOf(participant.sessionUserId);
                  if (index != -1) {
                    speakingOrder.splice(index, 1);
                    speakingOrder.unshift(participant.sessionUserId);
                    activeSession["speakingOrder"] = speakingOrder;
                  }
                }
              }
            }
            // set the initial totem to the first participant
            activeSession["totemUser"] = participants[speakingOrder[0]].sessionUserId;
          }
          // update the active session
          transaction.update(activeRef, activeSession);
          sessionParticipants = participants;
        });
        // store the participants, but store them keyed by uid so it
        // can be looked up in case of need to rejoin
        const circleParticipants: string[] = [];
        Object.entries(sessionParticipants).forEach(([, value]) => {
          const uid: string = <string>(<Record<string, unknown>>value).uid;
          circleParticipants.push(uid);
        });
        // cache the participants at the circle level as an archive of the users that
        // are part of the started session
        const startedDate = Timestamp.now();
        const circleUpdate: {
          state: string;
          startedDate: Timestamp;
          circleParticipants: string[];
          expiresOn?: Timestamp;
        } = {state: SessionState.live, startedDate, circleParticipants};
        if (maxMinutes != null) {
          circleUpdate["expiresOn"] = new Timestamp(startedDate.seconds + maxMinutes * 60, 0);
        }
        ref.update(circleUpdate);
        return true;
      }
    }
  }
  return false;
});

/**
 * Initializes the activeCircle session for the given circle. Called when the circle is put into the waiting state
 * @param {string} circleId - the id of the circle for the session
 * @return {Promise}
 */
export async function initializeSessionFor(circleId: string): Promise<void> {
  console.log(`Initializing session for circle ${circleId}`);
  admin.firestore().collection("activeCircles").doc(circleId).set({participants: {}});
}

interface CreateSnapCircleResponse {
  id: string;
}

export const createSnapCircle = functions.https.onCall(
  async (
    {
      name,
      description,
      previousCircle,
      bannedParticipants,
      themeRef,
      imageUrl,
      bannerImageUrl,
      options,
    }: CreateSnapCircleArgs,
    {auth}
  ): Promise<CreateSnapCircleResponse> => {
    auth = isAuthenticated(auth);
    if (!name) {
      throw new functions.https.HttpsError("invalid-argument", "Missing name for snap circle");
    }

    if (!hasAnyRole(auth, [Role.KEEPER])) {
      // Non-keeper circles can't be re-started
      if (previousCircle) {
        throw new functions.https.HttpsError("permission-denied", "This circle has ended and cannot be re-started.");
      }
      // Non-keepers can only have one active circle
      await assertHasFewerCirclesThan(auth.uid, 1);
      // Non-keeper circles can only have a max of 5 participants, last at most one hour and must be private
      let maxParticipants = options?.maxParticipants ?? NonKeeperMaxParticipants;
      if (maxParticipants > NonKeeperMaxParticipants) {
        maxParticipants = NonKeeperMaxParticipants;
      }
      let maxMinutes = options?.maxMinutes ?? NonKeeperMaxMinutes;
      if (maxMinutes > NonKeeperMaxMinutes) {
        maxMinutes = NonKeeperMaxMinutes;
      }
      options = {
        isPrivate: true,
        maxMinutes,
        maxParticipants,
        recurringType: RecurringType.none,
      };
    } else if (previousCircle) {
      // Only the keeper can re-start a circle
      await assertIsCircleKeeper(auth.uid, previousCircle);
    }

    // Get the user ref
    const keeper = auth.uid;
    const userRef = admin.firestore().collection("users").doc(keeper);

    const created = Timestamp.now();
    const recurringType = options?.recurringType ?? RecurringType.none;
    const data: SnapCircleData = {
      name,
      createdOn: created,
      updatedOn: created,
      createdBy: userRef,
      isPrivate: options?.isPrivate ?? false,
      keeper,
      state: recurringType === RecurringType.none ? SessionState.waiting : SessionState.scheduled,
    };
    if (recurringType !== RecurringType.none) {
      if (recurringType === RecurringType.instances) {
        // Validate the instances and set the scheduled sessions list
        data.scheduledSessions = assertValidInstances(options?.instances);
      } else {
        // Validate the repeating options and generate the session list
        data.repeating = assertValidRepeatingOptions(options?.repeating);
        data.scheduledSessions = generateScheduledSessions(data.repeating);
      }
      // Set the next session to the first in the list
      data.nextSession = data.scheduledSessions?.shift();
    }
    if (options?.maxMinutes) {
      data.maxMinutes = options.maxMinutes;
    }
    if (options?.maxParticipants) {
      data.maxParticipants = options.maxParticipants;
    }
    if (description) {
      data.description = description;
    }
    if (previousCircle) {
      data.previousCircle = previousCircle;
    }
    if (bannedParticipants) {
      data.bannedParticipants = bannedParticipants;
    }
    if (themeRef) {
      data.themeRef = themeRef;
    }
    if (imageUrl) {
      data.imageUrl = imageUrl;
    }
    if (bannerImageUrl) {
      data.bannerImageUrl = bannerImageUrl;
    }
    const ref = await admin.firestore().collection("snapCircles").add(data);
    if (data.state === SessionState.waiting) {
      await initializeSessionFor(ref.id);
    }
    // Generate a dynamic link for this circle
    try {
      const host = isDev ? "stage" : "app";
      const {shortLink, previewLink} = await firebaseDynamicLinks.createLink(
        {
          dynamicLinkInfo: {
            domainUriPrefix: functions.config().applinks.link,
            link: `https://${host}.totem.org/?snap=${ref.id}`,
            androidInfo: {
              androidPackageName: "io.kbl.totem",
            },
            iosInfo: {
              iosBundleId: "io.kbl.totem",
            },
          },
          suffix: {
            option: "UNGUESSABLE",
          },
        },
        "createSnapCircle"
      );
      // update with the link
      await admin.firestore().collection("snapCircles").doc(ref.id).update({link: shortLink, previewLink});
    } catch (ex) {
      if (!process.env.FIREBASE_EMULATOR_HUB) {
        console.log("Failed to create dynamic link for circle ${ref.id}: ", ex);
      }
    }
    // return information
    return {id: ref.id};
  }
);

/**
 * Generate a list of session dates for a recurring session
 * @param {RepeatOptions} recurring  - The recurring options
 * @return {Timestamp[]}
 */
const generateScheduledSessions = ({
  start = Timestamp.now(),
  every = 1,
  unit = RepeatUnit.days,
  until,
  count,
}: RepeatOptions): Timestamp[] => {
  const sessions: Timestamp[] = [];
  let next = start;
  let i = 0;
  let done = false;
  if (count == null && !until) {
    count = 0; // Make sure it doesn't run forever
  }
  do {
    sessions.push(next);
    i++;
    next = Timestamp.fromDate(add(next.toDate(), {[unit]: every}));
    if (count != null && i >= count) {
      done = true;
    } else if (until && next > until) {
      done = true;
    }
  } while (!done);
  return sessions;
};

const assertValidInstances = (instances?: Timestamp[]): Timestamp[] => {
  // Recurring instances are just a list of scheduled sessions for the circle
  if (!instances) {
    throw new functions.https.HttpsError("invalid-argument", "Missing instances for recurring circle");
  }
  if (instances.length === 0) {
    throw new functions.https.HttpsError("invalid-argument", "Must have at least one instance for recurring circle");
  }
  instances = instances.map((i) => (typeof i === "string" ? Timestamp.fromDate(new Date(i)) : i));
  if (instances[0] <= Timestamp.now()) {
    throw new functions.https.HttpsError("invalid-argument", "First instance must be in the future");
  }
  if (instances.length > 1) {
    // Make sure the instances are in order
    for (let i = 1; i < instances.length; i++) {
      if (instances[i] <= instances[i - 1]) {
        throw new functions.https.HttpsError("invalid-argument", "Instances must be in ascending time order");
      }
    }
  }
  return instances;
};

const assertValidRepeatingOptions = (repeating?: RepeatOptions): RepeatOptions => {
  if (!repeating) {
    throw new functions.https.HttpsError("invalid-argument", "Missing repeat options for repeating circle");
  }
  // Repeating circles happen on a repeated schedule (i.e. every 5 days) based on a starting date/time
  if (!repeating.start) {
    throw new functions.https.HttpsError("invalid-argument", "Must have a start date for a repeating circle");
  }
  repeating.start =
    typeof repeating.start === "string" ? Timestamp.fromDate(new Date(repeating.start)) : repeating.start;
  if (repeating.start <= Timestamp.now()) {
    throw new functions.https.HttpsError("invalid-argument", "Start date must be in the future for repeating circle");
  }
  if (!repeating.every) {
    throw new functions.https.HttpsError("invalid-argument", "Must have a repeat interval for a repeating circle");
  }
  if (!repeating.unit) {
    throw new functions.https.HttpsError("invalid-argument", "Must have a time unit for a repeating circle");
  }
  // Repeating circles also must end either after a given date or after a specified number of sessions
  if (!repeating.until && repeating.count == null) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Must have either an end date or a session count for a repeating circle"
    );
  }
  if (repeating.until) {
    repeating.until =
      typeof repeating.until === "string" ? Timestamp.fromDate(new Date(repeating.until)) : repeating.until;
    if (repeating.until <= repeating.start) {
      throw new functions.https.HttpsError("invalid-argument", "End date for repeating circle must after the start");
    }
  }

  return repeating;
};

const assertHasFewerCirclesThan = async (uid: string, maxCircles: number): Promise<void> => {
  const ref = admin
    .firestore()
    .collection("snapCircles")
    .where("keeper", "==", uid)
    .where("state", "not-in", [SessionState.cancelled, SessionState.complete]);
  const snapshot = await ref.get();
  if (snapshot.size >= maxCircles) {
    throw new functions.https.HttpsError("permission-denied", "You have reached the maximum number of circles");
  }
};

const assertIsCircleKeeper = async (uid: string, circleId: string): Promise<void> => {
  const ref = admin.firestore().collection("snapCircles").doc(circleId);
  const snapshot = await ref.get();
  if (!snapshot.exists) {
    throw new functions.https.HttpsError("not-found", "Circle not found");
  }
  if (snapshot.data()?.keeper !== uid) {
    throw new functions.https.HttpsError("permission-denied", "You are not the keeper of this circle");
  }
};

/**
 * Kicks the current session user id out of the agora session and bans the user from joining the circle again
 * @param circleId The id of the circle to ban the user from
 * @param userId The user id of the user to ban
 * @param sessionUserId The id of the user within the current agora session
 */
export const banUserFromCircle = functions.https.onCall(async ({circleId, uid, sessionUserId}, {auth}) => {
  if (!circleId || !uid || !sessionUserId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "The function must be called with a circleId, uid and sessionUserId."
    );
  }
  try {
    await admin.firestore().runTransaction(async (transaction) => {
      auth = isAuthenticated(auth);
      const circleRef = admin.firestore().collection("snapCircles").doc(circleId);
      const circleSnapshot = await transaction.get(circleRef);
      const {bannedParticipants = {}, circleParticipants = [], keeper} = circleSnapshot.data() ?? {};
      if (auth.uid !== keeper && !hasAnyRole(auth, [Role.ADMIN])) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "The function can only be called by the keeper of the circle or an admin."
        );
      }
      // Ban the user's current session user id from the Agora session
      const banData: {bannedOn: Timestamp; sessionBan?: {sessionUserId: string; ruleId: number}} = {
        bannedOn: Timestamp.now(),
      };
      const {success, ruleId} = await kickUserFromSession(circleId, sessionUserId);
      if (!success) {
        console.warn(`Failed to kick user ${uid} from agora session as ${sessionUserId}`);
      } else {
        // Keep a record of the session ban in case we need to reference it later
        banData.sessionBan = {sessionUserId, ruleId: ruleId ?? -1};
      }
      // Add a record to the circle's list of banned participants
      bannedParticipants[uid] = banData;
      if (circleParticipants.includes(uid)) {
        circleParticipants.splice(circleParticipants.indexOf(uid), 1);
      }
      transaction.update(circleRef, {bannedParticipants, circleParticipants});
    });
    return true;
  } catch (ex) {
    console.error(`Failed to ban user from circle: ${ex}`);
  }
  return false;
});

/**
 * Update the snap circle with the new participant count when active session is updated
 * The activeCircle is updated by a normal member, but snapCircles can only be updated by the keeper
 * @param circleId The id of the circle to update
 */
export const updateParticipants = functions.firestore
  .document("activeCircles/{circleId}")
  .onUpdate(async (change, context) => {
    const {circleId} = context.params;
    const {participants: participantsBefore} = change.before.data() ?? {};
    let {
      participants: participantsAfter,
      totemReceived = false,
      totemUser = "",
      speakingOrder = [],
    } = change.after.data() ?? {};
    const previousUids = Object.keys(participantsBefore);
    const numBefore = previousUids.length;
    const numAfter = Object.keys(participantsAfter).length;
    if (numAfter !== numBefore) {
      // The number of participants has changed, so update the snap circle
      try {
        await admin.firestore().runTransaction(async (transaction) => {
          const circleRef = admin.firestore().collection("snapCircles").doc(circleId);
          transaction.update(circleRef, {participantCount: numAfter});

          // Users were removed from the session, so we need to update the speaking order
          if (numAfter < numBefore) {
            // Get the list of uids no longer in the session
            const removedUids = previousUids.filter((uid) => !participantsAfter[uid]);
            for (const uid of removedUids) {
              // Get the user index in the speaking order
              const index = speakingOrder.indexOf(uid);
              if (totemUser === uid) {
                // If the user was the speaker, update to the next speaker in the list
                let nextTotemUser = "";
                if (index < speakingOrder.length - 1) {
                  nextTotemUser = speakingOrder[index + 1];
                } else {
                  nextTotemUser = speakingOrder[0];
                }
                totemReceived = false;
                totemUser = nextTotemUser;
              }
              if (index > -1) {
                // Remove the user from the speaking order list
                speakingOrder.splice(index, 1);
              }
            }
            // Update the session data
            const sessionRef = admin.firestore().collection("activeCircles").doc(circleId);
            transaction.update(sessionRef, {totemReceived, totemUser, speakingOrder});
          }
        });
      } catch (e) {
        console.error(`Failed to update circle ${circleId} after participant change: `, e);
      }
    }
  });
