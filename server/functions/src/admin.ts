import * as functions from "firebase-functions";

const token = functions.config().admin.token;

type actionsType = {
  [key: string]: (args: any) => string
}

const actions: actionsType = {
  make_keeper: makeKeeper,
};

export const admin = functions.https.onRequest((request, response) => {
  if (!token || request.get("TOKEN") !== token) {
    response.send("nope");
    return;
  }
  functions.logger.info(`admin from from ${request.ip}`, {structuredData: true});
  const action = actions[request.body.action];
  if (action === null) {
    response.send("invalid action");
  }
  response.send(action(request.body.args));
});


function makeKeeper(args: any): string {
  return `Make Keeper! ${args.uuid}`;
}