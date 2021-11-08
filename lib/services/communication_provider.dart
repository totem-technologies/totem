import 'package:flutter/foundation.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';

enum CommunicationState { disconnected, joining, active, failed }

abstract class CommunicationProvider extends ChangeNotifier {
  CommunicationState state = CommunicationState.disconnected;
  Future<bool> joinSession(
      {required Session session, required CommunicationHandler handler});
  Future<void> leaveSession();
  Future<void> endSession();
  String? get lastError;
}
