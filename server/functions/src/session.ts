import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// The Firebase Admin SDK to access the Firebase Realtime Database.
// make sure that this initializeApp call hasn't already
// happened
try {
  admin.initializeApp();
} catch (e) {
  console.log("re-initializing admin");
}

const SessionState = {
  cancelled: "cancelled",
  complete: "complete",
  live: "live",
  waiting: "waiting",
  starting: "starting",
};

export const endSnapSession = functions.https.onCall(async ({circleId}, {auth}) => {
  if (!auth || !auth.uid) {
    throw new functions.https.HttpsError("failed-precondition", "The function must be called while authenticated.");
  }
  if (circleId) {
    const ref = admin.firestore().collection("snapCircles").doc(circleId);
    const circleSnapshot = await ref.get();
    if (circleSnapshot.exists) {
      const {activeSession: {participants}, state} = circleSnapshot.data() ?? {};
      const completedDate = admin.firestore.Timestamp.fromDate(new Date());
      const batch = admin.firestore().batch();
      let endState = SessionState.cancelled;
      if (state === SessionState.live) {
        endState = SessionState.complete;
        const entry = {ref, completedDate};
        // moving from current state of 'active' to complete means the session is done
        // only cache the circle in users list if it was active
        participants.forEach(({ref: userRef, role} : {ref: admin.firestore.DocumentReference; role: string }) => {
          const entryRef = userRef.collection("snapCircles").doc();
          batch.set(entryRef, {...entry, role, completedDate});
        });
      }
      batch.update(ref, {state: endState, completedDate, activeSession: {}});
      await batch.commit();
      return true;
    }
  }
  return false;
});

export const startSnapSession = functions.https.onCall(async ({circleId}, {auth}) => {
  if (!auth || !auth.uid) {
    throw new functions.https.HttpsError("failed-precondition", "The function must be called while authenticated.");
  }
  if (circleId) {
    const ref = admin.firestore().collection("snapCircles").doc(circleId);
    const circleSnapshot = await ref.get();
    if (circleSnapshot.exists) {
      const {activeSession, activeSession: {participants}, state} = circleSnapshot.data() ?? {};
      if (state === SessionState.starting) {
        const startedDate = admin.firestore.Timestamp.fromDate(new Date());
        activeSession["totemReceived"] = false;
        if (participants.length > 0) {
          activeSession["totemUser"] = participants[0].sessionUserId;
        }
        // cache the participants at the circle level as an archive of the users that
        // are part of the started session
        ref.update({state: SessionState.live, startedDate, participants, activeSession});
        return true;
      }
    }
  }
  return false;
});

