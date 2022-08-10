import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {isAuthenticated} from "./auth";

try {
  admin.initializeApp();
} catch (e) {
  console.log("re-initializing admin");
}

export const deleteSelf = functions.https.onCall(async (_, {auth}) => {
  try {
    auth = isAuthenticated(auth);
    await admin.auth().deleteUser(auth.uid);
    return true;
  } catch (e) {
    console.error(`Unable to delete user: ${e}`);
    return false;
  }
});

export const updateAccountState = functions.https.onCall(async ({key, value}, {auth}) => {
  const protectedKeys = ["auth"];
  auth = isAuthenticated(auth);
  if (!key) {
    throw new functions.https.HttpsError("failed-precondition", "Missing key for account state");
  }
  if (typeof key !== "string") {
    throw new functions.https.HttpsError("failed-precondition", "Key for account state must be string");
  }
  if (protectedKeys.includes(key)) {
    throw new functions.https.HttpsError("failed-precondition", "Key for account state is protected");
  }
  if (value == null) {
    throw new functions.https.HttpsError("failed-precondition", "Missing value for account state");
  }
  // Get the user data ref
  const userAccountStateRef = admin.firestore().collection("userAccountState").doc(auth.uid);
  try {
    const data: {[key: string]: unknown} = {};
    data[key] = value;
    const userAccountStateSnapshot = await userAccountStateRef.get();
    if (!userAccountStateSnapshot.exists) {
      await userAccountStateRef.set(data);
    } else {
      await userAccountStateRef.update(data);
    }
  } catch (ex) {
    console.error("Failed updating account state: ", ex);
  }
  // return information
  return await userAccountStateRef.get();
});

/**
 * Set custom claims on user idToken when user roles are edited in userAccountState collection.
 * Also sets the "reauth" key to current timestamp to trigger re-authentication in client.
 */
export const updateRoles = functions.firestore
  .document("userAccountState/{uid}/auth/permissions")
  .onWrite(async (change, context) => {
    const {
      params: {uid},
    } = context;
    const now = new Date();
    const {roles = []} = change.after.data() ?? {};
    console.info(`Updating roles for user ${uid} to [${roles}]`);
    // Set custom user claims
    try {
      await admin.auth().setCustomUserClaims(uid, {roles});
      await admin
        .firestore()
        .collection("userAccountState")
        .doc(uid)
        .collection("auth")
        .doc("controls")
        .set({refresh: now}, {merge: true});
    } catch (ex) {
      console.error(`Failed updating roles for user ${uid}: ${ex}`);
    }
  });

export const seedUserAccountState = functions.auth.user().onCreate(async (user) => {
  const {uid} = user;
  const permissionsRef = admin
    .firestore()
    .collection("userAccountState")
    .doc(uid)
    .collection("auth")
    .doc("permissions");
  const permissionsSnapshot = await permissionsRef.get();
  console.log(`Seeding userAccountState for user ${uid}`);
  if (!permissionsSnapshot.exists) {
    await permissionsRef.set({
      roles: [],
    });
  }
});
