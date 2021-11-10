import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/auth/auth_exception.dart';
import 'package:totem/services/firebase_providers/paths.dart';
import 'package:totem/services/session_exception.dart';
import 'package:totem/services/session_provider.dart';

class FirebaseSessionProvider extends SessionProvider {
  ActiveSession? _activeSession;
  StreamSubscription? _sessionSubscription;

  @override
  ActiveSession? get activeSession {
    return _activeSession;
  }

  @override
  void clear() {
    _sessionSubscription?.cancel();
    _sessionSubscription = null;
    _activeSession = null;
    notifyListeners();
  }

  @override
  Future<ActiveSession> activateSession(
      {required Session session, required String uid}) async {
    // validate session keeper vs uid
    if (_activeSession != null && _activeSession!.session == session) {
      return _activeSession!;
    }
    if (session.circle.participantRole(uid) == Roles.keeper) {
      DocumentReference ref =
          FirebaseFirestore.instance.doc(session.circle.ref);
      WriteBatch batch = FirebaseFirestore.instance.batch();
      DocumentReference sessionRef =
          FirebaseFirestore.instance.doc(session.ref);
      Map<String, dynamic> sessionData = {
        "state": SessionState.waiting,
      };
      batch.update(sessionRef, sessionData);
      Map<String, dynamic> circleData = {"activeSession": sessionRef};
      batch.update(ref, circleData);
      await batch.commit();
      createActiveSession(session: session);
      return _activeSession!;
    }
    throw SessionException(
      code: AuthException.errorCodeUnauthorized,
      reference: session.ref,
    );
  }

  @override
  Future<void> joinSession(
      {required Session session,
      required String uid,
      String? sessionUserId}) async {
    // For security reasons, this might be better in a cloud function
    // so as not to give direct write permission to a session from a
    // participant? For now just allow it till we get functional
    try {
      DocumentReference ref = FirebaseFirestore.instance.doc(session.ref);
      DocumentReference userProfileRef =
          FirebaseFirestore.instance.collection(Paths.users).doc(uid);
      DocumentSnapshot sessionData = await ref.get();
      if (sessionData.exists) {
        Map<String, dynamic> data = sessionData.data()! as Map<String, dynamic>;
        List<Map<String, dynamic>> participants =
            List<Map<String, dynamic>>.from(data["participants"] ?? []);
        final existingUser = participants.firstWhereOrNull(
            (element) => element['ref']?.path == userProfileRef.path);
        if (existingUser == null) {
          participants.add(_participant(userProfileRef,
              sessionUserId: sessionUserId,
              role: session.circle.participantRole(uid).toString()));
        } else {
          existingUser['sessionUserId'] = sessionUserId;
        }
        await ref.update({"participants": participants});
      } else {
        throw SessionException(
          code: SessionException.errorCodeInvalidSession,
          reference: session.ref,
        );
      }
    } on FirebaseException catch (ex) {
      throw SessionException(
        code: ex.code,
        message: ex.message,
        reference: session.ref,
      );
    }
  }

  @override
  Future<void> leaveSession(
      {required Session session, required String sessionUid}) async {
    // For security reasons, this might be better in a cloud function
    // so as not to give direct write permission to a session from a
    // participant? For now just allow it till we get functional
    try {
      DocumentReference ref = FirebaseFirestore.instance.doc(session.ref);
      DocumentSnapshot sessionData = await ref.get();
      if (sessionData.exists && sessionData['state'] == SessionState.waiting) {
        // only remove people if they leave before the session is live,
        // this way they don't end up in the list of users when the
        // session is archived after completion
        Map<String, dynamic> data = sessionData.data()! as Map<String, dynamic>;
        List<Map<String, dynamic>> participants =
            List<Map<String, dynamic>>.from(data["participants"] ?? []);
        participants
            .removeWhere((element) => element['sessionUserId'] == sessionUid);
        await ref.update({"participants": participants});
      } else {
        throw SessionException(
          code: SessionException.errorCodeInvalidSession,
          reference: session.ref,
        );
      }
    } on FirebaseException catch (ex) {
      throw SessionException(
        code: ex.code,
        message: ex.message,
        reference: session.ref,
      );
    }
  }

