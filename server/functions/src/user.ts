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
  if (!value) {
    throw new functions.https.HttpsError("failed-precondition", "Missing value for account state");
  }
  // Get the user data ref
  const userAccountStateRef = admin.firestore().collection("userAccountState").doc(auth.uid);
  try {
    const data: { [key: string]: any } = {};
    data[key] = value;
    const userAccountStateSnapshot = await userAccountStateRef.get();
    if (!userAccountStateSnapshot.exists) {
      console.log("Setting " + auth.uid + " key: " + key);
      await userAccountStateRef.set(data);
    } else {
      console.log("updating " + auth.uid + " key: " + key);
      await userAccountStateRef.update(data);
    }
  } catch (ex) {
    console.log(ex);
  }
  // return information
  return await userAccountStateRef.get();
});
