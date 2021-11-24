import 'package:flutter/foundation.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';

enum CommunicationState { disconnected, disconnecting, joining, active, failed }

abstract class CommunicationProvider extends ChangeNotifier {
  CommunicationState state = CommunicationState.disconnected;
  bool muted = false;
  Future<bool> joinSession(
      {required Session session, required CommunicationHandler handler});
  Future<void> leaveSession();
  Future<void> endSession();
  String? get lastError;

  Future<void> muteAudio(bool mute);
}
