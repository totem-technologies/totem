import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
// eslint-disable-next-line import/no-unresolved -- https://github.com/firebase/firebase-admin-node/issues/1827#issuecomment-1226224988
import {Timestamp} from "firebase-admin/firestore";
import * as dynamicLinks from "./dynamic-links";
import {hasAnyRole, isAuthenticated, Role} from "./auth";
import {kickUserFromSession} from "./agora";

// The Firebase Admin SDK to access the Firebase Realtime Database.
// make sure that this initializeApp call hasn't already
// happened
try {
  admin.initializeApp();
} catch (e) {
  console.log("re-initializing admin");
}

const firebaseDynamicLinks = new dynamicLinks.FirebaseDynamicLinks(functions.config().applinks.key);

const SessionState = {
  cancelled: "cancelled",
  complete: "complete",
  live: "live",
  waiting: "waiting",
  starting: "starting",
  ending: "ending",
};

export const endSnapSession = functions.https.onCall(async ({circleId}, {auth}): Promise<boolean> => {
  auth = isAuthenticated(auth);
  if (circleId) {
    const circleRef = admin.firestore().collection("snapCircles").doc(circleId);
    const circleSnapshot = await circleRef.get();
    if (circleSnapshot.exists) {
      const {circleParticipants, state, keeper} = circleSnapshot.data() ?? {};
      if (auth.uid !== keeper && !hasAnyRole(auth, [Role.ADMIN])) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "The function can only be called by the keeper of the circle or an admin."
        );
      }
      const completedDate = Timestamp.now();
      const batch = admin.firestore().batch();
      let endState = SessionState.cancelled;
      if (state === SessionState.ending) {
        endState = SessionState.complete;
        const entry = {circleRef, completedDate};
        // moving from current state of 'active' to complete means the session is done
        // only cache the circle in users list if it was active
        if (circleParticipants) {
          circleParticipants.forEach((uid: string) => {
            const entryRef = admin.firestore().collection("users").doc(uid).collection("snapCircles").doc();
            const role = keeper === uid ? "keeper" : "member";
            batch.set(entryRef, {...entry, role, completedDate});
          });
        }
      }
      // delete active circle reference
      const activeRef = admin.firestore().collection("activeCircles").doc(circleId);
      batch.delete(activeRef);

      // update the circle reference to completed state
      batch.update(circleRef, {state: endState, completedDate});
      await batch.commit();
      return true;
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
      const {state, keeper} = circleSnapshot.data() ?? {};
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
          const {participants, speakingOrder} = activeSession;
          activeSession["totemReceived"] = false;
          if (Object.keys(participants).length > 0 && speakingOrder.length > 0) {
            activeSession["totemUser"] = participants[speakingOrder[0]].sessionUserId;
          }
          activeSession["userStatus"] = false;
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
        ref.update({state: SessionState.live, startedDate, circleParticipants});
        return true;
      }
    }
  }
  return false;
});

interface SnapCircleResponse {
  id: string;
}

export const createSnapCircle = functions.https.onCall(
  async ({name, description, previousCircle, removedParticipants}, {auth}): Promise<SnapCircleResponse> => {
    auth = isAuthenticated(auth, [Role.KEEPER]);
    if (!name) {
      throw new functions.https.HttpsError("invalid-argument", "Missing name for snap circle");
    }
    // Get the user ref
    const keeper = auth.uid;
    const userRef = admin.firestore().collection("users").doc(keeper);

    const created = Timestamp.now();
    const data: {
      name: string;
      createdOn: Timestamp;
      updatedOn: Timestamp;
      createdBy: admin.firestore.DocumentReference;
      keeper: string;
      state: string;
      description?: string;
      link?: string;
      previousCircle?: string;
      removedParticipants?: string[];
    } = {
      name,
      createdOn: created,
      updatedOn: created,
      createdBy: userRef,
      keeper,
      state: SessionState.waiting,
    };
    if (description) {
      data.description = description;
    }
    if (previousCircle) {
      data.previousCircle = previousCircle;
    }
    if (removedParticipants) {
      data.removedParticipants = removedParticipants;
    }
    const ref = await admin.firestore().collection("snapCircles").add(data);
    await admin.firestore().collection("activeCircles").doc(ref.id).set({participants: {}});
    // Generate a dynamic link for this circle
    try {
      const {shortLink, previewLink} = await firebaseDynamicLinks.createLink(
        {
          dynamicLinkInfo: {
            domainUriPrefix: functions.config().applinks.link,
            link: "https://app.heytotem.com/?snap=" + ref.id,
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
      console.log(ex);
    }
    // return information
    return {id: ref.id};
  }
);

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
