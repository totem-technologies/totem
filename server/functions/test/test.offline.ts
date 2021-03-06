import "mocha";
import * as chai from "chai";
import * as sinon from "sinon";
import * as testFunc from "firebase-functions-test";
import * as admin from "firebase-admin";
import {CloudFunction} from "firebase-functions";

describe("offline api tests", () => {
  admin.initializeApp();
  const assert = chai.assert;
  const test = testFunc();
  let myFunctions: {
    ping: (arg0: Record<string, unknown>, arg1: {send: (data: string) => void}) => void;
    getToken: CloudFunction<unknown>;
    deleteSelf: CloudFunction<unknown>;
  };
  let adminInitStub: sinon.SinonStub;

  before(() => {
    test.mockConfig({agora: {appid: "testappid0", certificate: "abcdefghij012345"}, applinks: {key: "testkey"}});
    adminInitStub = sinon.stub(admin, "initializeApp");
    myFunctions = require("../src");
  });

  after(() => {
    adminInitStub.restore();
    test.cleanup();
  });

  describe("ping", () => {
    it("should return pong", () => {
      const req = {ip: "127.0.0.1"};
      const res = {
        send: (data: string) => {
          assert.equal(data, "pong");
        },
      };
      myFunctions.ping(req, res);
    });
  });

  describe("getToken", () => {
    it("should return token with default expiration", () => {
      const oneHourFromNowInSeconds = Math.floor(Date.now() / 1000) + 3600;
      const wrapped = test.wrap(myFunctions.getToken);
      const {token, expiration} = wrapped({channelName: "test"}, {auth: {uid: "abcdefg123"}});
      assert.isString(token);
      assert.isAbove(token.length, 0);
      assert.isAtLeast(expiration, oneHourFromNowInSeconds);
    });
  });

  describe("deleteSelf", () => {
    it("should call admin.deleteUser and return true", async () => {
      const deleteUserStub = sinon.stub(admin.auth(), "deleteUser");
      deleteUserStub.returns(Promise.resolve());
      const wrapped = test.wrap(myFunctions.deleteSelf);
      const result = await wrapped({}, {auth: {uid: "abcdefg123"}});
      assert.isTrue(result);
      assert.isTrue(deleteUserStub.calledOnce);
      deleteUserStub.restore();
    });
  });
});
