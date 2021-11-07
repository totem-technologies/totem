import 'package:flutter/cupertino.dart';
import 'package:totem/models/index.dart';

abstract class SessionProvider extends ChangeNotifier {
  Future<ActiveSession> activateSession(
      {required Session session, required String uid});
  Future<void> joinSession({required Session session, required String uid});
  Future<void> endActiveSession();
  void clear();
  ActiveSession? get activeSession;
}
