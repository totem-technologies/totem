import * as functions from "firebase-functions";

export function isAuthenticated(auth: any) {
    if (!auth || !auth.uid) {
        throw new functions.https.HttpsError("failed-precondition", "The function must be called while authenticated.");
      }
}