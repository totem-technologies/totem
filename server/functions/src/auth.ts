import * as functions from "firebase-functions";
import {AuthData} from "firebase-functions/lib/common/providers/https";

/**
 * Checks if the `auth` object exists, and has a uid. Returns a non-null auth object.
 * @param {AuthData | undefined} auth
 * @return {AuthData}
 */
export function isAuthenticated(auth: AuthData | undefined): AuthData {
  if (!auth || !auth.uid) {
    throw new functions.https.HttpsError("failed-precondition", "The function must be called while authenticated.");
  }
  return auth;
}
