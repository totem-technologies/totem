import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/circles_provider.dart';
import 'package:totem/services/firebase_providers/paths.dart';
import 'package:totem/services/index.dart';

class FirebaseCirclesProvider extends CirclesProvider {
  @override
  Stream<List<ScheduledCircle>> scheduledCircles(String? uid) {
    if (uid != null) {
      // get circles for use
      final userCollection = FirebaseFirestore.instance
          .collection(Paths.users)
          .doc(uid)
          .collection(Paths.circles);
      return userCollection
          .snapshots()
          .asyncMap((snapshot) => _getCirclesFromSnapshot(snapshot, uid))
          .transform(StreamTransformer<List<ScheduledCircle>,
                  List<ScheduledCircle>>.fromHandlers(
              handleData: (inList, EventSink<List<ScheduledCircle>> sink) {
        inList.sort((circle1, circle2) {
          if (circle1.nextSession != null && circle2.nextSession != null) {
            return circle1.nextSession!.scheduledDate
                .compareTo(circle2.nextSession!.scheduledDate);
          } else if (circle1.nextSession != null) {
            return -1;
          } else if (circle2.nextSession != null) {
            return 1;
          }
          return 0;
        });
        sink.add(inList);
      }));
    } else {
      final collection = FirebaseFirestore.instance.collection(Paths.circles);
      return collection.snapshots().transform(StreamTransformer<
              QuerySnapshot<Map<String, dynamic>>,
              List<ScheduledCircle>>.fromHandlers(
          handleData: (QuerySnapshot<Map<String, dynamic>> querySnapshot,
              EventSink<List<ScheduledCircle>> sink) {
        _mapScheduledCircleUserReference(querySnapshot, sink);
      }));
    }
  }

  @override
  Stream<List<SnapCircle>> snapCircles() {
    final collection = FirebaseFirestore.instance.collection(Paths.snapCircles);
    return collection
        .where('state', isEqualTo: SessionState.waiting.name)
        .snapshots()
        .transform(
      StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
          List<SnapCircle>>.fromHandlers(
        handleData: (QuerySnapshot<Map<String, dynamic>> querySnapshot,
            EventSink<List<SnapCircle>> sink) {
          _mapSnapCircleUserReference(querySnapshot, sink);
        },
      ),
    );
  }

  @override
  Stream<List<SnapCircle>> rejoinableSnapCircles(String uid) {
    final collection = FirebaseFirestore.instance.collection(Paths.snapCircles);
    return collection
        .where('state', isEqualTo: SessionState.live.name)
        .where('circleParticipants', arrayContains: uid)
        .orderBy('startedDate', descending: true)
        .limit(1)
        .snapshots()
        .transform(
      StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
          List<SnapCircle>>.fromHandlers(
        handleData: (QuerySnapshot<Map<String, dynamic>> querySnapshot,
            EventSink<List<SnapCircle>> sink) {
          _mapSnapCircleUserReference(querySnapshot, sink);
        },
      ),
    );
  }

  @override
  Future<ScheduledCircle?> createScheduledCircle({
    required String name,
    required int numSessions,
    required DateTime startDate,
    required DateTime startTime,
    required List<int> daysOfTheWeek,
    required String uid,
    String? description,
    required bool addAsMember,
  }) async {
    final DocumentReference userRef =
        FirebaseFirestore.instance.collection(Paths.users).doc(uid);
    final DateTime now = DateTime.now();
    Map<String, dynamic> data = {
      "name": name,
      "createdOn": now,
      "updatedOn": now,
      "createdBy": userRef,
      "numSessions": numSessions,
    };
    if (description != null) {
      data["description"] = description;
    }
    try {
      DocumentReference ref =
          await FirebaseFirestore.instance.collection(Paths.circles).add(data);
      await _generateSessions(
          startDate, startTime, numSessions, daysOfTheWeek, ref);
      // add to users circle
      if (addAsMember) {
        await addUserToCircle(Paths.circles,
            id: ref.id, uid: uid, role: Role.keeper);
      }
      // return circle
      ScheduledCircle circle =
          ScheduledCircle.fromJson(data, id: ref.id, ref: ref.path);
      return circle;
    } catch (e) {
      // TODO: throw specific exception here
      debugPrint(e.toString());
    }
    return null;
  }

