import 'package:flutter/material.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';

enum CommunicationState {
  disconnected,
  disconnecting,
  joining,
  active,
  failed,
  networkConnectivity,
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

  List<CommunicationDevice> get audioOutputs;
  List<CommunicationDevice> get audioInputs;
  List<CommunicationDevice> get cameras;

  CommunicationDevice? get camera;
  CommunicationDevice? get audioInput;
  CommunicationDevice? get audioOutput;

  Future<bool> setCamera(CommunicationDevice device);
  Future<bool> setAudioInput(CommunicationDevice device);
  Future<bool> setAudioOutput(CommunicationDevice device);

  Future<String?> initialDevicePreview({bool enableVideo = true});
  Future<bool> joinSession({
    required Session session,
    required CommunicationHandler handler,
    bool enableVideo,
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
  Future<bool> removeUserFromSession({required String sessionUserId});

  Stream<CommunicationAudioVolumeIndication> get audioIndicatorStream;

  bool get audioDeviceConfigurable;

  void testAudioOutput();
  void endTestAudioOutput();

  void testAudioInput();
  void endTestAudioInput();

  void switchCamera();
}
