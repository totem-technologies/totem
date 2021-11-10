import {RtcTokenBuilder, RtcRole} from "agora-access-token";
import * as functions from "firebase-functions";

// TODO: If we are worried about code leakage these constants can be moved into the DB
const appId = "4880737da9bf47e290f46d847cd1c3b1";
const appCertificate = "c4ccb470443048c0b05fa686566a1fe5";
const role = RtcRole.PUBLISHER;
const defaultExpirationInSeconds = 3600;

export const getToken = functions.https.onCall(({channelName, expirationInSeconds}, {auth}) => {
  const currentTimestamp = Math.floor(Date.now() / 1000);
  const expirationTimeInSeconds = expirationInSeconds || defaultExpirationInSeconds;
  const expiration = currentTimestamp + expirationTimeInSeconds;

  if (!auth || !auth.uid) {
    throw new functions.https.HttpsError("failed-precondition", "The function must be called while authenticated.");
  }

  // TODO: Might want to validate channelName and user's inclusion in the channel before generating a tocken
  const token = RtcTokenBuilder.buildTokenWithAccount(appId, appCertificate, channelName, auth.uid, role, expiration);

  return {token, expiration};
});
