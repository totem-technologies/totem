import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/analytics_provider.dart';
import 'package:totem/services/communication_provider.dart';
import 'package:totem/services/error_report.dart';
import 'package:totem/services/firebase_providers/paths.dart';
import 'package:totem/services/service_exception.dart';
import 'package:totem/services/session_provider.dart';

class FirebaseSessionProvider extends SessionProvider {
  ActiveSession? _activeSession;
  StreamSubscription? _sessionSubscription;
  StreamSubscription? _circleSubscription;
  AnalyticsProvider analyticsProvider;
  String? userId;
  final StreamController<SessionDataMessage?> _messageStreamController =
      StreamController<SessionDataMessage?>.broadcast();

  FirebaseSessionProvider({required this.analyticsProvider});

  @override
  ActiveSession? get activeSession {
    return _activeSession;
  }

  @override
  void clear() {
    // stop listening to updates for the session and clear the data
    _messageStreamController.add(null);
    _sessionSubscription?.cancel();
    _circleSubscription?.cancel();
    _sessionSubscription = null;
    _circleSubscription = null;
    _activeSession = null;
    notifyListeners();
  }

  @override
  Stream<SessionDataMessage?> get messageStream =>
      _messageStreamController.stream;

  @override
  Future<void> joinSession({
    required Session session,
    required String uid,
    String? sessionImage,
    required String sessionUserId,
    bool muted = false,
    bool videoMuted = false,
  }) async {
    // For security reasons, this might be better in a cloud function
    // so as not to give direct write permission to a session from a
    // participant? For now just allow it till we get functional
    try {
      bool result = await _joinSnapSession(
          session, uid, sessionUserId, sessionImage,
          muted: muted, videoMuted: videoMuted);
      if (!result) {
        throw ServiceException(
          code: ServiceException.errorCodeInvalidSession,
          reference: session.circle.ref,
        );
      }
      userId = uid;

      // Log analytics
      analyticsProvider.joinedSnapSession(session);
    } on FirebaseException catch (ex, stack) {
      await reportError(ex, stack);
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
        result = await _removeSnapSessionParticipant(session, sessionUid);
        if (!result) {
          throw ServiceException(
            code: ServiceException.errorCodeInvalidSession,
            reference: session.circle.ref,
          );
        }
      }
    } on FirebaseException catch (ex, stack) {
      await reportError(ex, stack);
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
      } on FirebaseException catch (ex, stack) {
        await reportError(ex, stack);
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
    } on FirebaseException catch (ex, stack) {
      await reportError(ex, stack);
      throw ServiceException(
        code: ex.code,
        message: ex.message,
        reference: session.ref,
      );
    } catch (ex, stack) {
      await reportError(ex, stack);
      throw ServiceException(code: "token_error", reference: session.ref);
    }
  }

  @override
  Future<void> endActiveSession() async {
    if (_activeSession != null) {
      List<SessionState> validStates = [
        SessionState.waiting,
        SessionState.starting,
        SessionState.live,
        SessionState.expiring,
      ];

      if (!validStates.contains(_activeSession!.state)) {
        return;
      }
      bool complete = _activeSession!.live;
      try {
        await updateActiveSessionState(
            complete ? SessionState.ending : SessionState.cancelling);
        HttpsCallable callable =
            FirebaseFunctions.instance.httpsCallable('endSnapSession');
        final result = await callable({"circleId": activeSession!.circle.id});
        debugPrint('completed endSnapSession with result ${result.data}');
      } on FirebaseException catch (ex, stack) {
        await reportError(ex, stack);
        throw ServiceException(
          code: ex.code,
          reference: _activeSession!.circle.ref,
          message: ex.message,
        );
      }
    }
  }

  @override
  Future<void> addTimeToSession({required int minutes}) async {
    if (_activeSession != null && _activeSession!.live) {
      try {
        HttpsCallable callable =
            FirebaseFunctions.instance.httpsCallable('addMinutesToSession');
        final result = await callable({
          "circleId": _activeSession!.circle.id,
          "minutes": minutes,
        });
        debugPrint('completed addTimeToSnapSession($minutes) with result ${result.data}');
      } on FirebaseException catch (ex, stack) {
        await reportError(ex, stack);
        throw ServiceException(
          code: ex.code,
          reference: _activeSession!.circle.ref,
          message: ex.message,
        );
      }
    }
    return;
  }

  @override
  Future<void> cancelPendingSession({required Session session}) async {
    if (session.state == SessionState.waiting) {
      // If the session is already waiting to start then we can just end it
      try {
        await _updateCircleState(session.circle, SessionState.cancelling);
        HttpsCallable callable =
            FirebaseFunctions.instance.httpsCallable('endSnapSession');
        final result = await callable({"circleId": session.circle.id});
        debugPrint('completed endSnapSession with result ${result.data}');
      } on FirebaseException catch (ex, stack) {
        await reportError(ex, stack);
        throw ServiceException(
          code: ex.code,
          reference: _activeSession!.circle.ref,
          message: ex.message,
        );
      }
    } else if (session.state == SessionState.scheduled) {
      // TODO: implement cancelScheduledSession
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
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentReference activeCircleRef = FirebaseFirestore.instance
              .collection(Paths.activeCircles)
              .doc(_activeSession!.circle.id);
          DocumentSnapshot snapshot = await transaction.get(activeCircleRef);
          Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
          for (String key in update.keys) {
            data[key] = update[key];
          }
          data["userStatus"] = false;
          transaction.update(activeCircleRef, data);
        });
        return true;
      } on FirebaseException catch (ex, stack) {
        await reportError(ex, stack);
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
      return _updateCircleState(_activeSession!.circle, state);
    }
    return false;
  }

  Future<bool> _updateCircleState(Circle circle, SessionState state) async {
    try {
      // first update the state of the session to 'starting'
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference ref = FirebaseFirestore.instance.doc(circle.ref);
        Map<String, dynamic> data = {"state": state.name, "userStatus": false};
        transaction.update(ref, data);
      });
      return true;
    } on FirebaseException catch (ex, stack) {
      await reportError(ex, stack);
      throw ServiceException(code: ex.code);
    }
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
      Map<String, dynamic>? requestedUpdate =
          _activeSession!.updateFromData(sessionData);
      if (requestedUpdate != null) {
        // have to update the user
        await updateActiveSession(requestedUpdate);
      }
      if (sessionData["lastMessage"] != null) {
        SessionDataMessage message =
            SessionDataMessage.fromJson(sessionData["lastMessage"]);
        if (!message.expired) {
          Future.delayed(const Duration(milliseconds: 10), () {
            _messageStreamController.add(message);
          });
          return;
        }
      }
      notifyListeners();
    }
  }

  Future<bool> _removeSnapSessionParticipant(
      Session session, String sessionUid) async {
    List<String> validStates = [
      SessionState.waiting.name,
      SessionState.starting.name,
      SessionState.live.name,
    ];
    DocumentReference ref = FirebaseFirestore.instance
        .collection(Paths.activeCircles)
        .doc(session.circle.id);
    DocumentReference circleRef =
        FirebaseFirestore.instance.doc(session.circle.ref);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot circleDataSnapshot = await transaction.get(circleRef);
      DocumentSnapshot activeDataSnapshot = await transaction.get(ref);
      if (circleDataSnapshot.exists && activeDataSnapshot.exists) {
        Map<String, dynamic> circleData =
            circleDataSnapshot.data()! as Map<String, dynamic>;
        Map<String, dynamic> sessionData =
            activeDataSnapshot.data()! as Map<String, dynamic>;
        if (validStates.contains(circleData['state'])) {
          // only remove people if they leave before the session is over,
          Map<String, Map<String, dynamic>> participants =
              Map<String, Map<String, dynamic>>.from(
                  sessionData["participants"] ?? {});
          Map<String, dynamic>? participant = participants.values
              .firstWhereOrNull(
                  (element) => element["sessionUserId"] == sessionUid);
          if (participant != null) {
            participants.remove(participant["sessionUserId"]);
            sessionData['participants'] = participants;
            sessionData['userStatus'] = false;
            transaction.update(ref, sessionData);
          }
        }
      }
    });

    return true;
  }

  Future<bool> _joinSnapSession(
      Session session, String uid, String sessionUserId, String? sessionImage,
      {bool muted = false, bool videoMuted = false}) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
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
            //muted: muted,
            //videoMuted: videoMuted,
          );
        } else {
          existingUser['sessionUserId'] = sessionUserId;
          if (sessionImage != null) {
            existingUser['sessionImage'] = sessionImage;
          }
          //existingUser['muted'] = muted;
          //existingUser['videoMuted'] = videoMuted;
        }
        if (!speakingOrder.contains(sessionUserId)) {
          speakingOrder.add(sessionUserId);
        }
        activeSession["participants"] = participants;
        activeSession["lastChange"] =
            ActiveSessionChange.participantsChange.name;
        activeSession["speakingOrder"] = speakingOrder;
        activeSession["userStatus"] = false;
        transaction.update(activeCircleRef, activeSession);
      }
    });
    return true;
  }

  @override
  Future<bool> notifyUserStatus({
    required String sessionUserId,
    required bool muted,
    required bool videoMuted,
    required bool userChange,
  }) async {
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
            transaction.update(
                ref, {"participants": participants, "userStatus": userChange});
          });
          return true;
        } on FirebaseException catch (ex, stack) {
          await reportError(ex, stack);
          debugPrint('error updating user status: $ex');
        }
      }
    }
    return false;
  }

  @override
  Future<bool> removeParticipantFromActiveSession(
      {required String sessionUserId}) async {
    bool result = false;
    if (activeSession != null) {
      SessionParticipant? participant =
          activeSession!.participantWithSessionID(sessionUserId);
      if (participant != null) {
        try {
          await FirebaseFirestore.instance.runTransaction((transaction) async {
            DocumentReference activeCircleRef = FirebaseFirestore.instance
                .collection(Paths.activeCircles)
                .doc(activeSession!.circle.id);
            DocumentSnapshot activeSnapshot =
                await transaction.get(activeCircleRef);
            // Make sure the active session is present
            if (activeSnapshot.data() != null) {
              Map<String, dynamic> activeCircleData =
                  activeSnapshot.data()! as Map<String, dynamic>;
              Map<String, dynamic> participants =
                  activeCircleData['participants']! as Map<String, dynamic>;
              Map<String, dynamic>? participant =
                  activeCircleData['participants'][sessionUserId]
                      as Map<String, dynamic>?;
              if (participant != null) {
                String uid = participant['uid'] as String;
                participants.remove(sessionUserId);
                activeCircleData['participants'] = participants;

                transaction.update(activeCircleRef, activeCircleData);
                // Call backend to ban user from the circle
                HttpsCallable callable = FirebaseFunctions.instance
                    .httpsCallable('banUserFromCircle');
                final res = await callable({
                  "circleId": activeSession!.circle.id,
                  "uid": uid,
                  "sessionUserId": sessionUserId
                });
                debugPrint("banUserFromCircle result: ${res.data}");
                result = true;
              }
            }
          });
        } on FirebaseException catch (ex, stack) {
          debugPrint('error removing user from session: $ex');
          await reportError(ex, stack);
          result = false;
        } catch (ex, stack) {
          debugPrint('error removing user from session: $ex');
          await reportError(ex, stack);
          result = false;
        }
      }
    }
    return result;
  }

  @override
  Future<void> muteAllExceptTotem() async {
    if (activeSession != null && userId != null) {
      return _sendMessage(SessionDataMessage(
          sent: DateTime.now(),
          from: userId!,
          type: CommunicationMessageType.muteAllExceptTotem));
    }
  }

  Future<void> _sendMessage(SessionDataMessage message) async {
    if (_activeSession != null) {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference activeCircleRef = FirebaseFirestore.instance
            .collection(Paths.activeCircles)
            .doc(_activeSession!.circle.id);
        DocumentSnapshot activeSnapshot =
            await transaction.get(activeCircleRef);
        // Make sure the active session is present
        if (activeSnapshot.data() != null) {
          try {
            transaction
                .update(activeCircleRef, {"lastMessage": message.toJson()});
          } catch (ex) {
            debugPrint('error sending message: $ex');
          }
        }
      });
    }
  }
}
