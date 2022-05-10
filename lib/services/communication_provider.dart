import 'package:flutter/material.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';

enum CommunicationState {
  disconnected,
  disconnecting,
  joining,
  active,
  failed,
  networkConnectivity
}

class CommunicationErrors {
  static const String communicationError = "errorCommunicationError";
  static const String noMicrophonePermission =
      "errorCommunicationNoMicrophonePermission";
}

abstract class CommunicationProvider extends ChangeNotifier {
  CommunicationState state = CommunicationState.disconnected;
  bool muted = false;
  bool videoMuted = false;
  dynamic get channelId;
  Future<bool> joinSession({
    required Session session,
    required CommunicationHandler handler,
    Map<String, bool>? state,
    bool enableVideo,
    required Size fullScreenSize,
  });
  Future<void> leaveSession({bool requested = true});
  Future<void> endSession();
  String? get lastError;

  Future<void> startPreview();
  Future<void> stopPreview();

  Future<void> muteVideo(bool mute);
  Future<void> muteAudio(bool mute);
  Future<bool> receiveActiveSessionTotem({required String sessionUserId});
  Future<bool> passActiveSessionTotem({required String sessionUserId});
  Future<bool> doneActiveSessionTotem({required String sessionUserId});
  Future<bool> forceNextActiveSessionTotem();
  Future<void> setHasTotem(bool hasTotem);
  Stream<CommunicationAudioVolumeIndication> get audioIndicatorStream;
}
