import "mocha";
import * as chai from "chai";
import * as sinon from "sinon";
import * as testFunc from "firebase-functions-test";
import * as admin from "firebase-admin";
import {CloudFunction, https} from "firebase-functions";
import {CreateSnapCircleArgs, RecurringType, RepeatUnit, SnapCircleData, SessionState} from "../src/common-types";
// eslint-disable-next-line import/no-unresolved -- https://github.com/firebase/firebase-admin-node/issues/1827#issuecomment-1226224988
import {Timestamp} from "firebase-admin/firestore";
import {add} from "date-fns";

describe("unit tests", function () {
  admin.initializeApp();
  const assert = chai.assert;
  const test = testFunc();
  let myFunctions: {
    getToken: CloudFunction<{channelName: string}>;
    deleteSelf: CloudFunction<object>;
    updateAccountState: CloudFunction<{key?: string | number; value?: string | object}>;
    createSnapCircle: CloudFunction<CreateSnapCircleArgs>;
  };
  let adminInitStub: sinon.SinonStub;

  before(function () {
    test.mockConfig({agora: {appid: "testappid0", certificate: "abcdefghij012345"}, applinks: {key: "testkey"}});
    adminInitStub = sinon.stub(admin, "initializeApp");
    myFunctions = require("../src");
  });

  after(function () {
    adminInitStub.restore();
    test.cleanup();
  });

  describe("getToken", function () {
    it("should assert that circle does not exist", async function () {
      // const oneHourFromNowInSeconds = Math.floor(Date.now() / 1000) + 3600;
      const wrapped = test.wrap(myFunctions.getToken);
      try {
        await wrapped({channelName: "test"}, {auth: {uid: "abcdefg123"}});
      } catch (e) {
        const ex: https.HttpsError = e as https.HttpsError;
        assert.equal(ex.code, "not-found");
        assert.equal(ex.message, "The circle with the specified id does not exist.");
      }
      // assert.isString(token);
      // assert.isAbove(token.length, 0);
      // assert.isAtLeast(expiration, oneHourFromNowInSeconds);
    });
  });

  describe("deleteSelf", function () {
    it("should call admin.deleteUser and return true", async function () {
      const deleteUserStub = sinon.stub(admin.auth(), "deleteUser");
      deleteUserStub.returns(Promise.resolve());
      const wrapped = test.wrap(myFunctions.deleteSelf);
      const result = await wrapped({}, {auth: {uid: "abcdefg123"}});
      assert.isTrue(result);
      assert.isTrue(deleteUserStub.calledOnce);
      deleteUserStub.restore();
    });
  });

  describe("updateAccountState", function () {
    // Just testing pre-conditions for now as mocking admin.firestore() offline is too much work
    it("should throw error if missing key", async function () {
      const wrapped = test.wrap(myFunctions.updateAccountState);
      try {
        await wrapped({value: "test"}, {auth: {uid: "abcdefg123"}});
        assert.fail("should have thrown error");
      } catch (e) {
        const ex: https.HttpsError = e as https.HttpsError;
        assert.equal(ex.code, "failed-precondition");
        assert.equal(ex.message, "Missing key for account state");
      }
    });
    it("should throw error if key is not string", async function () {
      const wrapped = test.wrap(myFunctions.updateAccountState);
      try {
        await wrapped({key: 123, value: "test"}, {auth: {uid: "abcdefg123"}});
        assert.fail("should have thrown error");
      } catch (e) {
        const ex: https.HttpsError = e as https.HttpsError;
        assert.equal(ex.code, "failed-precondition");
        assert.equal(ex.message, "Key for account state must be string");
      }
    });
    it("should throw error if missing value", async function () {
      const wrapped = test.wrap(myFunctions.updateAccountState);
      try {
        await wrapped({key: "test"}, {auth: {uid: "abcdefg123"}});
        assert.fail("should have thrown error");
      } catch (e) {
        const ex: https.HttpsError = e as https.HttpsError;
        assert.equal(ex.code, "failed-precondition");
        assert.equal(ex.message, "Missing value for account state");
      }
    });
    it("should throw error if key is protected", async function () {
      const wrapped = test.wrap(myFunctions.updateAccountState);
      try {
        await wrapped({key: "auth", value: {permissions: {roled: ["admin"]}}}, {auth: {uid: "abcdefg123"}});
        assert.fail("should have thrown error");
      } catch (e) {
        const ex: https.HttpsError = e as https.HttpsError;
        assert.equal(ex.code, "failed-precondition");
        assert.equal(ex.message, "Key for account state is protected");
      }
    });
  });

  describe("createCircle", function () {
    let testCircleId: string;

    afterEach(async function () {
      if (testCircleId) {
        await admin.firestore().collection("snapCircles").doc(testCircleId).delete();
      }
    });

    describe("general", function () {
      it("should throw error if missing name", async function () {
        const wrapped = test.wrap(myFunctions.createSnapCircle);
        try {
          await wrapped({name: "", description: ""}, {auth: {uid: "abcdefg123"}});
          assert.fail("should have thrown error");
        } catch (e) {
          const ex: https.HttpsError = e as https.HttpsError;
          assert.equal(ex.code, "invalid-argument");
          assert.equal(ex.message, "Missing name for snap circle");
        }
      });
    });

    describe("non-keeper", function () {
      it("should throw permission denied for circle restart", async function () {
        const wrapped = test.wrap(myFunctions.createSnapCircle);
        try {
          await wrapped(
            {name: "New Circle", description: "", previousCircle: "xyz123"},
            {auth: {uid: "abcdefg123", token: {}}}
          );
          assert.fail("should have thrown error");
        } catch (e) {
          const ex: https.HttpsError = e as https.HttpsError;
          assert.equal(ex.code, "permission-denied");
          assert.equal(ex.message, "This circle has ended and cannot be re-started.");
        }
      });
      it("should create a default private circle with restrictions", async function () {
        const wrapped = test.wrap(myFunctions.createSnapCircle);
        const {id} = await wrapped({name: "Test Circle", description: "Test"}, {auth: {uid: "abcdefg123", token: {}}});
        testCircleId = id;
        assert.isString(testCircleId, `circleId is ${testCircleId}`);
        const ref = admin.firestore().collection("snapCircles").doc(testCircleId);
        const doc = await ref.get();
        assert.isTrue(doc.exists, "circle document exists");
        const {isPrivate, maxMinutes, maxParticipants, state} = doc.data() as SnapCircleData;
        assert.equal(state, SessionState.waiting, "state is waiting");
        assert.isTrue(isPrivate, "circle is private");
        assert.equal(maxMinutes, 60, "circle is max 60 minutes");
        assert.equal(maxParticipants, 5, "circle has max 5 participants");
      });
      it("should apply circle restrictions", async function () {
        const wrapped = test.wrap(myFunctions.createSnapCircle);
        const {id} = await wrapped(
          {name: "Test Circle", description: "Test", options: {isPrivate: false, maxMinutes: 90, maxParticipants: 15}},
          {auth: {uid: "abcdefg123", token: {}}}
        );
        testCircleId = id;
        const ref = admin.firestore().collection("snapCircles").doc(testCircleId);
        const doc = await ref.get();
        assert.isTrue(doc.exists, "circle document exists");
        const {isPrivate, maxMinutes, maxParticipants} = doc.data() as SnapCircleData;
        assert.isTrue(isPrivate, "circle is private");
        assert.equal(maxMinutes, 60, "circle is max 60 minutes");
        assert.equal(maxParticipants, 5, "circle has max 5 participants");
      });
      it("should allow tighter restrictions", async function () {
        const wrapped = test.wrap(myFunctions.createSnapCircle);
        const {id} = await wrapped(
          {name: "Test Circle", description: "Test", options: {isPrivate: true, maxMinutes: 15, maxParticipants: 3}},
          {auth: {uid: "abcdefg123", token: {}}}
        );
        testCircleId = id;
        const ref = admin.firestore().collection("snapCircles").doc(testCircleId);
        const doc = await ref.get();
        assert.isTrue(doc.exists, "circle document exists");
        const {maxMinutes, maxParticipants} = doc.data() as SnapCircleData;
        assert.equal(maxMinutes, 15, "circle has max 15 minutes");
        assert.equal(maxParticipants, 3, "circle has max 3 participants");
      });
    });

    describe("keeper", function () {
      it("should throw not found if previous circle doesn't exist", async function () {
        const wrapped = test.wrap(myFunctions.createSnapCircle);
        try {
          await wrapped(
            {name: "New Circle", description: "", previousCircle: "xyz123"},
            {auth: {uid: "abcdefg123", token: {roles: ["keeper"]}}}
          );
          assert.fail("should have thrown error");
        } catch (e) {
          const ex: https.HttpsError = e as https.HttpsError;
          assert.equal(ex.code, "not-found");
          assert.equal(ex.message, "Circle not found");
        }
      });
      it("should throw permission denied if not previous circle keeper", async function () {
        const wrapped = test.wrap(myFunctions.createSnapCircle);
        try {
          const {id} = await wrapped({name: "Test Circle", description: ""}, {auth: {uid: "xyz12345abc", token: {}}});
          testCircleId = id;
          await wrapped(
            {name: "Test Circle", description: "", previousCircle: testCircleId},
            {auth: {uid: "abcdefg123", token: {roles: ["keeper"]}}}
          );
          assert.fail("should have thrown error");
        } catch (e) {
          const ex: https.HttpsError = e as https.HttpsError;
          assert.equal(ex.code, "permission-denied");
          assert.equal(ex.message, "You are not the keeper of this circle");
        }
      });
      it("should create a default public circle without restrictions", async function () {
        const wrapped = test.wrap(myFunctions.createSnapCircle);
        const {id} = await wrapped(
          {name: "Test Circle", description: "Test"},
          {auth: {uid: "abcdefg123", token: {roles: ["keeper"]}}}
        );
        testCircleId = id;
        assert.isString(testCircleId, `circleId is ${testCircleId}`);
        const ref = admin.firestore().collection("snapCircles").doc(testCircleId);
        const doc = await ref.get();
        assert.isTrue(doc.exists, "circle document exists");
        const {isPrivate, maxMinutes, maxParticipants, state} = doc.data() as SnapCircleData;
        assert.equal(state, SessionState.waiting, "state is waiting");
        assert.isFalse(isPrivate, "circle is public");
        assert.isUndefined(maxMinutes, "circle has no time liimit");
        assert.isUndefined(maxParticipants, "circle has np participant limit");
      });
      it("should allow setting restructions", async function () {
        const wrapped = test.wrap(myFunctions.createSnapCircle);
        const {id} = await wrapped(
          {name: "Test Circle", description: "Test", options: {isPrivate: true, maxMinutes: 120, maxParticipants: 15}},
          {auth: {uid: "abcdefg123", token: {roles: ["keeper"]}}}
        );
        testCircleId = id;
        const ref = admin.firestore().collection("snapCircles").doc(testCircleId);
        const doc = await ref.get();
        assert.isTrue(doc.exists, "circle document exists");
        const {isPrivate, maxMinutes, maxParticipants} = doc.data() as SnapCircleData;
        assert.isTrue(isPrivate, "circle is private");
        assert.equal(maxMinutes, 120, "circle is max 120 minutes");
        assert.equal(maxParticipants, 15, "circle has max 15 participants");
      });
    });

    describe("recurring", function () {
      it("should not allowing recurring circle without instances", async function () {
        const wrapped = test.wrap(myFunctions.createSnapCircle);
        try {
          const {id} = await wrapped(
            {
              name: "Test Circle",
              description: "Test",
              options: {isPrivate: false, recurringType: RecurringType.instances},
            },
            {auth: {uid: "abcdefg123", token: {roles: ["keeper"]}}}
          );
          testCircleId = id;
          assert.fail("should have thrown error");
        } catch (e) {
          const ex: https.HttpsError = e as https.HttpsError;
          assert.equal(ex.code, "invalid-argument");
          assert.equal(ex.message, "Missing instances for recurring circle");
        }
      });
      it("should not allow recurring circle without at least one instance", async function () {
        const wrapped = test.wrap(myFunctions.createSnapCircle);
        try {
          const {id} = await wrapped(
            {
              name: "Test Circle",
              description: "Test",
              options: {isPrivate: false, recurringType: RecurringType.instances, instances: []},
            },
            {auth: {uid: "abcdefg123", token: {roles: ["keeper"]}}}
          );
          testCircleId = id;
          assert.fail("should have thrown error");
        } catch (e) {
          const ex: https.HttpsError = e as https.HttpsError;
          assert.equal(ex.code, "invalid-argument");
          assert.equal(ex.message, "Must have at least one instance for recurring circle");
        }
      });
      it("should not allow recurring circle with instance in the past", async function () {
        const wrapped = test.wrap(myFunctions.createSnapCircle);
        try {
          const {id} = await wrapped(
            {
              name: "Test Circle",
              description: "Test",
              options: {isPrivate: false, recurringType: RecurringType.instances, instances: [Timestamp.now()]},
            },
            {auth: {uid: "abcdefg123", token: {roles: ["keeper"]}}}
          );
          testCircleId = id;
          assert.fail("should have thrown error");
        } catch (e) {
          const ex: https.HttpsError = e as https.HttpsError;
          assert.equal(ex.code, "invalid-argument");
          assert.equal(ex.message, "First instance must be in the future");
        }
      });
      it("should not allow recurring circle with instances that aren't in ascending order", async function () {
        const wrapped = test.wrap(myFunctions.createSnapCircle);
        try {
          const baseTime = new Date();
          const first = Timestamp.fromDate(add(baseTime, {days: 1}));
          const second = Timestamp.fromDate(add(baseTime, {days: 2}));
          const third = Timestamp.fromDate(add(baseTime, {days: 3}));
          const {id} = await wrapped(
            {
              name: "Test Circle",
              description: "Test",
              options: {isPrivate: false, recurringType: RecurringType.instances, instances: [first, third, second]},
            },
            {auth: {uid: "abcdefg123", token: {roles: ["keeper"]}}}
          );
          testCircleId = id;
          assert.fail("should have thrown error");
        } catch (e) {
          const ex: https.HttpsError = e as https.HttpsError;
          assert.equal(ex.code, "invalid-argument");
          assert.equal(ex.message, "Instances must be in ascending time order");
        }
      });
      it("should create recurring circle with supplied instances", async function () {
        const wrapped = test.wrap(myFunctions.createSnapCircle);
        const baseTime = new Date();
        const first = Timestamp.fromDate(add(baseTime, {days: 2}));
        const second = Timestamp.fromDate(add(baseTime, {days: 9}));
        const third = Timestamp.fromDate(add(baseTime, {days: 16}));
        const {id} = await wrapped(
          {
            name: "Test Circle",
            description: "Test",
            options: {isPrivate: false, recurringType: RecurringType.instances, instances: [first, second, third]},
          },
          {auth: {uid: "abcdefg123", token: {roles: ["keeper"]}}}
        );
        testCircleId = id;
        const ref = admin.firestore().collection("snapCircles").doc(testCircleId);
        const doc = await ref.get();
        assert.isTrue(doc.exists, "circle document exists");
        const {scheduledSessions, nextSession, state} = doc.data() as SnapCircleData;
        assert.equal(state, SessionState.scheduled, "state is scheduled");
        assert.isTrue(nextSession?.isEqual(first), "next session is first instance");
        assert.equal(scheduledSessions?.length, 2, "2 more scheduled sessions");
        const [test0, test1] = scheduledSessions || [];
        assert.isTrue(test0.isEqual(second), "next session is first instance");
        assert.isTrue(test1.isEqual(third), "next session is first instance");
      });
    });

    describe("repeating", function () {
      it("should not allowing repeating circle without options", async function () {
        const wrapped = test.wrap(myFunctions.createSnapCircle);
        try {
          const {id} = await wrapped(
            {
              name: "Test Circle",
              description: "Test",
              options: {isPrivate: false, recurringType: RecurringType.repeating},
            },
            {auth: {uid: "abcdefg123", token: {roles: ["keeper"]}}}
          );
          testCircleId = id;
          assert.fail("should have thrown error");
        } catch (e) {
          const ex: https.HttpsError = e as https.HttpsError;
          assert.equal(ex.code, "invalid-argument");
          assert.equal(ex.message, "Missing repeat options for repeating circle");
        }
      });
      it("should not allowing repeating circle without start date", async function () {
        const wrapped = test.wrap(myFunctions.createSnapCircle);
        try {
          const {id} = await wrapped(
            {
              name: "Test Circle",
              description: "Test",
              options: {isPrivate: false, recurringType: RecurringType.repeating, repeating: {}},
            },
            {auth: {uid: "abcdefg123", token: {roles: ["keeper"]}}}
          );
          testCircleId = id;
          assert.fail("should have thrown error");
        } catch (e) {
          const ex: https.HttpsError = e as https.HttpsError;
          assert.equal(ex.code, "invalid-argument");
          assert.equal(ex.message, "Must have a start date for a repeating circle");
        }
      });
      it("should not allowing repeating circle start date in the past", async function () {
        const wrapped = test.wrap(myFunctions.createSnapCircle);
        try {
          const now = Timestamp.now();
          const {id} = await wrapped(
            {
              name: "Test Circle",
              description: "Test",
              options: {isPrivate: false, recurringType: RecurringType.repeating, repeating: {start: now}},
            },
            {auth: {uid: "abcdefg123", token: {roles: ["keeper"]}}}
          );
          testCircleId = id;
          assert.fail("should have thrown error");
        } catch (e) {
          const ex: https.HttpsError = e as https.HttpsError;
          assert.equal(ex.code, "invalid-argument");
          assert.equal(ex.message, "Start date must be in the future for repeating circle");
        }
      });
      it("should not allowing repeating circle without an interval", async function () {
        const wrapped = test.wrap(myFunctions.createSnapCircle);
        try {
          const start = Timestamp.fromDate(add(new Date(), {days: 1}));
          const {id} = await wrapped(
            {
              name: "Test Circle",
              description: "Test",
              options: {isPrivate: false, recurringType: RecurringType.repeating, repeating: {start}},
            },
            {auth: {uid: "abcdefg123", token: {roles: ["keeper"]}}}
          );
          testCircleId = id;
          assert.fail("should have thrown error");
        } catch (e) {
          const ex: https.HttpsError = e as https.HttpsError;
          assert.equal(ex.code, "invalid-argument");
          assert.equal(ex.message, "Must have a repeat interval for a repeating circle");
        }
      });
      it("should not allowing repeating circle without a time unit", async function () {
        const wrapped = test.wrap(myFunctions.createSnapCircle);
        try {
          const start = Timestamp.fromDate(add(new Date(), {days: 1}));
          const every = 2;
          const {id} = await wrapped(
            {
              name: "Test Circle",
              description: "Test",
              options: {isPrivate: false, recurringType: RecurringType.repeating, repeating: {start, every}},
            },
            {auth: {uid: "abcdefg123", token: {roles: ["keeper"]}}}
          );
          testCircleId = id;
          assert.fail("should have thrown error");
        } catch (e) {
          const ex: https.HttpsError = e as https.HttpsError;
          assert.equal(ex.code, "invalid-argument");
          assert.equal(ex.message, "Must have a time unit for a repeating circle");
        }
      });
      it("should not allowing repeating circle without an end date or count", async function () {
        const wrapped = test.wrap(myFunctions.createSnapCircle);
        try {
          const start = Timestamp.fromDate(add(new Date(), {days: 1}));
          const every = 2;
          const unit = RepeatUnit.weeks;
          const {id} = await wrapped(
            {
              name: "Test Circle",
              description: "Test",
              options: {isPrivate: false, recurringType: RecurringType.repeating, repeating: {start, every, unit}},
            },
            {auth: {uid: "abcdefg123", token: {roles: ["keeper"]}}}
          );
          testCircleId = id;
          assert.fail("should have thrown error");
        } catch (e) {
          const ex: https.HttpsError = e as https.HttpsError;
          assert.equal(ex.code, "invalid-argument");
          assert.equal(ex.message, "Must have either an end date or a session count for a repeating circle");
        }
      });
      it("should not allowing repeating circle without an end date before or equal to start", async function () {
        const wrapped = test.wrap(myFunctions.createSnapCircle);
        try {
          const start = Timestamp.fromDate(add(new Date(), {days: 1}));
          const every = 2;
          const unit = RepeatUnit.weeks;
          const {id} = await wrapped(
            {
              name: "Test Circle",
              description: "Test",
              options: {
                isPrivate: false,
                recurringType: RecurringType.repeating,
                repeating: {start, every, unit, until: start},
              },
            },
            {auth: {uid: "abcdefg123", token: {roles: ["keeper"]}}}
          );
          testCircleId = id;
          assert.fail("should have thrown error");
        } catch (e) {
          const ex: https.HttpsError = e as https.HttpsError;
          assert.equal(ex.code, "invalid-argument");
          assert.equal(ex.message, "End date for repeating circle must after the start");
        }
      });
      it("should create 3 instances with 2 week intervals", async function () {
        const wrapped = test.wrap(myFunctions.createSnapCircle);
        const start = Timestamp.fromDate(add(new Date(), {days: 1}));
        const every = 2;
        const unit = RepeatUnit.weeks;
        const count = 2;
        const second = Timestamp.fromDate(add(start.toDate(), {weeks: every}));
        const third = Timestamp.fromDate(add(start.toDate(), {weeks: count * every}));
        const {id} = await wrapped(
          {
            name: "Test Circle",
            description: "Test",
            options: {
              isPrivate: false,
              recurringType: RecurringType.repeating,
              repeating: {start, every, unit, count},
            },
          },
          {auth: {uid: "abcdefg123", token: {roles: ["keeper"]}}}
        );
        testCircleId = id;
        const ref = admin.firestore().collection("snapCircles").doc(testCircleId);
        const doc = await ref.get();
        assert.isTrue(doc.exists, "circle document exists");
        const {scheduledSessions, nextSession, state} = doc.data() as SnapCircleData;
        assert.equal(state, SessionState.scheduled, "state is scheduled");
        assert.isTrue(nextSession?.isEqual(start), "next session is on the start date");
        assert.equal(scheduledSessions?.length, 2, "2 more scheduled sessions");
        const [test0, test1] = scheduledSessions || [];
        assert.isTrue(test0.isEqual(second), "second session is 2 weeks after start");
        assert.isTrue(test1.isEqual(third), "third session is 4 weeks after start");
      });
      it("should create 3 instances with 1 week intervals", async function () {
        const wrapped = test.wrap(myFunctions.createSnapCircle);
        const start = Timestamp.fromDate(add(new Date(), {days: 1}));
        const every = 1;
        const unit = RepeatUnit.weeks;
        const second = Timestamp.fromDate(add(start.toDate(), {weeks: every}));
        const third = Timestamp.fromDate(add(start.toDate(), {weeks: 2 * every}));
        const until = third;
        const {id} = await wrapped(
          {
            name: "Test Circle",
            description: "Test",
            options: {
              isPrivate: false,
              recurringType: RecurringType.repeating,
              repeating: {start, every, unit, until},
            },
          },
          {auth: {uid: "abcdefg123", token: {roles: ["keeper"]}}}
        );
        testCircleId = id;
        const ref = admin.firestore().collection("snapCircles").doc(testCircleId);
        const doc = await ref.get();
        assert.isTrue(doc.exists, "circle document exists");
        const {scheduledSessions, nextSession, state} = doc.data() as SnapCircleData;
        assert.equal(state, SessionState.scheduled, "state is scheduled");
        assert.isTrue(nextSession?.isEqual(start), "next session is on the start date");
        assert.equal(scheduledSessions?.length, 2, "2 more scheduled sessions");
        const [test0, test1] = scheduledSessions || [];
        assert.isTrue(test0.isEqual(second), "second session is 1 weeks after start");
        assert.isTrue(test1.isEqual(third), "third session is 2 weeks after start");
      });
    });
  });
});
