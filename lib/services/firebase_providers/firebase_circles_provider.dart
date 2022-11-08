import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/circles_provider.dart';
import 'package:totem/services/error_report.dart';
import 'package:totem/services/firebase_providers/paths.dart';
import 'package:totem/services/index.dart';

class FirebaseCirclesProvider extends CirclesProvider {
  @override
  Stream<List<Circle>> circles() {
    final collection = FirebaseFirestore.instance.collection(Paths.snapCircles);
    return collection
        .where('state', isEqualTo: SessionState.waiting.name)
        .where('isPrivate', isEqualTo: false)
        .snapshots()
        .transform(
      StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
          List<Circle>>.fromHandlers(
        handleData: (QuerySnapshot<Map<String, dynamic>> querySnapshot,
            EventSink<List<Circle>> sink) {
          _mapCircleUserReference(querySnapshot, sink);
        },
      ),
    );
  }

  @override
  Stream<List<Circle>> rejoinableCircles(String uid) {
    final collection = FirebaseFirestore.instance.collection(Paths.snapCircles);
    return collection
        .where('state', isEqualTo: SessionState.live.name)
        .where('circleParticipants', arrayContains: uid)
        .orderBy('startedDate', descending: true)
        .limit(1)
        .snapshots()
        .transform(
      StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
          List<Circle>>.fromHandlers(
        handleData: (QuerySnapshot<Map<String, dynamic>> querySnapshot,
            EventSink<List<Circle>> sink) {
          _mapCircleUserReference(querySnapshot, sink);
        },
      ),
    );
  }

  @override
  Stream<List<Circle>> myCircles(String uid,
      {bool privateOnly = true, bool activeOnly = true}) {
    final collection = FirebaseFirestore.instance.collection(Paths.snapCircles);
    Query query = collection.where('keeper', isEqualTo: uid);
    if (privateOnly) {
      query = query.where('isPrivate', isEqualTo: true);
    }
    if (activeOnly) {
      query = query.where('state', whereIn: [
        SessionState.waiting.name,
        SessionState.starting.name,
        SessionState.live.name,
      ]);
    }
    return query.snapshots().transform(
      StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
          List<Circle>>.fromHandlers(
        handleData: (QuerySnapshot<Map<String, dynamic>> querySnapshot,
            EventSink<List<Circle>> sink) {
          _mapCircleUserReference(querySnapshot, sink);
        },
      ),
    );
  }

  @override
  Stream<Circle?> circleStream(String circleId) {
    final circle =
        FirebaseFirestore.instance.collection(Paths.snapCircles).doc(circleId);
    return circle.snapshots().transform(
      StreamTransformer<DocumentSnapshot<Map<String, dynamic>>,
          Circle?>.fromHandlers(
        handleData: (DocumentSnapshot<Map<String, dynamic>> documentSnapshot,
            EventSink<Circle?> sink) {
          _mapSingleCircleUserReference(documentSnapshot, sink);
        },
      ),
    );
  }

