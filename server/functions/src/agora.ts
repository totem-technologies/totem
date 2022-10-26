import {RtcTokenBuilder, RtcRole} from "agora-access-token";
import axios from "axios";
import {AxiosError} from "axios";
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {isAuthenticated} from "./auth";
import {SnapCircleData} from "./common-types";

const agoraHost = "https://api.agora.io";
const appid = functions.config().agora.appid;
const appCertificate = functions.config().agora.certificate;
const restapikey = functions.config().agora.restapikey;
const restapisecret = functions.config().agora.restapisecret;
const role = RtcRole.PUBLISHER;
const defaultExpirationInSeconds = 60 * 60 * 5; // Default to 5 hours

const agoraApi = axios.create({
  baseURL: `${agoraHost}/dev/v1/`,
  headers: {
    "Content-Type": "application/json",
  },
  auth: {username: restapikey, password: restapisecret},
});

// Base for agora REST responses
interface AgoraResponse {
  status: string;
}

// Response from agora REST API for kicking a user from a channel
interface AgoraKickResponse extends AgoraResponse {
  id: number;
}

// TODO: Handle scheduled circles once we re-enable that feature
const assertUserCanJoinCircle = async (uid: string, circleId: string) => {
  const circleRef = admin.firestore().collection("snapCircles").doc(circleId);
  const circleSnapshot = await circleRef.get();
  if (!circleSnapshot.exists) {
    console.log(`User ${uid} tried to join circle ${circleId} but it doesn't exist`);
    throw new functions.https.HttpsError("not-found", "The circle with the specified id does not exist.");
  }
  const {bannedParticipants, maxParticipants, participantCount = 0} = (circleSnapshot.data() as SnapCircleData) ?? {};
  if (bannedParticipants && bannedParticipants[uid]) {
    console.log(`User ${uid} tried to join circle ${circleId} but they are banned`);
    throw new functions.https.HttpsError("permission-denied", "User has been removed from this circle.");
  }
  if (maxParticipants && participantCount >= maxParticipants) {
    console.log(`User ${uid} tried to join circle ${circleId} but it is full`);
    throw new functions.https.HttpsError("resource-exhausted", "This circle is full.");
  }
};

interface GetTokenResponse {
  token: string;
  expiration: number;
  uid?: string;
}

export const getToken = functions.https.onCall(
  async ({channelName, expirationInSeconds}, {auth}): Promise<GetTokenResponse> => {
    const currentTimestamp = Math.floor(Date.now() / 1000);
    const expirationTimeInSeconds = expirationInSeconds || defaultExpirationInSeconds;
    const expiration = currentTimestamp + expirationTimeInSeconds;

    auth = isAuthenticated(auth);
    await assertUserCanJoinCircle(auth.uid, channelName);
    const token = RtcTokenBuilder.buildTokenWithAccount(appid, appCertificate, channelName, auth.uid, role, expiration);

    return {token, expiration};
  }
);

export const getTokenWithUserId = functions.https.onCall(
  async ({channelName, expirationInSeconds, userId}, {auth}): Promise<GetTokenResponse> => {
    const currentTimestamp = Math.floor(Date.now() / 1000);
    const expirationTimeInSeconds = expirationInSeconds || defaultExpirationInSeconds;
    const expiration = currentTimestamp + expirationTimeInSeconds;
    const uid = userId || Math.floor(Math.random() * 10000);

    auth = isAuthenticated(auth);
    await assertUserCanJoinCircle(auth.uid, channelName);
    // TODO: Might want to validate channelName and user's inclusion in the channel before generating a token
    const token = RtcTokenBuilder.buildTokenWithUid(appid, appCertificate, channelName, uid, role, expiration);

    return {token, expiration, uid};
  }
);

export interface KickUserResonse {
  success: boolean;
  ruleId?: number;
}
export const kickUserFromSession = async (cname: string, uid: string): Promise<KickUserResonse> => {
  const body = {
    appid,
    cname,
    uid,
    time: 1440,
    privileges: ["join_channel"],
  };
  try {
    const {data} = await agoraApi.post("/kicking-rule", body);
    const {status, id} = data as AgoraKickResponse;
    return {success: status === "success", ruleId: id};
  } catch (ex) {
    if (axios.isAxiosError(ex)) {
      const error = ex as AxiosError;
      console.error("Failed to ban user from session: ", error.message);
      if (error.response?.data) {
        const data = error.response.data as {message: unknown};
        console.error("Failed to ban user from session: ", data.message);
      }
    } else {
      console.error("Failed to ban user from session: ", ex);
    }
  }
  return {success: false};
};