  @override
  Future<void> startActiveSession() async {
    if (_activeSession != null) {
      try {
        DocumentReference ref =
            FirebaseFirestore.instance.doc(activeSession!.session.ref);
        Map<String, dynamic> data = {"state": SessionState.live};
        await ref.update(data);
      } on FirebaseException catch (ex) {
        throw SessionException(
          code: ex.code,
          reference: _activeSession!.session.ref,
          message: ex.message,
        );
      }
    }
  }

  @override
  Future<void> endActiveSession({bool complete = true}) async {
    if (_activeSession != null) {
      try {
        WriteBatch batch = FirebaseFirestore.instance.batch();
        DocumentReference ref =
            FirebaseFirestore.instance.doc(_activeSession!.session.circle.ref);
        Map<String, dynamic> circleData = {"activeSession": null};
        batch.update(ref, circleData);
        if (!complete) {
          // restore session back to pending, this is just a cancel
          Map<String, dynamic> sessionData = {
            "state": SessionState.pending,
            "participants": null,
          };
          batch.update(
              FirebaseFirestore.instance.doc(activeSession!.session.ref),
              sessionData);
        } else {
          // session has completed, archive to completed collection
          Map<String, dynamic> sessionData = activeSession!.toJson();
          sessionData["participants"] =
              activeSession!.participants.map((participant) {
            Map<String, dynamic> data = participant.toJson();
            // convert to doc reference for firebase
            data["ref"] = FirebaseFirestore.instance.doc(data['ref']);
          }).toList(growable: false);
          sessionData["completed"] = DateTime.now();
          DocumentReference sessionRef = FirebaseFirestore.instance
              .doc(activeSession!.session.circle.ref)
              .collection(Paths.completedSessions)
              .doc(activeSession!.session.id);
          batch.set(sessionRef, sessionData);
          batch.delete(
              FirebaseFirestore.instance.doc(activeSession!.session.ref));
        }
        await batch.commit();
        clear();
      } on FirebaseException catch (ex) {
        throw SessionException(
          code: ex.code,
          reference: _activeSession!.session.ref,
          message: ex.message,
        );
      }
    }
  }

  Map<String, dynamic> _participant(DocumentReference userRef,
      {String? role, String? sessionUserId}) {
    Map<String, dynamic> data = {
      "ref": userRef,
      "role": role ?? Roles.member.toString(),
      "joined": DateTime.now(),
      "online": true,
    };
    if (sessionUserId != null) {
      data["sessionUserId"] = sessionUserId;
    }
    return data;
  }

  @override
  Future<ActiveSession> createActiveSession({required Session session}) async {
    clear();
    _activeSession = ActiveSession(session: session);
    DocumentReference ref = FirebaseFirestore.instance.doc(session.ref);
    Stream<DocumentSnapshot> liveSession = ref.snapshots();
    _sessionSubscription = liveSession.listen(_updateLiveSession);
    notifyListeners();
    return _activeSession!;
  }

  Future<void> _updateLiveSession(DocumentSnapshot sessionSnapshot) async {
    // blend live data changes with current liveSession
    // only care about stateful session data
    if (sessionSnapshot.exists) {
      final Map<String, dynamic> data =
          sessionSnapshot.data()! as Map<String, dynamic>;
      if (data['participants'] != null) {
        List<Map<String, dynamic>> participantUpdates =
            List<Map<String, dynamic>>.from(data['participants']);
        final participants =
            await Future.wait(participantUpdates.map((participantData) async {
          DocumentReference ref = participantData['ref'];
          DocumentSnapshot doc = await ref.get();
          return Participant.fromJson(
            participantData,
            userProfile: UserProfile.fromJson(
              doc.data() as Map<String, dynamic>,
              uid: doc.id,
              ref: doc.reference.path,
            ),
          );
        }).toList());
        data['participants'] = participants;
      }
      _activeSession!.updateFromData(data);
      notifyListeners();
    }
  }
}
