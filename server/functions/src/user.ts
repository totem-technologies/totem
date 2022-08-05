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
  auth = isAuthenticated(auth);
  if (!key) {
    throw new functions.https.HttpsError("failed-precondition", "Missing key for account state");
  }
  if (typeof key !== "string") {
    throw new functions.https.HttpsError("failed-precondition", "Key for account state must be string");
  }
  if (value == null) {
    throw new functions.https.HttpsError("failed-precondition", "Missing value for account state");
  }
  // Get the user data ref
  const userAccountStateRef = admin.firestore().collection("userAccountState").doc(auth.uid);
  try {
    const data: { [key: string]: unknown } = {};
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
