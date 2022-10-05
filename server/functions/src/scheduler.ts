// eslint-disable-next-line import/no-unresolved -- https://github.com/firebase/firebase-admin-node/issues/1827#issuecomment-1226224988
import {Timestamp} from "firebase-admin/firestore";
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import {SessionState, SnapCircleData} from "./common-types";
import {endSessionFor} from "./session";
import {PubSub} from "@google-cloud/pubsub";

const expiringMinutes = 5;

export const scheduler = functions.pubsub.schedule("every 5 minutes").onRun(async () => {
  await performScheduledTasks();
  return null;
});

export const runScheduler = functions.https.onRequest(async (_, response) => {
  await performScheduledTasks();
  response.status(200).send("Schedule has run");
});

/**
 * Run all of the currently scheduled tasks. We can later break this up into separate sections
 * if we end up needing to run tasks at different intervals or want to run specific tasks on demand
 * @return {Promise}
 */
async function performScheduledTasks(): Promise<void> {
  // Do them in this order so we don't end sessions that were just set to expiring in the same run
  // This gives the frontend a chance to handle the expiring state
  await endExpiredSessions();
  await setExpiringSessions();
}

/**
 * Queries snapCircles for any sessions that have expired and ends them
 * @return {Promise}
 */
async function endExpiredSessions(): Promise<void> {
  const now: Timestamp = Timestamp.now();
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
  const in5Mins: Timestamp = new Timestamp(Timestamp.now().seconds + expiringMinutes * 60, 0);
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
