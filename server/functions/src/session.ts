import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as dynamicLinks from "firebase-dynamic-links";
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
    const ref = admin.firestore().collection("snapCircles").doc(circleId);
    const circleSnapshot = await ref.get();
    if (circleSnapshot.exists) {
      const {participants, state} = circleSnapshot.data() ?? {};
      const completedDate = admin.firestore.Timestamp.fromDate(new Date());
      const batch = admin.firestore().batch();
      let endState = SessionState.cancelled;
      if (state === SessionState.ending) {
        endState = SessionState.complete;
        const entry = {ref, completedDate};
        // moving from current state of 'active' to complete means the session is done
        // only cache the circle in users list if it was active
        if (participants) {
          participants.forEach(({uid, role} : {uid: string; role: string }) => {
            const entryRef = admin.firestore().collection("users").doc(uid).collection("snapCircles").doc();
            batch.set(entryRef, {...entry, role, completedDate});
          });
        }
      }
      batch.update(ref, {state: endState, completedDate, activeSession: {}});
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

export const createSnapCircle = functions.https.onCall(async ({name, description}, {auth}) => {
  auth = isAuthenticated(auth);
  if (!name) {
    throw new functions.https.HttpsError("failed-precondition", "Missing name for snap circle");
  }
  // Get the user ref
  const userRef = admin.firestore().collection("users").doc(auth.uid);

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
    activeSession: {started: admin.firestore.Timestamp},
    description?: string,
    link?: string
  } = {
    name,
    createdOn: created,
    updatedOn: created,
    createdBy: userRef,
    state: SessionState.waiting,
    activeSession: {
      started: created,
    },
  };
  if (description) {
    data.description = description;
  }
  const ref = await admin.firestore().collection("snapCircles").add(data);
  // Generate a dynamic link for this circle
  console.log("Created circle with ref: " + ref.id);
  try {
    const {shortLink, previewLink} = await firebaseDynamicLinks.createLink({
      dynamicLinkInfo: {
        domainUriPrefix: functions.config().applinks.link,
        link: "https://app.heytotem.com/circlesession/" + ref.id,
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
    });
    console.log("Created circle link: " + shortLink + " preview: " + previewLink);
    // update with the link
    await admin.firestore().collection("snapCircles").doc(ref.id).update({link: shortLink, previewLink});
  } catch (ex) {
    console.log("Unable to create dynamic link for circle: " + ex);
  }
  // return information
  return {id: ref.id};
});