  @override
  Future<SnapCircle?> createSnapCircle({
    required String name,
    required String uid,
    String? description,
    String? keeper,
    String? previousCircle,
    List<String>? removedParticipants,
  }) async {
    final DocumentReference userRef =
        FirebaseFirestore.instance.collection(Paths.users).doc(keeper ?? uid);
    try {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('createSnapCircle');
      final data = <String, dynamic>{
        "name": name,
      };
      if (description != null) {
        data["description"] = description;
      }
      if (keeper != null) {
        data["keeper"] = keeper;
      }
      if (previousCircle != null) {
        data['previousCircle'] = previousCircle;
      }
      if (removedParticipants != null) {
        data['removedParticipants'] = removedParticipants;
      }
      final result = await callable(data);
      final String id = result.data['id'];
      debugPrint('completed startSnapSession with result $id');
      DocumentReference ref =
          FirebaseFirestore.instance.collection(Paths.snapCircles).doc(id);
      DocumentSnapshot circleSnapshot = await ref.get();
      if (circleSnapshot.exists) {
        SnapCircle circle = SnapCircle.fromJson(
          circleSnapshot.data() as Map<String, dynamic>,
          id: ref.id,
          ref: ref.path,
        );
        circle.createdBy = await _userFromRef(userRef);
        return circle;
      }
    } on FirebaseException catch (e) {
      // TODO: throw specific exception here
      throw (ServiceException(code: e.code, message: e.message));
    } catch (e) {
      throw (ServiceException(
          code: ServiceException.errorCodeUnknown, message: e.toString()));
    }
    return null;
  }

  @override
  Stream<ScheduledCircle> scheduledCircle(String circleId, String uid) {
    return FirebaseFirestore.instance
        .collection(Paths.circles)
        .doc(circleId)
        .snapshots()
        .transform(
      StreamTransformer<DocumentSnapshot<Map<String, dynamic>>,
          ScheduledCircle>.fromHandlers(
        handleData: (DocumentSnapshot<Map<String, dynamic>> docSnapshot,
            EventSink<ScheduledCircle> sink) async {
          ScheduledCircle circle =
              await _getScheduledCircleFromSnapshot(docSnapshot, uid: uid);
          sink.add(circle);
        },
      ),
    );
  }

  Future<bool> addUserToCircle(String path,
      {required String id,
      required String uid,
      Role role = Role.member}) async {
    try {
      DocumentReference circleRef =
          FirebaseFirestore.instance.collection(path).doc(id);
      DocumentSnapshot circleSnapshot = await circleRef.get();
      if (circleSnapshot.exists) {
        DocumentReference userRef =
            FirebaseFirestore.instance.collection(Paths.users).doc(uid);
        final joined = DateTime.now();
        final circleData = {
          "role": role.name,
          "joined": joined,
          "ref": userRef,
        };
        // Update the members list for the circle
        Map<String, dynamic> circle =
            circleSnapshot.data() as Map<String, dynamic>;
        List<dynamic>? participants = circle["participants"];
        if (participants == null) {
          participants = [circleData];
        } else {
          participants.add(circleData);
        }
        await circleRef.update({"participants": participants});
        // Update the user reference to the circle
        final userCircleData = {
          "role": role.name,
          "joined": joined,
          "ref": circleRef
        };
        await FirebaseFirestore.instance
            .collection(Paths.users)
            .doc(uid)
            .collection(path)
            .add(userCircleData);
        return true;
      }
    } catch (ex) {
      debugPrint('Unable to add user to collection: $ex');
    }
    return false;
  }

