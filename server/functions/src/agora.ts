import {RtcTokenBuilder, RtcRole} from "agora-access-token";
import * as functions from "firebase-functions";
import { isAuthenticated } from "./auth";

const appId = functions.config().agora.appid;
const appCertificate = functions.config().agora.certificate;
const role = RtcRole.PUBLISHER;
const defaultExpirationInSeconds = 60 * 60 * 5; // Default to 5 hours

export const getToken = functions.https.onCall(({channelName, expirationInSeconds}, {auth}) => {
  const currentTimestamp = Math.floor(Date.now() / 1000);
  const expirationTimeInSeconds = expirationInSeconds || defaultExpirationInSeconds;
  const expiration = currentTimestamp + expirationTimeInSeconds;

  isAuthenticated(auth);

  // TODO: Might want to validate channelName and user's inclusion in the channel before generating a token
  const token = RtcTokenBuilder.buildTokenWithAccount(appId, appCertificate, channelName, auth!.uid, role, expiration);

  return {token, expiration};
});

export const getTokenWithUserId = functions.https.onCall(({channelName, expirationInSeconds, userId}, {auth}) => {
  const currentTimestamp = Math.floor(Date.now() / 1000);
  const expirationTimeInSeconds = expirationInSeconds || defaultExpirationInSeconds;
  const expiration = currentTimestamp + expirationTimeInSeconds;
  const uid = userId || Math.floor(Math.random() * 10000);

  isAuthenticated(auth);

  // TODO: Might want to validate channelName and user's inclusion in the channel before generating a token
  const token = RtcTokenBuilder.buildTokenWithUid(appId, appCertificate, channelName, uid, role, expiration);

  return {token, expiration, uid};
});
