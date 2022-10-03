// eslint-disable-next-line import/no-unresolved -- https://github.com/firebase/firebase-admin-node/issues/1827#issuecomment-1226224988
import {Timestamp} from "firebase-admin/firestore";
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import {SessionState, SnapCircleData} from "./common-types";
import {endSessionFor} from "./session";
import {PubSub} from "@google-cloud/pubsub";

const expiringMinutes = 5;

export const scheduler = functions.pubsub.schedule("every 5 minutes").onRun(async () => {
  await setExpiringSessions();
  await endExpiredSessions();
  return null;
});

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

  /**
   * Runs the scheduler by publishing a message to the scheduler topic
   */
  const _publishToScheduler = async () => {
    const pubsub = new PubSub({projectId: process.env.GCLOUD_PROJECT});
    try {
      const SCHEDULED_FUNCTION_TOPIC = "firebase-schedule-scheduler";
      console.log(`Trigger sheduled function via PubSub topic: ${SCHEDULED_FUNCTION_TOPIC}`);
      const data = Buffer.from("start");
      const msg = await pubsub.topic(SCHEDULED_FUNCTION_TOPIC).publishMessage({data});
      console.log(`Message ${msg} published.`);
    } catch (err) {
      console.error(err);
    }
  };

  // Hit this endpoint to manually publish a message to the sceduler and run it immediately
  exports.runScheduler = functions.https.onRequest((req, response) => {
    _publishToScheduler();
    response.status(200).send("Published message to scheduler");
  });

  // Hit this endpoint to pubish a message to the scheduler every 5 minutes
  exports.startScheduler = functions.https.onRequest((req, response) => {
    setInterval(async () => _publishToScheduler, 5 * 60 * 1000); // every 5 minutes
    response.status(200).send("Scheduler started to run every 5 minutes");
  });
}
