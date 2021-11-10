import {RtcTokenBuilder, RtcRole} from "agora-access-token";
import * as functions from "firebase-functions";

const appId = functions.config().agora.appid;
const appCertificate = functions.config().agora.certificate;
const role = RtcRole.PUBLISHER;
const defaultExpirationInSeconds = 60 * 60 * 5; // Default to 5 hours

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
