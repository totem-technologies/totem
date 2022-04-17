import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/auth/auth_exception.dart';
import 'package:totem/services/firebase_providers/paths.dart';
import 'package:totem/services/service_exception.dart';
import 'package:totem/services/session_provider.dart';

class FirebaseSessionProvider extends SessionProvider {
  ActiveSession? _activeSession;
  StreamSubscription? _sessionSubscription;
  StreamSubscription? _circleSubscription;

  @override
  ActiveSession? get activeSession {
    return _activeSession;
  }

  @override
  void clear() {
    // stop listening to updates for the session and clear the data
    _sessionSubscription?.cancel();
    _circleSubscription?.cancel();
    _sessionSubscription = null;
    _circleSubscription = null;
    _activeSession = null;
    notifyListeners();
  }

  @override
  Future<ActiveSession> activateSession(
      {required ScheduledSession session, required String uid}) async {
    // TODO - THIS IS FOR SCHEDULED SESSIONS
    // THIS NEEDS TO BE UPDATED WHEN SCHEDULED SESSIONS ARE SUPPORTED
    // validate session keeper vs uid
    if (_activeSession != null && _activeSession!.circle.id == session.id) {
      return _activeSession!;
    }
    if (session.circle.participantRole(uid) == Role.keeper) {
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
      createActiveSession(circle: session.circle, uid: uid);
      return _activeSession!;
    }
    throw ServiceException(
      code: AuthException.errorCodeUnauthorized,
      reference: session.ref,
    );
  }

