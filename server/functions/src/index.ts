import * as functions from "firebase-functions";

export * from "./agora";
export * from "./session";
export * from "./user";
export * from "./admin";
// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
export const ping = functions.https.onRequest((request, response) => {
  functions.logger.info(`ping from ${request.ip}`, {structuredData: true});
  response.send("pong");
});

