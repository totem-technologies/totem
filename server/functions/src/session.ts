import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
// eslint-disable-next-line import/no-unresolved
import {Timestamp} from "firebase-admin/firestore";
import * as dynamicLinks from "./dynamic-links";
import {hasAnyRole, isAuthenticated, Role} from "./auth";

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

export const endSnapSession = functions.https.onCall(async ({circleId}, {auth}) => {
  auth = isAuthenticated(auth);
  if (circleId) {
    const circleRef = admin.firestore().collection("snapCircles").doc(circleId);
    const circleSnapshot = await circleRef.get();
    if (circleSnapshot.exists) {
      const {circleParticipants, state, keeper} = circleSnapshot.data() ?? {};
      if (auth.uid !== keeper && !hasAnyRole(auth, [Role.ADMIN])) {
        throw new functions.https.HttpsError(
          "failed-precondition",
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

export const startSnapSession = functions.https.onCall(async ({circleId}, {auth}) => {
  auth = isAuthenticated(auth);
  if (circleId) {
    const ref = admin.firestore().collection("snapCircles").doc(circleId);
    const circleSnapshot = await ref.get();
    if (circleSnapshot.exists) {
      const {state, keeper} = circleSnapshot.data() ?? {};
      if (auth.uid !== keeper) {
        throw new functions.https.HttpsError(
          "failed-precondition",
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

export const createSnapCircle = functions.https.onCall(
  async ({name, description, previousCircle, removedParticipants}, {auth}) => {
    auth = isAuthenticated(auth, [Role.KEEPER]);
    if (!name) {
      throw new functions.https.HttpsError("failed-precondition", "Missing name for snap circle");
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
 * Update the snap circle with the new participant count when active session is updated
 * The activeCircle is updated by a normal member, but snapCircles can only be updated by the keeper
 * @param circleId The id of the circle to update
 */
export const updateParticipants = functions.firestore
  .document("activeCircles/{circleId}")
  .onUpdate(async (change, context) => {
    const {circleId} = context.params;
    const {participants: participantsBefore} = change.before.data() ?? {};
    const {participants: participantsAfter} = change.after.data() ?? {};
    const numBefore = Object.keys(participantsBefore).length;
    const numAfter = Object.keys(participantsAfter).length;
    if (numAfter !== numBefore) {
      const ref = admin.firestore().collection("snapCircles").doc(circleId);
      await ref.update({participantCount: numAfter});
    }
  });
