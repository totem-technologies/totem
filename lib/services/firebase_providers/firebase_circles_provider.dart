import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/firebase_providers/paths.dart';
import 'package:totem/services/circles_provider.dart';

class FirebaseCirclesProvider extends CirclesProvider {
  @override
  Stream<List<Circle>> circles(String? uid) {
    if (uid != null) {
      // get circles for use
      final userCollection = FirebaseFirestore.instance
          .collection(Paths.users)
          .doc(uid)
          .collection(Paths.circles);
      return userCollection
          .snapshots()
          .asyncMap((snapshot) => _getCirclesFromSnapshot(snapshot))
          .transform(StreamTransformer<List<Circle>, List<Circle>>.fromHandlers(
              handleData: (inList, EventSink<List<Circle>> sink) {
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
              QuerySnapshot<Map<String, dynamic>>, List<Circle>>.fromHandlers(
          handleData: (QuerySnapshot<Map<String, dynamic>> querySnapshot,
              EventSink<List<Circle>> sink) {
        _mapUserReference(querySnapshot, sink);
      }));
    }
  }

  @override
  Future<Circle?> createCircle({
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
        await addUserToCircle(id: ref.id, uid: uid, role: Roles.keeper);
      }
      // return circle
      Circle circle = Circle.fromJson(data, id: ref.id, ref: ref.path);
      return circle;
    } catch (e) {
      // TODO: throw specific exception here
      debugPrint(e.toString());
    }
    return null;
  }

  @override
  Stream<Circle> circle(String circleId) {
    return FirebaseFirestore.instance
        .collection(Paths.circles)
        .doc(circleId)
        .snapshots()
        .transform(StreamTransformer<DocumentSnapshot<Map<String, dynamic>>,
                Circle>.fromHandlers(
            handleData: (DocumentSnapshot<Map<String, dynamic>> docSnapshot,
                EventSink<Circle> sink) async {
      Circle circle = await _getCircleFromSnapshot(docSnapshot);
      sink.add(circle);
    }));
  }

  Future<bool> addUserToCircle(
      {required String id,
      required String uid,
      Role role = Roles.member}) async {
    try {
      DocumentReference circleRef =
          FirebaseFirestore.instance.collection(Paths.circles).doc(id);
      DocumentSnapshot circleSnapshot = await circleRef.get();
      if (circleSnapshot.exists) {
        DocumentReference userRef =
            FirebaseFirestore.instance.collection(Paths.users).doc(uid);
        final joined = DateTime.now();
        final circleData = {
          "role": role.toString(),
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
        circleRef.update({"participants": participants});
        // Update the user reference to the circle
        final userCircleData = {
          "role": role.toString(),
          "joined": joined,
          "ref": circleRef
        };
        await FirebaseFirestore.instance
            .collection(Paths.users)
            .doc(uid)
            .collection(Paths.circles)
            .add(userCircleData);
        return true;
      }
    } catch (ex) {
      debugPrint('Unable to add user to collection: ' + ex.toString());
    }
    return false;
  }

  Future<Circle> _getCircleFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> circleSnapshot,
      {bool resolveUsers = true,
      bool resolveAllSessions = true}) async {
    // Resolve all the session data and user details for a circle
    Map<String, dynamic> circleData =
        circleSnapshot.data() as Map<String, dynamic>;
    final circle = Circle.fromJson(circleData,
        id: circleSnapshot.id, ref: circleSnapshot.reference.path);
    // Check for the active session
    String? activeSessionId;
    if (circleData["activeSession"] != null) {
      activeSessionId = (circleData["activeSession"] as DocumentReference).id;
    }
    // resolve users participating in the circle
    if (resolveUsers && circleData['participants'] != null) {
      final List<Map<String, dynamic>>? participantsRef =
          List<Map<String, dynamic>>.from(circleData['participants']);
      if (participantsRef != null) {
        final participants =
            await Future.wait(participantsRef.map((participantRef) async {
          DocumentReference ref = participantRef['ref'];
          DocumentSnapshot doc = await ref.get();
          return Participant.fromJson(
            participantRef,
            userProfile: UserProfile.fromJson(
              doc.data() as Map<String, dynamic>,
              uid: doc.id,
              ref: doc.reference.path,
            ),
          );
        }).toList());
        circle.participants = participants;
      }
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
      List<Session> sessions = result.docs.map((session) {
        Session sessionItem = Session.fromJson(session.data(),
            id: session.id, ref: session.reference.path, circle: circle);
        if (sessionItem.id == activeSessionId) {
          circle.activeSession = sessionItem;
        }
        return sessionItem;
      }).toList();
      sessions.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
      circle.sessions = sessions;
    }
    return circle;
  }

  Future<List<Circle>> _getCirclesFromSnapshot(QuerySnapshot circleSnapshot) {
    // Maps from User's list of circles to global circle reference
    return Future.wait(
        circleSnapshot.docs.map((DocumentSnapshot circleDoc) async {
      Map<String, dynamic> data = circleDoc.data() as Map<String, dynamic>;
      DocumentReference ref = data["ref"];
      DocumentSnapshot<Map<String, dynamic>> circleSnapshot =
          await ref.get() as DocumentSnapshot<Map<String, dynamic>>;
      return await _getCircleFromSnapshot(circleSnapshot,
          resolveAllSessions: false, resolveUsers: false);
    }).toList());
  }

  void _mapUserReference(
      QuerySnapshot<Map<String, dynamic>> querySnapshot, EventSink sink) async {
    List<Circle> circles = [];
    for (DocumentSnapshot document in querySnapshot.docs) {
      try {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        Circle circle = Circle.fromJson(data,
            id: document.id, ref: document.reference.path);
        DocumentReference ref = data["createdBy"] as DocumentReference;
        DocumentSnapshot userData = await ref.get();
        if (userData.exists) {
          UserProfile user = UserProfile.fromJson(
            userData.data() as Map<String, dynamic>,
            uid: userData.id,
            ref: userData.reference.path,
          );
          circle.createdBy = user;
        }
        circles.add(circle);
      } catch (ex) {
        debugPrint(ex.toString());
      }
    }
    sink.add(circles);
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
        debugPrint("unable to create session: " + ex.toString());
      }
    }
    await batch.commit();
    return sessions;
  }
}
