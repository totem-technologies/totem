import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as dynamicLinks from "./dynamic-links";
import {isAuthenticated} from "./auth";

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
  isAuthenticated(auth);
  if (circleId) {
    const circleRef = admin.firestore().collection("snapCircles").doc(circleId);
    const circleSnapshot = await circleRef.get();
    if (circleSnapshot.exists) {
      const {participants, state} = circleSnapshot.data() ?? {};
      const completedDate = admin.firestore.Timestamp.fromDate(new Date());
      const batch = admin.firestore().batch();
      let endState = SessionState.cancelled;
      if (state === SessionState.ending) {
        endState = SessionState.complete;
        const entry = {circleRef, completedDate};
        // moving from current state of 'active' to complete means the session is done
        // only cache the circle in users list if it was active
        if (participants) {
          Object.keys(participants).forEach((key)=>{
            const {role} = participants[key];
            const entryRef = admin.firestore().collection("users").doc(key).collection("snapCircles").doc();
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
  isAuthenticated(auth);
  if (circleId) {
    const ref = admin.firestore().collection("snapCircles").doc(circleId);
    const circleSnapshot = await ref.get();
    if (circleSnapshot.exists) {
      const {state} = circleSnapshot.data() ?? {};
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
        let keeper = "";
        const circleParticipants: string[] = [];
        Object.entries(sessionParticipants).forEach(([, value]) => {
          const uid: string = <string>(<Record<string, unknown>>value).uid;
          const role: string = <string>(<Record<string, unknown>>value).role;
          if (role === "keeper") {
            keeper = uid;
          }
          circleParticipants.push(uid);
        });
        // cache the participants at the circle level as an archive of the users that
        // are part of the started session
        const startedDate = admin.firestore.Timestamp.fromDate(new Date());
        ref.update({state: SessionState.live, startedDate, circleParticipants, keeper});
        return true;
      }
    }
  }
  return false;
});

export const createSnapCircle = functions.https.onCall(async ({name, description, keeper, previousCircle}, {auth}) => {
  auth = isAuthenticated(auth);
  if (!name) {
    throw new functions.https.HttpsError("failed-precondition", "Missing name for snap circle");
  }
  // Get the user ref
  const creatorId = keeper || auth.uid;
  const userRef = admin.firestore().collection("users").doc(creatorId);

  // Enable this block eventually to check for the proper permission for the user trying to create
  // the circle, currently anyone can create a snap circle
  /*
  const userSnapshot = await userRef.get();
  const { role } = (userSnapshot.exists ? (user.data() ?? {}) : {};
  if (!role  || role != 'keeper') {
      throw new functions.https.HttpsError("failed-precondition", "No permission to create snap circle");
  } */
  const created = admin.firestore.Timestamp.fromDate(new Date());
  const data : {name: string;
    createdOn: admin.firestore.Timestamp,
    updatedOn: admin.firestore.Timestamp,
    createdBy: admin.firestore.DocumentReference,
    state: string,
    description?: string,
    link?: string,
    previousCircle?: string,
  } = {
    name,
    createdOn: created,
    updatedOn: created,
    createdBy: userRef,
    state: SessionState.waiting,
  };
  if (description) {
    data.description = description;
  }
  if (previousCircle) {
    data.previousCircle = previousCircle;
  }
  const ref = await admin.firestore().collection("snapCircles").add(data);
  await admin.firestore().collection("activeCircles").doc(ref.id).set({participants: {}});
  // Generate a dynamic link for this circle
  try {
    const {shortLink, previewLink} = await firebaseDynamicLinks.createLink({
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
    }, "createSnapCircle");
    // update with the link
    await admin.firestore().collection("snapCircles").doc(ref.id).update({link: shortLink, previewLink});
  } catch (ex) {
    console.log(ex);
  }
  // return information
  return {id: ref.id};
});


