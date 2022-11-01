import 'package:flutter/cupertino.dart';
import 'package:totem/models/index.dart';

abstract class SessionProvider extends ChangeNotifier {
  Future<void> joinSession({
    required Session session,
    required String uid,
    String? sessionImage,
    required String sessionUserId,
    bool muted = false,
    bool videoMuted = false,
  });
  Future<void> leaveSession(
      {required Session session, required String sessionUid});
  Future<ActiveSession> createActiveSession(
      {required SnapCircle circle, required String uid});
  Future<void> startActiveSession();
  Future<void> endActiveSession();
  void clear();
  ActiveSession? get activeSession;
  Future<SessionToken> requestSessionToken({required Session session});
  Future<SessionToken> requestSessionTokenWithUID(
      {required Session session, required int uid});
  Future<bool> updateActiveSession(Map<String, dynamic> update);
  Future<bool> updateActiveSessionState(SessionState state);
  Future<bool> notifyUserStatus(
      {required String sessionUserId,
      required bool muted,
      required bool videoMuted,
      required bool userChange});
  Future<bool> removeParticipantFromActiveSession(
      {required String sessionUserId});
  Future<void> muteAllExceptTotem();
  Stream<SessionDataMessage?> get messageStream;
}