  @override
  Future<void> joinSession({
    required Session session,
    required String uid,
    String? sessionImage,
    required String sessionUserId,
  }) async {
    // For security reasons, this might be better in a cloud function
    // so as not to give direct write permission to a session from a
    // participant? For now just allow it till we get functional
    try {
      bool result = false;
      if (session is SnapSession) {
        result =
            await _joinSnapSession(session, uid, sessionUserId, sessionImage);
      } else {
        result = await _joinScheduledSession(
            session as ScheduledSession, uid, sessionUserId, sessionImage);
      }
      if (!result) {
        throw ServiceException(
          code: ServiceException.errorCodeInvalidSession,
          reference: session.circle.ref,
        );
      }
    } on FirebaseException catch (ex) {
      throw ServiceException(
        code: ex.code,
        message: ex.message,
        reference: session.circle.ref,
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
      bool result = false;
      if (session.state != SessionState.cancelled &&
          session.state != SessionState.complete) {
        if (session is SnapSession) {
          result = await _removeSnapSessionParticipant(session, sessionUid);
        } else {
          result = await _removeScheduledSessionParticipant(
              session as ScheduledSession, sessionUid);
        }
        if (!result) {
          throw ServiceException(
            code: ServiceException.errorCodeInvalidSession,
            reference: session.circle.ref,
          );
        }
      }
    } on FirebaseException catch (ex) {
      throw ServiceException(
        code: ex.code,
        message: ex.message,
        reference: session.circle.ref,
      );
    }
  }

  @override
  Future<void> startActiveSession() async {
    if (_activeSession != null) {
      try {
        await updateActiveSessionState(SessionState.starting);
        if (activeSession!.isSnap) {
          // now start the session
          HttpsCallable callable =
              FirebaseFunctions.instance.httpsCallable('startSnapSession');
          final result = await callable({"circleId": activeSession!.circle.id});
          debugPrint('completed startSnapSession with result ${result.data}');
        } else {
          // TODO - FIX FOR ScHEDULED SESSIONS
          DocumentReference ref =
              FirebaseFirestore.instance.doc(activeSession!.circle.ref);
          Map<String, dynamic> data = {"state": SessionState.live.name};
          await ref.update(data);
        }
      } on FirebaseException catch (ex) {
        throw ServiceException(
          code: ex.code,
          reference: _activeSession!.circle.ref,
          message: ex.message,
        );
      }
    }
  }

  @override
  Future<SessionToken> requestSessionToken({required Session session}) async {
    try {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('getToken');
      final result = await callable({"channelName": session.id});
      return SessionToken.fromJson(result.data);
    } catch (ex) {
      throw ServiceException(code: "token_error", reference: session.ref);
    }
  }

  @override
  Future<SessionToken> requestSessionTokenWithUID(
      {required Session session, required int uid}) async {
    try {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('getTokenWithUserId');
      final result = await callable({"channelName": session.id, "userId": uid});
      return SessionToken.fromJson(result.data);
    } catch (ex) {
      throw ServiceException(code: "token_error", reference: session.ref);
    }
  }

  @override
  Future<void> endActiveSession() async {
    if (_activeSession != null) {
      bool complete = _activeSession!.state == SessionState.live;
      try {
        await updateActiveSessionState(
            complete ? SessionState.ending : SessionState.cancelling);
        if (activeSession!.isSnap) {
          HttpsCallable callable =
              FirebaseFunctions.instance.httpsCallable('endSnapSession');
          final result = await callable({"circleId": activeSession!.circle.id});
          debugPrint('completed endSnapSession with result ${result.data}');
        } else {
          WriteBatch batch = FirebaseFirestore.instance.batch();
          DocumentReference ref =
              FirebaseFirestore.instance.doc(_activeSession!.circle.ref);
          Map<String, dynamic> circleData = {"activeSession": null};
          batch.update(ref, circleData);
          /* TODO - Update for scheduled session support
          if (!complete) {
            // restore session back to pending, this is just a cancel
            Map<String, dynamic> sessionData = {
              "state": SessionState.pending.name,
              "participants": null,
            };
            batch.update(
                FirebaseFirestore.instance.doc(activeSession!.session.ref),
                sessionData);
          } else {
            // session has completed, archive to completed collection
            Map<String, dynamic> sessionData = activeSession!.toJson();
            sessionData["participants"] =
                activeSession!.participants.map((key, participant) {
              Map<String, dynamic> data = participant.toJson();
              // convert to doc reference for firebase
              data["ref"] = FirebaseFirestore.instance.doc(data['uid']);
              return MapEntry(key, data);
            });
            sessionData["completed"] = DateTime.now();
            DocumentReference sessionRef = FirebaseFirestore.instance
                .doc(activeSession!.session.circle.ref)
                .collection(Paths.completedSessions)
                .doc(activeSession!.session.id);
            batch.set(sessionRef, sessionData);
            batch.delete(
                FirebaseFirestore.instance.doc(activeSession!.session.ref));
          } */
          await batch.commit();
        }
//        clear();
      } on FirebaseException catch (ex) {
        throw ServiceException(
          code: ex.code,
          reference: _activeSession!.circle.ref,
          message: ex.message,
        );
      }
    }
  }

  Map<String, dynamic> _participant({
    required String uid,
    required String name,
    String? role,
    String? sessionUserId,
    String? sessionImage,
    bool muted = false,
    bool videoMuted = false,
  }) {
    Map<String, dynamic> data = {
      "uid": uid,
      "name": name,
      "role": role ?? Role.member.name,
      "joined": DateTime.now(),
      "muted": muted,
      "videoMuted": videoMuted,
    };
    if (sessionUserId != null) {
      data["sessionUserId"] = sessionUserId;
    }
    if (sessionImage != null) {
      data["sessionImage"] = sessionImage;
    }
    return data;
  }

  @override
  Future<bool> updateActiveSession(Map<String, dynamic> update) async {
    if (_activeSession != null) {
      try {
        if (_activeSession!.isSnap) {
          await FirebaseFirestore.instance.runTransaction((transaction) async {
            DocumentReference activeCircleRef = FirebaseFirestore.instance
                .collection(Paths.activeCircles)
                .doc(_activeSession!.circle.id);
            DocumentSnapshot snapshot = await transaction.get(activeCircleRef);
            Map<String, dynamic> data =
                snapshot.data()! as Map<String, dynamic>;
            for (String key in update.keys) {
              data[key] = update[key];
            }
            transaction.update(activeCircleRef, data);
          });
        } else {
          // todo for scheduled session
        }
        return true;
      } on FirebaseException catch (ex) {
        throw ServiceException(
          code: ex.code,
          reference: activeSession!.circle.ref,
          message: ex.message,
        );
      }
    }
    return false;
  }

  @override
  Future<bool> updateActiveSessionState(SessionState state) async {
    if (_activeSession != null) {
      try {
        // first update the state of the session to 'starting'
        if (_activeSession!.isSnap) {
          await FirebaseFirestore.instance.runTransaction((transaction) async {
            DocumentReference ref =
                FirebaseFirestore.instance.doc(_activeSession!.circle.ref);
            Map<String, dynamic> data = {"state": state.name};
            transaction.update(ref, data);
          });
          return true;
        } else {
          // todo for scheduled session
        }
      } on FirebaseException catch (ex) {
        throw ServiceException(code: ex.code);
      }
    }
    return false;
  }

  @override
  Future<ActiveSession> createActiveSession(
      {required Circle circle, required String uid, bool snap = true}) async {
    clear();
    _activeSession = ActiveSession(circle: circle, userId: uid);
    DocumentReference ref = FirebaseFirestore.instance.doc(circle.ref);
    Stream<DocumentSnapshot> liveSession = ref.snapshots();
    if (snap) {
      _circleSubscription = liveSession.listen(_updateLiveCircle);
      DocumentReference sessionRef = FirebaseFirestore.instance
          .collection(Paths.activeCircles)
          .doc(circle.id);
      Stream<DocumentSnapshot> activeSession = sessionRef.snapshots();
      _sessionSubscription = activeSession.listen(_updateLiveSnapSession);
    } else {
      // TODO - scheduled
      _sessionSubscription = liveSession.listen(_updateLiveSession);
    }
    notifyListeners();
    return _activeSession!;
  }

  Future<void> _updateLiveCircle(DocumentSnapshot sessionSnapshot) async {
    if (sessionSnapshot.exists) {
      final Map<String, dynamic> data =
          sessionSnapshot.data()! as Map<String, dynamic>;
      _activeSession?.updateSessionState(data);
      notifyListeners();
    }
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
        final participants = participantUpdates.map((participantData) {
          return SessionParticipant.fromJson(participantData,
              me: participantData['uid'] == _activeSession!.userId);
        }).toList();
        data['participants'] = participants;
      }
      _activeSession!.updateFromData(data);
      notifyListeners();
    }
  }

  Future<void> _updateLiveSnapSession(DocumentSnapshot sessionSnapshot) async {
    // blend live data changes with current liveSession
    // only care about stateful session data
    if (sessionSnapshot.exists) {
      final Map<String, dynamic> sessionData =
          sessionSnapshot.data()! as Map<String, dynamic>;
      _activeSession!.updateFromData(sessionData);
      notifyListeners();
    }
  }

  Future<bool> _removeScheduledSessionParticipant(
      ScheduledSession session, String sessionUid) async {
    // this way they don't end up in the list of users when the
    // session is archived after completion
    DocumentReference ref = FirebaseFirestore.instance.doc(session.ref);
    DocumentSnapshot sessionDataSnapshot = await ref.get();
    if (sessionDataSnapshot.exists) {
      Map<String, dynamic> sessionData =
          sessionDataSnapshot.data()! as Map<String, dynamic>;
      if (sessionData['state'] == SessionState.waiting) {
        // only remove people if they leave before the session is live,
        // this way they don't end up in the list of users when the
        // session is archived after completion
        List<Map<String, dynamic>> participants =
            List<Map<String, dynamic>>.from(sessionData["participants"] ?? []);
        participants
            .removeWhere((element) => element['sessionUserId'] == sessionUid);
        await ref.update({"participants": participants});
        return true;
      }
    }
    return false;
  }

  Future<bool> _removeSnapSessionParticipant(
      SnapSession session, String sessionUid) async {
    DocumentReference ref = FirebaseFirestore.instance
        .collection(Paths.activeCircles)
        .doc(session.circle.id);
    DocumentReference circleRef =
        FirebaseFirestore.instance.doc(session.circle.ref);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot circleDataSnapshot = await transaction.get(circleRef);
      DocumentSnapshot activeDataSnapshot = await transaction.get(ref);
      if (circleDataSnapshot.exists && activeDataSnapshot.exists) {
        Map<String, dynamic> circleData =
            circleDataSnapshot.data()! as Map<String, dynamic>;
        Map<String, dynamic> sessionData =
            activeDataSnapshot.data()! as Map<String, dynamic>;
        if (circleData['state'] == SessionState.waiting) {
          // only remove people if they leave before the session is over,
          Map<String, Map<String, dynamic>> participants =
              Map<String, Map<String, dynamic>>.from(
                  sessionData["participants"] ?? {});
          Map<String, dynamic>? participant = participants.values
              .firstWhereOrNull(
                  (element) => element["sessionUserId"] == sessionUid);
          if (participant != null) {
            participants.remove(participant["sessionUserId"]);
            if (sessionData["speakingOrder"] != null) {
              List<String> speakers =
                  List<String>.from(sessionData['speakingOrder']);
              speakers.remove(participant["sessionUserId"]);
              sessionData["speakingOrder"] = speakers;
            }
            sessionData['participants'] = participants;
            transaction.update(ref, sessionData);
            int count = participants.length;
            transaction.update(circleRef, {'participantCount': count});
          }
        }
      }
    });

    return true;
  }

  Future<bool> _joinScheduledSession(ScheduledSession session, String uid,
      String? sessionUserId, String? sessionImage) async {
    DocumentReference ref = FirebaseFirestore.instance.doc(session.ref);
    DocumentReference userProfileRef =
        FirebaseFirestore.instance.collection(Paths.users).doc(uid);
    DocumentSnapshot sessionData = await ref.get();
    DocumentSnapshot userData = await userProfileRef.get();
    if (sessionData.exists) {
      Map<String, dynamic> data = sessionData.data()! as Map<String, dynamic>;
      Map<String, Map<String, dynamic>> participants =
          Map<String, Map<String, dynamic>>.from(data["participants"] ?? {});
      final existingUser = participants.values.firstWhereOrNull(
          (element) => element['ref']?.path == userProfileRef.path);
      if (existingUser == null) {
        participants[uid] = _participant(
            uid: uid,
            name: userData["name"] ?? "",
            sessionUserId: sessionUserId,
            sessionImage: sessionImage,
            role: session.circle.participantRole(uid).name);
      } else {
        if (sessionUserId != null) {
          existingUser['sessionUserId'] = sessionUserId;
        }
        if (sessionImage != null) {
          existingUser['sessionImage'] = sessionImage;
        }
      }
      await ref.update({"participants": participants});
    }
    return false;
  }

  Future<bool> _joinSnapSession(SnapSession session, String uid,
      String sessionUserId, String? sessionImage) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference circleRef =
          FirebaseFirestore.instance.doc(session.circle.ref);
      DocumentReference activeCircleRef = FirebaseFirestore.instance
          .collection(Paths.activeCircles)
          .doc(session.circle.id);
      //DocumentSnapshot circleData = await transaction.get(circleRef);
      //Map<String, dynamic> circle = circleData.data()! as Map<String, dynamic>;
      DocumentReference userProfileRef =
          FirebaseFirestore.instance.collection(Paths.users).doc(uid);
      DocumentSnapshot circleSessionData =
          await transaction.get(activeCircleRef);
      DocumentSnapshot userData = await userProfileRef.get();
      if (circleSessionData.exists) {
        Map<String, dynamic> activeSession =
            circleSessionData.data()! as Map<String, dynamic>;
        Map<String, Map<String, dynamic>> participants =
            Map<String, Map<String, dynamic>>.from(
                activeSession["participants"] ?? {});
        List<String> speakingOrder = activeSession['speakingOrder'] != null
            ? List<String>.from(activeSession['speakingOrder'])
            : [];
        final existingUser = participants[sessionUserId];
        if (existingUser == null) {
          // check for user via user id, would need to replace old session id with
          // new one. This would be the case if someone dropped and rejoined using a
          // potentially different session id
          final Map<String, dynamic>? reconnectedUser = participants.values
              .firstWhereOrNull((element) => element["uid"] == uid);
          if (reconnectedUser != null &&
              reconnectedUser['sessionUserId'] != sessionUserId) {
            // remove the old sessionId based record
            participants.remove(reconnectedUser['sessionUserId']);
            speakingOrder.remove(reconnectedUser['sessionUserId']);
          }
          participants[sessionUserId] = _participant(
            uid: uid,
            name: userData['name'] ?? "",
            sessionUserId: sessionUserId,
            sessionImage: sessionImage,
            role: session.circle.participantRole(uid).name,
          );
        } else {
          existingUser['sessionUserId'] = sessionUserId;
          if (sessionImage != null) {
            existingUser['sessionImage'] = sessionImage;
          }
        }
        if (!speakingOrder.contains(sessionUserId)) {
          speakingOrder.add(sessionUserId);
        }
        activeSession["participants"] = participants;
        activeSession["lastChange"] =
            ActiveSessionChange.participantsChange.name;
        activeSession["speakingOrder"] = speakingOrder;
        transaction.update(activeCircleRef, activeSession);

        int count = (participants.length);
        transaction.update(circleRef, {"participantCount": count});
      }
    });
    return true;
  }

  @override
  Future<bool> notifyUserStatus(
      {required String sessionUserId,
      required bool muted,
      required bool videoMuted}) async {
    if (_activeSession != null) {
      SessionParticipant? participant =
          _activeSession!.participantWithSessionID(sessionUserId);
      if (participant != null) {
        participant.muted = muted;
        participant.videoMuted = videoMuted;
        try {
          await FirebaseFirestore.instance.runTransaction((transaction) async {
            DocumentReference ref = FirebaseFirestore.instance
                .collection(Paths.activeCircles)
                .doc(_activeSession!.circle.id);
            DocumentSnapshot snapshot = await transaction.get(ref);
            Map<String, dynamic> activeSession =
                snapshot.data()! as Map<String, dynamic>;
            Map<String, dynamic> participants =
                activeSession['participants'] ?? {};
            participants[sessionUserId] = participant.toJson();
            transaction.update(ref, {"participants": participants});
          });
          return true;
        } on FirebaseException catch (ex) {
          debugPrint('error updating user status: ' + ex.toString());
        }
      }
    }
    return false;
  }
}
