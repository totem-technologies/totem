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
