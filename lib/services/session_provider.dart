import 'package:flutter/cupertino.dart';
import 'package:totem/models/index.dart';

abstract class SessionProvider extends ChangeNotifier {
  Future<ActiveSession> activateSession(
      {required ScheduledSession session, required String uid});
  Future<void> joinSession(
      {required Session session,
      required String uid,
      String? sessionImage,
      String? sessionUserId});
  Future<void> leaveSession(
      {required Session session, required String sessionUid});
  Future<ActiveSession> createActiveSession(
      {required Session session, required String uid});
  Future<void> startActiveSession();
  Future<void> endActiveSession();
  void clear();
  ActiveSession? get activeSession;
  Future<SessionToken> requestSessionToken({required Session session});
  Future<SessionToken> requestSessionTokenWithUID(
      {required Session session, required int uid});
  Future<bool> updateActiveSession(Map<String, dynamic> update);
  Future<bool> updateActiveSessionState(SessionState state);
}