  Future<ScheduledCircle> _getScheduledCircleFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> circleSnapshot,
      {bool resolveUsers = true,
      bool resolveAllSessions = true,
      String? uid}) async {
    // Resolve all the session data and user details for a circle
    Map<String, dynamic> circleData =
        circleSnapshot.data() as Map<String, dynamic>;
    final circle = ScheduledCircle.fromJson(circleData,
        id: circleSnapshot.id, ref: circleSnapshot.reference.path);
    // Check for the active session
    /* FIXME - SCHEDULE SESSION
    String? activeSessionId;
    if (circleData["activeSession"] != null) {
      activeSessionId = (circleData["activeSession"] as DocumentReference).id;
    } */
    // resolve users participating in the circle
    if (resolveUsers && circleData['participants'] != null) {
      final List<Map<String, dynamic>> participantsRef =
          List<Map<String, dynamic>>.from(circleData['participants']);
      final participants =
          await Future.wait(participantsRef.map((participantRef) async {
        DocumentReference ref = participantRef['ref'];
        DocumentSnapshot doc = await ref.get();
        return Participant.fromJson(participantRef,
            userProfile: UserProfile.fromJson(
              doc.data() as Map<String, dynamic>,
              uid: doc.id,
              ref: doc.reference.path,
            ),
            me: doc.id == uid);
      }).toList());
      circle.participants = participants;
    }
    DateTime now = DateTime.now();
    // resolve sessions for the circle
    var query = FirebaseFirestore.instance
        .collection(Paths.circles)
        .doc(circleSnapshot.id)
        .collection(Paths.scheduledSessions)
        .orderBy("scheduledDate")
        .where("scheduledDate", isGreaterThanOrEqualTo: now);
    if (!resolveAllSessions) {
      query.limit(1);
    }
    QuerySnapshot<Map<String, dynamic>> result = await query.get();
    if (result.docs.isNotEmpty) {
      List<ScheduledSession> sessions = result.docs.map((session) {
        ScheduledSession sessionItem = ScheduledSession.fromJson(session.data(),
            id: session.id, ref: session.reference.path, circle: circle);
        /* TODO - SCHEDULED SESSION
        if (sessionItem.id == activeSessionId) {
          circle.activeSession = sessionItem;
        } */
        return sessionItem;
      }).toList();
      sessions.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
      circle.sessions = sessions;
    }
    return circle;
  }

  Future<List<ScheduledCircle>> _getCirclesFromSnapshot(
      QuerySnapshot circleSnapshot, String uid) {
    // Maps from User's list of circles to global circle reference
    return Future.wait(
        circleSnapshot.docs.map((DocumentSnapshot circleDoc) async {
      Map<String, dynamic> data = circleDoc.data() as Map<String, dynamic>;
      DocumentReference ref = data["ref"];
      DocumentSnapshot<Map<String, dynamic>> circleSnapshot =
          await ref.get() as DocumentSnapshot<Map<String, dynamic>>;
      return await _getScheduledCircleFromSnapshot(circleSnapshot,
          resolveAllSessions: false, resolveUsers: false, uid: uid);
    }).toList());
  }

  void _mapScheduledCircleUserReference(
      QuerySnapshot<Map<String, dynamic>> querySnapshot, EventSink sink) async {
    List<ScheduledCircle> circles = [];
    for (DocumentSnapshot document in querySnapshot.docs) {
      try {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        ScheduledCircle circle = ScheduledCircle.fromJson(data,
            id: document.id, ref: document.reference.path);
        DocumentReference ref = data["createdBy"] as DocumentReference;
        circle.createdBy = await _userFromRef(ref);
        circles.add(circle);
      } catch (ex) {
        debugPrint(ex.toString());
      }
    }
    sink.add(circles);
  }

  void _mapSnapCircleUserReference(
      QuerySnapshot<Map<String, dynamic>> querySnapshot, EventSink sink) async {
    List<SnapCircle> circles = [];
    for (DocumentSnapshot document in querySnapshot.docs) {
      try {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        SnapCircle circle = SnapCircle.fromJson(data,
            id: document.id, ref: document.reference.path);
        DocumentReference ref = data["createdBy"] as DocumentReference;
        circle.createdBy = await _userFromRef(ref);
        if (data['activeSession'] != null) {
          SnapSession.fromJson(data['activeSession'], circle: circle);
        }
        circles.add(circle);
      } catch (ex) {
        debugPrint(ex.toString());
      }
    }
    sink.add(circles);
  }

  Future<UserProfile?> _userFromRef(DocumentReference ref) async {
    DocumentSnapshot userData = await ref.get();
    if (userData.exists) {
      UserProfile user = UserProfile.fromJson(
        userData.data() as Map<String, dynamic>,
        uid: userData.id,
        ref: userData.reference.path,
      );
      return user;
    }
    return null;
  }

  Future<List<DocumentReference>> _generateSessions(
      DateTime startsOn,
      DateTime startTime,
      int numSessions,
      List<int> daysOfTheWeek,
      DocumentReference circleRef) async {
    daysOfTheWeek.sort((a, b) => a.compareTo(b));
    int nextDay = 0;
    List<DocumentReference> sessions = [];
    DateTime nextTime =
        DateTime(startsOn.year, startsOn.month, startsOn.day, 12, 0, 0);
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (int i = 0; i < numSessions; i++) {
      try {
        int dayOfWeek = daysOfTheWeek[nextDay];
        if (nextDay < daysOfTheWeek.length - 1) {
          nextDay++;
        } else {
          nextDay = 0;
        }
        if (nextTime.weekday < dayOfWeek) {
          nextTime = nextTime.add(Duration(days: dayOfWeek - nextTime.weekday));
        } else if (nextTime.weekday > dayOfWeek) {
          nextTime =
              nextTime.add(Duration(days: 7 - (nextTime.weekday - dayOfWeek)));
        } else if (i > 0) {
          nextTime = nextTime.add(const Duration(days: 7));
        }
        // rebuild with time value as DST can change the time using duration addition of days
        Map<String, dynamic> session = {
          "scheduledDate": DateTime(nextTime.year, nextTime.month, nextTime.day,
              startTime.hour, startTime.minute),
        };
        DocumentReference ref =
            circleRef.collection(Paths.scheduledSessions).doc();
        batch.set(ref, session);
        sessions.add(ref);
      } catch (ex) {
        debugPrint("unable to create session: $ex");
      }
    }
    await batch.commit();
    return sessions;
  }

  @override
  Future<bool> removeSnapCircle(
      {required SnapCircle circle, required String uid}) async {
    try {
      final DocumentReference circleRef = FirebaseFirestore.instance
          .collection(Paths.snapCircles)
          .doc(circle.id);
      await circleRef.delete();
      final DocumentReference activeCircleRef = FirebaseFirestore.instance
          .collection(Paths.activeCircles)
          .doc(circle.id);
      await activeCircleRef.delete();
      return true;
    } catch (ex) {
      debugPrint(ex.toString());
    }
    return false;
  }

  @override
  Future<SnapCircle?> circleFromId(String id, String uid) async {
    try {
      final DocumentReference circleRef =
          FirebaseFirestore.instance.collection(Paths.snapCircles).doc(id);
      DocumentSnapshot circleSnapshot = await circleRef.get();
      Map<String, dynamic> data = circleSnapshot.data() as Map<String, dynamic>;
      SnapCircle circle =
          SnapCircle.fromJson(data, id: id, ref: circleRef.path, uid: uid);
      DocumentReference ref = data["createdBy"] as DocumentReference;
      circle.createdBy = await _userFromRef(ref);
      if (data['activeSession'] != null) {
        SnapSession.fromJson(data['activeSession'], circle: circle);
      }
      return circle;
    } catch (ex) {
      debugPrint(ex.toString());
    }
    return null;
  }

  @override
  Future<SnapCircle?> circleFromPreviousIdAndState(
      {required String previousId,
      required List<SessionState> state,
      required String uid}) async {
    try {
      final query = FirebaseFirestore.instance
          .collection(Paths.snapCircles)
          .where('previousCircle', isEqualTo: previousId)
          .where('state', whereIn: state.map((e) => e.name).toList())
          .orderBy('createdOn', descending: true)
          .limit(1);
      QuerySnapshot<Map<String, dynamic>> result = await query.get();
      if (result.docs.isNotEmpty) {
        QueryDocumentSnapshot<Map<String, dynamic>> snapshot = result.docs[0];
        SnapCircle snapCircle = SnapCircle.fromJson(snapshot.data(),
            id: snapshot.id, ref: snapshot.reference.path);
        return snapCircle;
      }
    } catch (ex) {
      debugPrint(ex.toString());
    }
    return null;
  }

  @override
  Future<SnapCircle?> circleFromPreviousIdAndNotState(
      {required String previousId,
      required List<SessionState> state,
      required String uid}) async {
    try {
      final query = FirebaseFirestore.instance
          .collection(Paths.snapCircles)
          .where('previousCircle', isEqualTo: previousId)
          .where('state', whereNotIn: state.map((e) => e.name).toList())
          .orderBy('createdOn', descending: true)
          .limit(1);
      QuerySnapshot<Map<String, dynamic>> result = await query.get();
      if (result.docs.isNotEmpty) {
        QueryDocumentSnapshot<Map<String, dynamic>> snapshot = result.docs[0];
        SnapCircle snapCircle = SnapCircle.fromJson(snapshot.data(),
            id: snapshot.id, ref: snapshot.reference.path);
        return snapCircle;
      }
    } catch (ex) {
      debugPrint(ex.toString());
    }
    return null;
  }

  @override
  Future<bool> canJoinCircle(
      {required String circleId, required String uid}) async {
    try {
      final query = FirebaseFirestore.instance
          .collection(Paths.snapCircles)
          .where('previousCircle', isEqualTo: circleId)
          .orderBy('createdOn', descending: true)
          .limit(1);
      QuerySnapshot<Map<String, dynamic>> result = await query.get();
      if (result.docs.isNotEmpty) {
        QueryDocumentSnapshot<Map<String, dynamic>> snapshot = result.docs[0];
        List<String> removedParticipants = List<String>.from(
            snapshot.data()['removedParticipants'] as List? ?? []);
        if (removedParticipants.contains(uid)) {
          return false;
        }
      }
    } catch (ex) {
      debugPrint(ex.toString());
    }
    return true;
  }
}
