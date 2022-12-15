// eslint-disable-next-line import/no-unresolved -- https://github.com/firebase/firebase-admin-node/issues/1827#issuecomment-1226224988
import {Timestamp} from "firebase-admin/firestore";
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import {SessionState, SnapCircleData} from "./common-types";
import {endSessionFor, initializeSessionFor} from "./session";
import {PubSub} from "@google-cloud/pubsub";

const SchedulerInterval = 5;

export const scheduler = functions.pubsub.schedule(`every ${SchedulerInterval} minutes`).onRun(async () => {
  await performAllTasks();
  return null;
});

export const runScheduler = functions.https.onRequest(async (_, response) => {
  await performAllTasks();
  response.status(200).send("Schedule has run");
});

/**
 * Run all of the currently scheduled tasks.
 * If we later decide we want these to run without waiting we can convert them to pubsub subjects and publish to them here
 * @return {Promise}
 */
async function performAllTasks(): Promise<void> {
  await Promise.all([activateScheduledSessions(), performExpirationTasks()]);
}

/**
 * Run all of the tasks associated with expiring sessions
 * @return {Promise}
 */
async function performExpirationTasks(): Promise<void> {
  await Promise.all([endUnstartedSessions(), endExpiredSessions(), setExpiringSessions()]);
}

/**
 * Queries snapCircles for any sessions that have expired and ends them
 * @return {Promise}
 */
async function endExpiredSessions(): Promise<void> {
  // Added a grace period from when the session is set to expiring to when it is actually ended
  // by the server. This gives the frontend a chance to end gracefully rather then end abruptly
  // at the exact time the session is set to expire
  const gracePeriod = 1800; // 30 minutes in seconds,
  const now: Timestamp = new Timestamp(Timestamp.now().seconds - gracePeriod, 0);
  const ref = admin
    .firestore()
    .collection("snapCircles")
    .where("state", "==", SessionState.expiring)
    .where("expiresOn", "<", now);
  const snapshot = await ref.get();
  for (const doc of snapshot.docs) {
    console.warn(`Session for circle ${doc.id} has expired, ending session`);
    await endSessionFor(doc.id, doc.data() as SnapCircleData);
  }
}

/**
 * Queries snapCircles for any sessions that will expire within 5 minutes and sets their status to "expiring"
 * This allows the frontend to privide warning and feedback to the user when a session is about to end
 * @return {Promise}
 */
async function setExpiringSessions(): Promise<void> {
  const in5Mins: Timestamp = new Timestamp(Timestamp.now().seconds + SchedulerInterval * 60, 0);
  const ref = admin
    .firestore()
    .collection("snapCircles")
    .where("state", "==", SessionState.live)
    .where("expiresOn", "<", in5Mins);
  const snapshot = await ref.get();
  for (const doc of snapshot.docs) {
    console.warn(`Setting session for circle ${doc.id} to expiring`);
    admin.firestore().collection("snapCircles").doc(doc.id).update({state: SessionState.expiring});
  }
}

/**
 * Queries snapCircles for any sessions that haven't started by their expiration time (plus a buffer) and ends them
 * @return {Promise}
 */
async function endUnstartedSessions(): Promise<void> {
  const min30 = 30*60;
  const nowMinusBuffer: Timestamp = new Timestamp(Timestamp.now().seconds - min30, 0);
  const ref = admin
    .firestore()
    .collection("snapCircles")
    .where("state", "==", SessionState.waiting)
    .where("expiresOn", "<", nowMinusBuffer);
  const snapshot = await ref.get();
  for (const doc of snapshot.docs) {
    console.warn(`Session for circle ${doc.id} has was never started, ending session`);
    await endSessionFor(doc.id, doc.data() as SnapCircleData);
  }
}

/**
 * This function is used to move any sessions that are set to start in the next few minutes
 * into the waiting state and to prepare the session data for the circle.
 */
async function activateScheduledSessions(): Promise<void> {
  const in5Mins: Timestamp = new Timestamp(Timestamp.now().seconds + SchedulerInterval * 60, 0);
  const ref = admin
    .firestore()
    .collection("snapCircles")
    .where("state", "==", SessionState.scheduled)
    .where("nextSession", "<", in5Mins);
  const snapshot = await ref.get();
  const promises = snapshot.docs.flatMap((doc) => [
    initializeSessionFor(doc.id),
    activateCircle(doc.id, doc.data() as SnapCircleData),
  ]);
  await Promise.all(promises);
}

/**
 * Puts the circle into the waiting state and calcualates the expiration time for the session
 *
 * @param {string} circleId - circle ID
 * @param {SnapCircleData} circleData - the circle data object
 * @return {Promise}
 */
async function activateCircle(circleId: string, circleData: SnapCircleData): Promise<void> {
  const {maxMinutes, nextSession} = circleData;
  const circleUpdate: {state: string; expiresOn?: Timestamp} = {
    state: SessionState.waiting,
  };
  if (maxMinutes != null && nextSession != null) {
    // A scheduled circle's expiration time is based on the time it was scheduled to start
    circleUpdate["expiresOn"] = new Timestamp(nextSession.seconds + maxMinutes * 60, 0);
  }

  await admin.firestore().collection("snapCircles").doc(circleId).update(circleUpdate);
}

if (process.env.FUNCTIONS_EMULATOR === "true") {
  // These endpoints are only available in the local emulator because it doesn't support actually schduling
  // the pubsub functions https://github.com/firebase/firebase-tools/issues/2034#issuecomment-1215972419

  const SCHEDULER_FUNCTION_TOPIC = "firebase-schedule-scheduler";
  const PUBSUB_SIMULATE_TOPIC = "firebase-pubsub-simulate";
  /**
   * Runs the scheduler by publishing a message to the scheduler topic
   * @param {string} topic - The topic to publish to
   * @return {Promise}
   */
  const _publishToTopic = async (topic: string): Promise<void> => {
    const pubsub = new PubSub({projectId: process.env.GCLOUD_PROJECT});
    try {
      console.log(`Trigger sheduled function via PubSub topic: ${topic}`);
      const data = Buffer.from("start");
      const msg = await pubsub.topic(topic).publishMessage({data});
      console.log(`Message ${msg} published.`);
    } catch (err) {
      console.error(err);
    }
  };

  // Pubsub handler with a timeout of 6 minutes so that it set a 5 minute timeout to send a message to run the scheduler
  // and then send a message to itself to run again
  exports.pubSubScheduler = functions
    .runWith({timeoutSeconds: 60 * 6})
    .pubsub.topic(PUBSUB_SIMULATE_TOPIC)
    .onPublish(async () => {
      setTimeout(async () => {
        await _publishToTopic(SCHEDULER_FUNCTION_TOPIC);
        await _publishToTopic(PUBSUB_SIMULATE_TOPIC);
      }, 5 * 60 * 1000);
    });

  // Hit this endpoint to start simulating the pubsub scheduler running every 5 minutes
  exports.simulateScheduler = functions.https.onRequest(async (_, response) => {
    await _publishToTopic(PUBSUB_SIMULATE_TOPIC);
    response.status(200).send("Scheduler started to run every 5 minutes");
  });
}
