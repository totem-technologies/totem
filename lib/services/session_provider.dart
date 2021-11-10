import 'package:flutter/cupertino.dart';
import 'package:totem/models/index.dart';

abstract class SessionProvider extends ChangeNotifier {
  Future<ActiveSession> activateSession(
      {required Session session, required String uid});
  Future<void> joinSession(
      {required Session session, required String uid, String? sessionUserId});
  Future<void> leaveSession(
      {required Session session, required String sessionUid});
  Future<ActiveSession> createActiveSession({required Session session});
  Future<void> startActiveSession();
  Future<void> endActiveSession();
  void clear();
  ActiveSession? get activeSession;
}