  @override
  Future<Circle?> createCircle({
    required String name,
    required String uid,
    String? description,
    String? keeper,
    String? previousCircle,
    Map<String, dynamic>? bannedParticipants,
    bool? isPrivate,
    int? duration,
    int? maxParticipants,
    String? themeRef,
    String? imageUrl,
    String? bannerUrl,
    RecurringType? recurringType,
    List<DateTime>? instances,
    RepeatOptions? repeatOptions,
  }) async {
    final DocumentReference userRef =
        FirebaseFirestore.instance.collection(Paths.users).doc(keeper ?? uid);
    try {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('createSnapCircle');
      final data = <String, dynamic>{
        "name": name,
      };
      final Map<String, dynamic> options = <String, dynamic>{};
      if (description != null) {
        data["description"] = description;
      }
      if (keeper != null) {
        data["keeper"] = keeper;
      }
      if (previousCircle != null) {
        data['previousCircle'] = previousCircle;
      }
      if (bannedParticipants != null) {
        data['bannedParticipants'] = bannedParticipants;
      }
      if (themeRef != null) {
        data["themeRef"] = themeRef;
      }
      if (imageUrl != null) {
        data["imageUrl"] = imageUrl;
      }
      if (bannerUrl != null) {
        data["bannerImageUrl"] = bannerUrl;
      }
      if (isPrivate != null) {
        options['isPrivate'] = isPrivate;
      }
      if (duration != null) {
        options['maxMinutes'] = duration;
      }
      if (maxParticipants != null) {
        options["maxParticipants"] = maxParticipants;
      }
      if (recurringType != null) {
        options["recurringType"] = recurringType.name;
      }
      if (instances != null) {
        options["instances"] =
            instances.map((e) => e.toUtc().toIso8601String()).toList();
      }
      if (repeatOptions != null) {
        final repeating = <String, dynamic>{};
        repeating['start'] = repeatOptions.start.toUtc().toIso8601String();
        repeating['every'] = repeatOptions.every;
        repeating['unit'] = repeatOptions.unit.name;
        if (repeatOptions.until != null) {
          repeating['until'] = repeatOptions.until!.toUtc().toIso8601String();
        }
        if (repeatOptions.count != null) {
          repeating['count'] = repeatOptions.count;
        }
        options['repeating'] = repeating;
      }
      if (options.isNotEmpty) {
        data["options"] = options;
      }
      final result = await callable(data);
      final String id = result.data['id'];
      debugPrint('completed startSnapSession with result $id');
      DocumentReference ref =
          FirebaseFirestore.instance.collection(Paths.snapCircles).doc(id);
      DocumentSnapshot circleSnapshot = await ref.get();
      if (circleSnapshot.exists) {
        Circle circle = Circle.fromJson(
          circleSnapshot.data() as Map<String, dynamic>,
          id: ref.id,
          ref: ref.path,
        );
        circle.createdBy = await _userFromRef(userRef);
        return circle;
      }
    } on FirebaseException catch (ex, stack) {
      // TODO: throw specific exception here
      await reportError(ex, stack);
      throw (ServiceException(code: ex.code, message: ex.message));
    } catch (ex, stack) {
      await reportError(ex, stack);
      throw (ServiceException(
          code: ServiceException.errorCodeUnknown, message: ex.toString()));
    }
    return null;
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
    } catch (ex, stack) {
      debugPrint('Unable to add user to collection: $ex');
      await reportError(ex, stack);
    }
    return false;
  }

  void _mapCircleUserReference(
      QuerySnapshot<Map<String, dynamic>> querySnapshot, EventSink sink) async {
    List<Circle> circles = [];
    for (DocumentSnapshot document in querySnapshot.docs) {
      try {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        Circle circle = Circle.fromJson(data,
            id: document.id, ref: document.reference.path);
        DocumentReference ref = data["createdBy"] as DocumentReference;
        circle.createdBy = await _userFromRef(ref);
        if (data['activeSession'] != null) {
          Session.fromJson(data['activeSession'],
              circle: circle, id: circle.id);
        }
        circles.add(circle);
      } catch (ex, stack) {
        debugPrint(ex.toString());
        await reportError(ex, stack);
      }
    }
    sink.add(circles);
  }

  void _mapSingleCircleUserReference(
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot,
      EventSink sink) async {
    if (documentSnapshot.exists) {
      try {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        Circle circle = Circle.fromJson(data,
            id: documentSnapshot.id, ref: documentSnapshot.reference.path);
        DocumentReference ref = data["createdBy"] as DocumentReference;
        circle.createdBy = await _userFromRef(ref);
        if (data['activeSession'] != null) {
          Session.fromJson(data['activeSession'],
              circle: circle, id: circle.id);
        }
        sink.add(circle);
      } catch (ex, stack) {
        debugPrint(ex.toString());
        await reportError(ex, stack);
      }
    } else {
      sink.add(null);
    }
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

  @override
  Future<bool> removeCircle(
      {required Circle circle, required String uid}) async {
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
    } catch (ex, stack) {
      debugPrint(ex.toString());
      await reportError(ex, stack);
    }
    return false;
  }

  @override
  Future<Circle?> circleFromId(String id, String uid) async {
    try {
      final DocumentReference circleRef =
          FirebaseFirestore.instance.collection(Paths.snapCircles).doc(id);
      DocumentSnapshot circleSnapshot = await circleRef.get();
      Map<String, dynamic> data = circleSnapshot.data() as Map<String, dynamic>;
      Circle circle =
          Circle.fromJson(data, id: id, ref: circleRef.path, uid: uid);
      DocumentReference ref = data["createdBy"] as DocumentReference;
      circle.createdBy = await _userFromRef(ref);
      if (data['activeSession'] != null) {
        Session.fromJson(data['activeSession'], circle: circle, id: circle.id);
      }
      return circle;
    } catch (ex, stack) {
      debugPrint(ex.toString());
      await reportError(ex, stack);
    }
    return null;
  }

  @override
  Future<Circle?> circleFromPreviousIdAndState(
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
        Circle circle = Circle.fromJson(snapshot.data(),
            id: snapshot.id, ref: snapshot.reference.path);
        return circle;
      }
    } catch (ex, stack) {
      debugPrint(ex.toString());
      await reportError(ex, stack);
    }
    return null;
  }

  @override
  Future<Circle?> circleFromPreviousIdAndNotState(
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
        Circle circle = Circle.fromJson(snapshot.data(),
            id: snapshot.id, ref: snapshot.reference.path);
        return circle;
      }
    } catch (ex, stack) {
      debugPrint(ex.toString());
      await reportError(ex, stack);
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
        Map<String, dynamic> bannedParticipants = Map<String, dynamic>.from(
            snapshot.data()['bannedParticipants'] as Map? ?? {});
        if (bannedParticipants[uid] != null) {
          return false;
        }
      }
    } catch (ex, stack) {
      debugPrint(ex.toString());
      await reportError(ex, stack);
    }
    return true;
  }
}
