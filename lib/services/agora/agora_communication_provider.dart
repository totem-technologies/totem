import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:collection/collection.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:totem/config.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/error_report.dart';
import 'package:totem/services/index.dart';
import 'package:wakelock/wakelock.dart';

enum PermissionType {
  video,
  audio,
}

class AgoraCommunicationProvider extends CommunicationProvider {
  static const String appId = AppConfig.agoriaAppID;

  // These are used as default values for the video preview, modify
  // as needed to define a different default as these get set on the engine
  static const int fullScreenHeight = 600;
  static const int fullScreenWidth = 600;

  // Communication streams
  static const int statsStream = 0;
  static const int notifyDuration = 10; // seconds
  static const int networkTimeoutDuration = 20; // seconds
  static const bool useAgoraStream = false;

  AgoraCommunicationProvider({
    required this.sessionProvider,
    required this.userId,
  }) {
    sessionProvider.addListener(_updateCommunicationFromSession);
    _messageSubscription = sessionProvider.messageStream.listen(_handleMessage);
  }
  bool _hasTotem = false;
  RtcEngine? _engine;
  CommunicationHandler? _handler;
  int commUid = 0;
  late SessionProvider sessionProvider;
  Session? _session;
  final String userId;
  String? _lastError;
  bool _pendingComplete = false;
  late SessionToken _sessionToken;
  String? _sessionImage;
  SessionState? _lastState;
  bool _pendingRequestLeave = false;
  bool _isIndicatorStreamOpen = false;
  StreamController<CommunicationAudioVolumeIndication>?
      _audioIndicatorStreamController;
  dynamic _channel;
  Timer? _updateTimer;
  Timer? _networkErrorTimeout;

  // Devices and selected device
  List<CommunicationDevice> _cameras = [];
  List<CommunicationDevice> _audioOutputs = [];
  List<CommunicationDevice> _audioInputs = [];
  CommunicationDevice? _camera;
  CommunicationDevice? _audioInput;
  CommunicationDevice? _audioOutput;
  SystemVideo systemVideo = SystemVideo();

  late StreamSubscription<SessionDataMessage?> _messageSubscription;

  @override
  String? get lastError {
    return _lastError;
  }

  @override
  void dispose() {
    _messageSubscription.cancel();
    _networkErrorTimeout?.cancel();
    _cancelStateUpdates();
    _channel = null;
    try {
      sessionProvider.removeListener(_updateCommunicationFromSession);
      _engine?.stopPreview();
      _engine?.destroy();
      _engine = null;
      _audioIndicatorStreamController?.close();
      super.dispose();
    } catch (ex, stack) {
      reportError(ex, stack);
      debugPrint("unable to break down engine: $ex");
    }
  }

  @override
  Future<String?> initialDevicePreview(
      {bool enableVideo = true, SystemVideo? video}) async {
    String? errorMessage;
    if (video != null) {
      systemVideo = video;
    }
    try {
      await _assertEngine(enableVideo);

      // Speakers
      try {
        List<MediaDeviceInfo> audioDevices =
            await _engine!.deviceManager.enumerateAudioPlaybackDevices();
        _audioOutputs = audioDevices
            .map((device) => CommunicationDevice(
                name: device.deviceName,
                id: device.deviceId,
                type: CommunicationDeviceType.speakers))
            .toList(growable: false);
        String? audioPlayback =
            await _engine!.deviceManager.getAudioPlaybackDevice();
        if (audioPlayback != null) {
          _audioOutput = _audioOutputs.firstWhereOrNull((speaker) =>
              audioPlayback.isNotEmpty
                  ? speaker.id == audioPlayback
                  : speaker.id == "default");
        }
        _audioOutput ??= _audioOutputs.first;
      } catch (ex, stack) {
        debugPrint('unable to get devices: $ex');
        await reportError(ex, stack);
      }

      // Microphones
      try {
        List<MediaDeviceInfo> audioInputDevices =
            await _engine!.deviceManager.enumerateAudioRecordingDevices();
        _audioInputs = audioInputDevices
            .map((device) => CommunicationDevice(
                name: device.deviceName,
                id: device.deviceId,
                type: CommunicationDeviceType.microphone))
            .toList(growable: false);
        String? audioInput =
            await _engine!.deviceManager.getAudioRecordingDevice();
        if (audioInput != null) {
          _audioInput = _audioInputs.firstWhereOrNull((device) =>
              audioInput.isNotEmpty
                  ? device.id == audioInput
                  : device.name == "default");
        }
        _audioInput ??= _audioInputs.first;
        if (_audioInput == null) {
          return "errorNoMicrophone";
        }
      } catch (ex, stack) {
        debugPrint('unable to get audioInput devices, not supported $ex');
        await reportError(ex, stack);
      }

      // Cameras
      try {
        List<MediaDeviceInfo> cameraDevices =
            await _engine!.deviceManager.enumerateVideoDevices();
        _cameras = cameraDevices
            .map((device) => CommunicationDevice(
                name: device.deviceName,
                id: device.deviceId,
                type: CommunicationDeviceType.camera))
            .toList(growable: false);
        String? camera = await _engine!.deviceManager.getVideoDevice();
        if (camera != null) {
          _camera = _cameras.firstWhereOrNull((device) => camera.isNotEmpty
              ? device.id == camera
              : device.name == "default");
        }
        _camera ??= _cameras.first;
        if (_camera == null) {
          return "errorCamera";
        }
      } catch (ex, stack) {
        debugPrint('unable to get camera devices, not supported $ex');
        await reportError(ex, stack);
      }
      return null;
    } catch (ex, stack) {
      debugPrint('unable to activate agora session: $ex');
      await reportError(ex, stack);
      _updateState(CommunicationState.failed);
      errorMessage = ex.toString();
    }
    return errorMessage;
  }

  @override
  Future<bool> joinSession({
    required Session session,
    required CommunicationHandler handler,
    String? sessionImage,
    bool enableVideo = false,
  }) async {
    _handler = handler;
    _session = session;
    _sessionImage = sessionImage;
    _lastError = null;
    _audioIndicatorStreamController =
        StreamController<CommunicationAudioVolumeIndication>.broadcast(
      onListen: () {
        _isIndicatorStreamOpen = true;
      },
      onCancel: () {
        _isIndicatorStreamOpen = false;
      },
    );
    _updateState(CommunicationState.joining);
    try {
      await _assertEngine(enableVideo);
      int uid = Random().nextInt(100000);
      _sessionToken = await sessionProvider.requestSessionTokenWithUID(
          session: session, uid: uid);
      bool hasAudioPermission = await checkPermissions(PermissionType.audio);
      // Check to ensure there is at least one microphone connected
      if (!hasAudioPermission) {
        _updateState(CommunicationState.failed);
        return false;
      }
      await _engine!.joinChannel(_sessionToken.token, session.id, null, uid);
    } on ServiceException catch (ex, stack) {
      await reportError(ex, stack);
      _lastError = ex.message;
      _updateState(CommunicationState.failed);
    } catch (ex, stack) {
      debugPrint('unable to activate agora session: $ex');
      await reportError(ex, stack);
      _updateState(CommunicationState.failed);
    }
    return false;
  }

  @override
  Future<void> leaveSession({bool requested = true}) async {
    // disable wakelock
    unawaited(Wakelock.disable());

    // for android, stop the foreground service to keep the process running
    // to prevent drops in connection
    if (!kIsWeb && Platform.isAndroid) {
      await SessionForeground.instance.stopSessionTask();
    }

    _pendingRequestLeave = requested;

    if (requested &&
        sessionProvider.activeSession != null &&
        sessionProvider.activeSession!.totemParticipant != null &&
        sessionProvider.activeSession!.totemParticipant!.me) {
      // User is requesting to leave and they are the active totem user ...
      // need to pass the totem in this case
      await passActiveSessionTotem(
          sessionUserId: sessionProvider.activeSession!.totemUser!);
    }
    _cancelStateUpdates();
    await _engine?.leaveChannel();
    // update list of participants
  }

  @override
  Future<void> endSession() async {
    // need to see if there is another call for
    // session owner to end for all?
    _pendingComplete = true;
    _updateState(CommunicationState.disconnecting);
    await _engine?.leaveChannel();
  }

  @override
  Future<bool> receiveActiveSessionTotem(
      {required String sessionUserId}) async {
    if (sessionProvider.activeSession?.totemUser == sessionUserId) {
      // update the session information with the user
      Map<String, dynamic>? update =
          sessionProvider.activeSession?.receiveUserTotem();
      if (update != null) {
        return await sessionProvider.updateActiveSession(update);
      }
    }
    return false;
  }

  @override
  Future<bool> passActiveSessionTotem({required String sessionUserId}) async {
    if (sessionProvider.activeSession?.totemUser == sessionUserId) {
      Map<String, dynamic>? update =
          sessionProvider.activeSession?.requestNextUserTotem();
      if (update != null) {
        return await sessionProvider.updateActiveSession(update);
      }
    }
    return false;
  }

  @override
  Future<bool> doneActiveSessionTotem({required String sessionUserId}) async {
    if (sessionProvider.activeSession?.totemUser == sessionUserId) {
      Map<String, dynamic>? update =
          sessionProvider.activeSession?.requestNextUserTotem();
      if (update != null) {
        return await sessionProvider.updateActiveSession(update);
      }
    }
    return false;
  }

  @override
  Future<bool> forceNextActiveSessionTotem() async {
    Map<String, dynamic>? update =
        sessionProvider.activeSession?.requestNextUserTotem();
    if (update != null) {
      return await sessionProvider.updateActiveSession(update);
    }
    return false;
  }

  @override
  Future<bool> removeUserFromSession({required String sessionUserId}) async {
    // first user from the session
    return sessionProvider.removeParticipantFromActiveSession(
        sessionUserId: sessionUserId);
  }

  void _cancelStateUpdates() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  void _startStateUpdates() {
    _updateTimer ??=
        Timer.periodic(const Duration(seconds: notifyDuration), (timer) {
      notifyState();
    });
  }

  Future<void> _assertEngine(bool enableVideo) async {
    if (_engine == null) {
      try {
        PermissionStatus statusValue = PermissionStatus.granted;
        if (!kIsWeb) {
          statusValue = await Permission.bluetooth.request();
          if (statusValue != PermissionStatus.granted &&
              statusValue != PermissionStatus.limited) {
            debugPrint('Failed requesting bluetooth!');
          }
          statusValue = await Permission.bluetoothConnect.request();
          if (statusValue != PermissionStatus.granted &&
              statusValue != PermissionStatus.limited) {
            debugPrint('Failed requesting bluetooth connect!');
          }
          statusValue = await Permission.camera.request();
          if (statusValue != PermissionStatus.granted &&
              statusValue != PermissionStatus.limited) {
            debugPrint('Failed requesting camera!');
          }
          statusValue = await Permission.microphone.request();
          if (statusValue != PermissionStatus.granted &&
              statusValue != PermissionStatus.limited) {
            debugPrint('Failed requesting microphone!');
          }
        }
        if (statusValue == PermissionStatus.granted ||
            statusValue == PermissionStatus.limited) {
          _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
          // enable audio and fancy noise cancelling
          await _engine!.enableAudio();
          await _engine!.setDefaultAudioRouteToSpeakerphone(true);
          await _engine!.enableDeepLearningDenoise(true);
          await _engine!.enableAudioVolumeIndication(200, 3, true);
          await _engine!.setChannelProfile(ChannelProfile.Communication);
          await _engine!.enableDualStreamMode(true);

          // This is a workaround for providing the low bit rate stream parameters
          // to the Agora SDK. For this to work we are using a forked version of
          // the SDK that has a modified web implementation of setParameters to
          // call the appropriate web sdk method.
          Map<String, dynamic> lowParams = {
            "che.video.lowBitRateStreamParameter": {
              "width": systemVideo.lowResSize,
              "height": systemVideo.lowResSize,
              "frameRate": systemVideo.lowResFrameRate,
              "bitRate": systemVideo.lowResBitRate,
            }
          };
          String paramString = jsonEncode(lowParams);
          await _engine!.setParameters(paramString);

          await _engine!.setVideoEncoderConfiguration(
            // Agora recommends setting the video resolution
            VideoEncoderConfiguration(
              frameRate: frameRateFromInt(systemVideo.frameRate),
              bitrate: systemVideo.bitRate,
              dimensions: VideoDimensions(
                  width: systemVideo.videoSize, height: systemVideo.videoSize),
            ),
          );
          bool hasVideoPermission =
              await checkPermissions(PermissionType.video);
          if (enableVideo && hasVideoPermission) {
            await _engine!.enableVideo();
            await _engine!.startPreview();
          }
          // setup event handlers that will let us know about connections
          // and other events
          _engine!.setEventHandler(
            RtcEngineEventHandler(
              audioPublishStateChanged: _handleAudioPublishStateChanged,
              activeSpeaker: _handleActiveSpeaker,
              connectionLost: () {
                debugPrint('connection lost');
              },
              connectionStateChanged: _handleConnectionStateChanged,
              error: _handleSessionError,
              joinChannelSuccess: _handleJoinSession,
              leaveChannel: _handleLeaveSession,
              localAudioStateChanged: _handleLocalAudioStateChanged,
              remoteAudioStateChanged: _handleRemoteAudioStateChanged,
              rejoinChannelSuccess: _handleRejoinChannelSuccess,
              userInfoUpdated: _handleUserInfoUpdated,
              userJoined: _handleUserJoined,
              userOffline: _handleUserOffline,
              audioVolumeIndication: _handleAudioVolumeIndication,
              videoPublishStateChanged: _handleVideoPublishStateChanged,
              remoteVideoStateChanged: _handleRemoteVideoStateChanged,
              networkQuality: _handleNetworkQuality,
            ),
          );
        } else {
          _lastError = CommunicationErrors.noMicrophonePermission;
          _updateState(CommunicationState.failed);
        }
      } catch (ex, stack) {
        // error initializing engine
        await reportError(ex, stack);
        _lastError = CommunicationErrors.communicationError;
        _updateState(CommunicationState.failed);
      }
    }
  }

  void _handleUserInfoUpdated(int uid, UserInfo userInfo) {
    // A user's information has been updated, this should be a mapping
    // of their user id and the user account id provided at join time which is the
    // totem user id.
    debugPrint(
        "Got user update with id: $uid UserInfo: ${userInfo.userAccount}");
  }

  void _handleSessionError(ErrorCode error) {
    _lastError = error.toString();
    if (state != CommunicationState.disconnected) {
      debugPrint('Error handler: ${state.name} - error: ${error.name}');
      switch (error) {
        case ErrorCode.AdmGeneralError:
          debugPrint('error: ${error.name}');
          break;
        case ErrorCode.ConnectionInterrupted:
          // this is a lost connection for more than 4 seconds but less than
          // 10 seconds at which point the connection will be lost.
          debugPrint('error: ${error.name}');
          _networkErrorTimeout ??= Timer.periodic(
              const Duration(seconds: networkTimeoutDuration),
              _handleNetworkTimeout);
          _updateState(CommunicationState.networkConnectivity);
          break;
        case ErrorCode.ConnectionLost:
          // been more than 10 sec since lost network, set state to show connectivity
          // issues in the client and wait to see if the network auto reconnects
          // Need to test to see that it will actually try to reconnect after this
          _networkErrorTimeout ??= Timer.periodic(
              const Duration(seconds: networkTimeoutDuration),
              _handleNetworkTimeout);
          _updateState(CommunicationState.networkConnectivity);
          break;
        // ignore: deprecated_member_use
        case ErrorCode.StartCamera:
          // This seems to be benign like the AdmGeneralError error.
          // also its deprecated so its odd that its being generated.
          debugPrint('error: ${error.name} -> Ignoring');
          break;
        default:
          // all other errors are fatal for now
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(error.name, null,
                reason: 'error from agora session');
          }
          _updateState(CommunicationState.failed);
          break;
      }
    }
  }

  void _handleMuteAllExceptTotem(dynamic messageData) {
    if (sessionProvider.activeSession?.totemParticipant?.sessionUserId !=
            commUid.toString() &&
        !muted) {
      muteAudio(true);
    }
  }

  void _handleRejoinChannelSuccess(String channel, int uid, int elapsedMS) {
    debugPrint(
        'Rejoin success: ${uid.toString()} duration: ${elapsedMS.toString()}');
    _networkErrorTimeout?.cancel();
    _networkErrorTimeout = null;
    if (state != CommunicationState.active) {
      _updateState(CommunicationState.active);
    }
  }

  void _handleNetworkTimeout(Timer timer) {
    _networkErrorTimeout?.cancel();
    _networkErrorTimeout = null;
  }

  void _handleActiveSpeaker(int uid) {
    // handle display / update of status for the current active speaker
    // this is the loudest speaker in the channel
    debugPrint('Current active speaker is now: $uid');
  }

  void _handleAudioPublishStateChanged(String channel,
      StreamPublishState oldState, StreamPublishState newState, int elapsed) {
    debugPrint('audio state changed: $oldState > $newState');
    bool mute = newState == StreamPublishState.NoPublished;
    if (muted != mute) {
      muted = mute;
      sessionProvider.activeSession?.updateMutedStateForUser(
          sessionUserId: commUid.toString(), muted: muted);
      notifyListeners();
      notifyState(directChange: true);
    }
  }

  void _handleVideoPublishStateChanged(String channel,
      StreamPublishState oldState, StreamPublishState newState, int elapsed) {
    debugPrint('video state changed: $oldState > $newState');
    bool muteVideo = newState == StreamPublishState.NoPublished;
    debugPrint('local video muted: $muteVideo');
    if (videoMuted != muteVideo) {
      videoMuted = muteVideo;
      sessionProvider.activeSession?.updateVideoMutedStateForUser(
          sessionUserId: commUid.toString(), muted: videoMuted);
      notifyListeners();
      notifyState(directChange: true);
    }
  }

  void _handleLocalAudioStateChanged(
      AudioLocalState state, AudioLocalError error) async {
    // handles local changes to audio
    debugPrint('local audio state changes: $state');
    if (error != AudioLocalError.Ok) {
      debugPrint('local audio state error: ${error.toString()}');
      if (error == AudioLocalError.RecordFailure) {
        if (muted) {
          await _engine!.muteLocalAudioStream(false);
        }
        try {
          await _engine!.enableLocalAudio(false);
          await _engine!.enableLocalAudio(true);
        } catch (ex, stack) {
          debugPrint('Failed resetting local audio $ex');
          await reportError(ex, stack);
        } finally {
          if (muted) {
            await _engine!.muteLocalAudioStream(true);
          }
        }
      }
    }
  }

  void _handleRemoteAudioStateChanged(int uid, AudioRemoteState state,
      AudioRemoteStateReason reason, int elapsed) {
    // handle changes to the audio state for a given user. This will be called
    // when people are muted so that we can register the audio status of that
    // user for display
    if (state == AudioRemoteState.Stopped &&
        reason == AudioRemoteStateReason.RemoteMuted) {
      sessionProvider.activeSession
          ?.updateMutedStateForUser(sessionUserId: uid.toString(), muted: true);
    } else if (state == AudioRemoteState.Decoding &&
        reason == AudioRemoteStateReason.RemoteUnmuted) {
      sessionProvider.activeSession?.updateMutedStateForUser(
          sessionUserId: uid.toString(), muted: false);
    }
    debugPrint(
        'Remote audio state change for user: $uid state: $state reason: $reason');
  }

  void _handleRemoteVideoStateChanged(int uid, VideoRemoteState state,
      VideoRemoteStateReason reason, int elapsed) {
    // handle changes to the audio state for a given user. This will be called
    // when people are muted so that we can register the audio status of that
    // user for display
    debugPrint(
        'local video state changed: $uid state: ${state.name} reason: ${reason.name}');
    if (state == VideoRemoteState.Stopped &&
        reason == VideoRemoteStateReason.RemoteMuted) {
      sessionProvider.activeSession?.updateVideoMutedStateForUser(
          sessionUserId: uid.toString(), muted: true);
    } else if (state == VideoRemoteState.Decoding &&
        reason == VideoRemoteStateReason.RemoteUnmuted) {
      sessionProvider.activeSession?.updateVideoMutedStateForUser(
          sessionUserId: uid.toString(), muted: false);
    }
    debugPrint(
        'Remote video state change for user: $uid state: $state reason: $reason');
  }

  void _handleConnectionStateChanged(
      ConnectionStateType state, ConnectionChangedReason reason) {
    // TODO - handle changes to connection state here
    debugPrint('connection state changed: $state reason: $reason');
    if (state == ConnectionStateType.Reconnecting &&
        reason == ConnectionChangedReason.Interrupted) {
      _networkErrorTimeout ??= Timer.periodic(
          const Duration(seconds: networkTimeoutDuration),
          _handleNetworkTimeout);
      _updateState(CommunicationState.networkConnectivity);
    }
  }

  Future<void> _handleJoinSession(channel, uid, elapsed) async {
    commUid = uid;
    _channel = channel;
    // Update the session to add user information to session display
    await sessionProvider.joinSession(
      session: _session!,
      uid: userId,
      sessionUserId: commUid.toString(),
      sessionImage: _sessionImage,
      muted: muted,
      videoMuted: videoMuted,
    );
    sessionProvider.activeSession
        ?.userJoined(sessionUserId: commUid.toString());
    bool? onSpeaker = await _engine!.isSpeakerphoneEnabled();
    if (onSpeaker != true) {
      await _engine!.setEnableSpeakerphone(true);
    }
/*    _statsStreamId = await _engine
        ?.createDataStreamWithConfig(DataStreamConfig(false, false));
    debugPrint(
        'Created Stats Stream: ${_statsStreamId?.toString() ?? 'failed'}');*/
    // notify any callbacks that the user has joined the session
    if (_handler != null && _handler!.joinedCircle != null) {
      _handler!.joinedCircle!(_session!.id, uid.toString());
    }
    _updateState(CommunicationState.active);

    // Prevent device from going to sleep while the session is active
    unawaited(Wakelock.enable());

    // for android, start a foreground service to keep the process running
    // to prevent drops in connection
    if (!kIsWeb && Platform.isAndroid) {
      await SessionForeground.instance.startSessionTask();
    }
    // notify of state to others
    notifyState();
    _startStateUpdates();
  }

  Future<void> _handleLeaveSession(stats) async {
    _cancelStateUpdates();

    // end the data session and update state
    try {
      if (_pendingComplete) {
        await sessionProvider.endActiveSession();
      } else {
        await sessionProvider.leaveSession(
            session: _session!, sessionUid: commUid.toString());
      }
    } on ServiceException catch (ex, stack) {
      // just log this for now
      debugPrint('Got exception trying to leave session: ${ex.toString()}');
      await reportError(ex, stack);
    }
    _pendingComplete = false;
    // update state
    if (_handler != null && _handler!.leaveCircle != null) {
      _handler!.leaveCircle!();
    }
    _handler = null;
    _channel = null;
    // only notify if the user didn't request to leave
    _updateState(CommunicationState.disconnected,
        notify: !_pendingRequestLeave);
  }

  void _handleUserJoined(int user, int elapsed) {
    if (user == commUid) {
      return;
    }
    sessionProvider.activeSession?.userJoined(sessionUserId: user.toString());
    if (sessionProvider.activeSession?.state == SessionState.live) {
      _updateVideoStreamState();
    } else {
      _engine!.setRemoteVideoStreamType(user, VideoStreamType.Low);
    }
    debugPrint('User joined event: $user elapsed $elapsed');
  }

  void _handleUserOffline(int user, UserOfflineReason reason) {
    sessionProvider.activeSession?.userOffline(sessionUserId: user.toString());
    debugPrint('User left: $user reason: $reason');
  }

  void _updateState(CommunicationState newState, {bool notify = true}) {
    if (newState != state) {
      state = newState;
      if (notify) {
        notifyListeners();
      }
    }
  }

  void _handleNetworkQuality(
      int uid, NetworkQuality qualityTx, NetworkQuality qualityRx) {
    // user for display
    uid = uid == 0 ? commUid : uid;
    sessionProvider.activeSession?.updateUnstableNetworkForUser(
        sessionUserId: uid.toString(),
        sample: NetworkSample(
            receive: _networkToValue(qualityRx),
            transmit: _networkToValue(qualityTx)));
  }

  bool isBadConnection(NetworkQuality quality) {
    return quality == NetworkQuality.Bad ||
        quality == NetworkQuality.VBad ||
        quality == NetworkQuality.Down;
  }

  @override
  Future<void> muteAudio(bool mute) async {
    if (mute != muted) {
      await _engine?.muteLocalAudioStream(mute);
      if (state != CommunicationState.active) {
        // reflect the state locally if not in a session
        muted = mute;
        notifyListeners();
        return;
      }
      if (kIsWeb) {
        // FIXME - TEMP - Right now it seems that the
        // audio publishing changes made locally are
        // not coming, so to work around this,
        // call the callback directly to simulate the
        // callback that should come and trigger the state change
        _handleAudioPublishStateChanged(
            _channel ?? "",
            mute
                ? StreamPublishState.Published
                : StreamPublishState.NoPublished,
            mute
                ? StreamPublishState.NoPublished
                : StreamPublishState.Published,
            0);
      }
    }
  }

  void _updateCommunicationFromSession() {
    // check the session state
    ActiveSession? session = sessionProvider.activeSession;
    if (session != null && _session != null) {
      bool updateStreamState = false;
      if (session.state == SessionState.live && !session.userStatus) {
        // have to manage mute state based on changes to the state
        bool started = (_lastState == SessionState.starting &&
            session.state == SessionState.live);
        if (started ||
            session.lastChange == ActiveSessionChange.totemChange ||
            session.lastChange == ActiveSessionChange.totemReceive) {
          updateStreamState = true;
          SessionParticipant? participant = session.totemParticipant;
          if (participant != null) {
            setHasTotem(participant.me);
            muteAudio(!participant.me || !session.totemReceived);
          }
        }
      } else if (session.state == SessionState.cancelled ||
          session.state == SessionState.complete) {
        if (_channel != null) {
          debugPrint('leaving channel after complete/cancel');
          _engine?.leaveChannel();
        }
      }
      if (updateStreamState) {
        debugPrint('updating video stream state for users');
        _updateVideoStreamState();
      }
      _lastState = session.state;
    }
  }

  void _updateVideoStreamState() {
    ActiveSession? session = sessionProvider.activeSession;
    if (session != null) {
      SessionParticipant? totemParticipant = session.totemParticipant;
      String? totemSessionId = totemParticipant?.sessionUserId;
      for (final participant in session.activeParticipants) {
        if (participant.sessionUserId != null && !participant.me) {
          _engine?.setRemoteVideoStreamType(
              int.parse(participant.sessionUserId!),
              participant.sessionUserId == totemSessionId
                  ? VideoStreamType.High
                  : VideoStreamType.Low);
          debugPrint(
              'Setting video stream for ${participant.name} to ${participant.sessionUserId == totemSessionId ? 'high' : 'low'}');
        }
      }
    }
  }

  void _handleAudioVolumeIndication(
      List<AudioVolumeInfo> speakers, int totalVolume) {
    // debugPrint('Audio volume: ${totalVolume.toString()}');
    if (!_isIndicatorStreamOpen) {
      return;
    }
    if (speakers.isNotEmpty) {
      var infos = speakers.map((info) {
        //debugPrint('speaker: ${info.uid.toString()} ${info.vad.toString()}');
        return CommunicationAudioVolumeInfo(
            uid: info.uid, volume: info.volume, speaking: info.vad == 1);
      }).toList();
      _audioIndicatorStreamController?.add(CommunicationAudioVolumeIndication(
          speakers: infos, totalVolume: totalVolume));
    }
  }

  @override
  Stream<CommunicationAudioVolumeIndication> get audioIndicatorStream {
    return _audioIndicatorStreamController!.stream;
  }

  @override
  Future<void> startPreview() async {
    await _engine?.startPreview();
  }

  @override
  Future<void> stopPreview() async {
    await _engine?.stopPreview();
  }

  @override
  Future<void> muteVideo(bool mute) async {
    if (mute != videoMuted) {
      await _engine?.muteLocalVideoStream(mute);
      // Right now it seems that the
      // video publishing changes made locally are
      // not coming, so to work around this,
      // call the callback directly to simulate the
      // callback that should come and trigger the state change
      _handleVideoPublishStateChanged(
          _channel ?? "",
          mute ? StreamPublishState.Published : StreamPublishState.NoPublished,
          mute ? StreamPublishState.NoPublished : StreamPublishState.Published,
          0);
    }
  }

  @override
  dynamic get channelId {
    return _channel;
  }

  @override
  Future<void> setHasTotem(bool hasTotem) async {
    if (_hasTotem != hasTotem) {
      _hasTotem = hasTotem;
    }
  }

  @override
  Future<void> muteAllExceptTotem() async {
    await sessionProvider.muteAllExceptTotem();
  }

  void notifyState({bool directChange = false}) async {
/*    if (useAgoraStream) {
      if (_statsStreamId == null) {
        _statsStreamId = await _engine
            ?.createDataStreamWithConfig(DataStreamConfig(false, false));
        debugPrint(
            'Tried to re-create stream in notifyState: ${_statsStreamId.toString()}');
        if (_statsStreamId == null) {
          return;
        }
      }
      List<int> state = [statsStream, muted ? 1 : 0, videoMuted ? 1 : 0];
      debugPrint('Notify State: ${state.toString()}');
      _engine?.sendStreamMessage(_statsStreamId!, Uint8List.fromList(state));
    }
    if (directChange) {
      sessionProvider.notifyUserStatus(
          userChange: !_stateUpdate,
          sessionUserId: commUid.toString(),
          muted: muted,
          videoMuted: videoMuted);
    } */
  }

  @override
  CommunicationDevice? get audioInput => _audioInput;

  @override
  List<CommunicationDevice> get audioInputs => _audioInputs;

  @override
  List<CommunicationDevice> get audioOutputs => _audioOutputs;

  @override
  CommunicationDevice? get audioOutput => _audioOutput;

  @override
  CommunicationDevice? get camera => _camera;

  @override
  List<CommunicationDevice> get cameras => _cameras;

  @override
  Future<bool> setAudioInput(CommunicationDevice device) async {
    if (_engine == null) return false;
    try {
      if (device != _audioInput) {
        await _engine!.enableLocalAudio(false);
        await _engine!.deviceManager.setAudioRecordingDevice(device.id);
        await _engine!.enableLocalAudio(true);
        _audioInput = device;
        notifyListeners();
      }
      return true;
    } catch (ex, stack) {
      debugPrint('unable to setAudioInput: $ex');
      await reportError(ex, stack);
    }
    return false;
  }

  @override
  Future<bool> setAudioOutput(CommunicationDevice device) async {
    if (_engine == null) return false;
    try {
      if (device != _audioOutput) {
        //await _engine!.enableLocalAudio(false);
        await _engine!.deviceManager.setAudioPlaybackDevice(device.id);
        String? setDev = await _engine!.deviceManager.getAudioPlaybackDevice();
        debugPrint('Set Device: $setDev');
        //await _engine!.enableLocalAudio(true);
        _audioOutput = device;
        notifyListeners();
      }
      return true;
    } catch (ex, stack) {
      debugPrint('unable to setAudioOutput: $ex');
      await reportError(ex, stack);
    }
    return false;
  }

  @override
  Future<bool> setCamera(CommunicationDevice device) async {
    if (_engine == null) return false;
    try {
      if (device != _camera) {
        await _engine!.stopPreview();
        await _engine!.disableVideo();
//        await _engine!.enableLocalVideo(false);
        await _engine!.deviceManager.setVideoDevice(device.id);
//        await _engine!.enableLocalVideo(true);
        await _engine!.enableVideo();
        await _engine!.startPreview();
        _camera = device;
        notifyListeners();
      }
      return true;
    } catch (ex, stack) {
      debugPrint('unable to setCamera: $ex');
      await reportError(ex, stack);
    }
    return false;
  }

  @override
  void endTestAudioInput() {
    if (_engine != null) {}
  }

  @override
  void endTestAudioOutput() {
    if (_engine != null) {
      if (!kIsWeb) {
        _engine!.deviceManager.stopAudioPlaybackDeviceTest();
      }
    }
  }

  @override
  void testAudioInput() {
    if (_engine != null) {}
  }

  @override
  void testAudioOutput() async {
    if (_engine != null) {
      if (!kIsWeb) {
        await _engine!.deviceManager
            .startAudioPlaybackDeviceTest('assets/totemtest.mp3');
      }
    }
  }

  @override
  bool get audioDeviceConfigurable {
    return _audioInput != null || _audioOutput != null;
  }

  @override
  void switchCamera() async {
    if (_engine != null) {
      await _engine!.switchCamera();
    }
  }

  Future<bool> checkPermissions(PermissionType type) async {
    try {
      switch (type) {
        case PermissionType.video:
          if (kIsWeb) {
            List<MediaDeviceInfo> videoDevices =
                await _engine!.deviceManager.enumerateVideoDevices();
            return videoDevices.isNotEmpty &&
                videoDevices[0].deviceId.isNotEmpty;
          } else {
            return Permission.camera.request().isGranted;
          }
        case PermissionType.audio:
          if (kIsWeb) {
            List<MediaDeviceInfo> audioInputDevices =
                await _engine!.deviceManager.enumerateAudioRecordingDevices();
            return audioInputDevices.isNotEmpty &&
                audioInputDevices[0].deviceId.isNotEmpty;
          } else {
            return Permission.microphone.request().isGranted;
          }
      }
    } catch (ex, stack) {
      await reportError(ex, stack);
      return false;
    }
  }

  VideoFrameRate frameRateFromInt(int frameRate) {
    switch (frameRate) {
      case 15:
        return VideoFrameRate.Fps15;
      case 30:
        return VideoFrameRate.Fps30;
      case 60:
        return VideoFrameRate.Fps60;
      case 10:
        return VideoFrameRate.Fps10;
      case 24:
      default:
        return VideoFrameRate.Fps24;
    }
  }

  int _networkToValue(NetworkQuality quality) {
    switch (quality) {
      case NetworkQuality.Excellent:
        return NetworkState.kNetworkQualityExcellent;
      case NetworkQuality.Good:
        return NetworkState.kNetworkQualityGood;
      case NetworkQuality.Poor:
        return NetworkState.kNetworkQualityPoor;
      case NetworkQuality.Bad:
        return NetworkState.kNetworkQualityBad;
      case NetworkQuality.VBad:
        return NetworkState.kNetworkQualityVeryBad;
      case NetworkQuality.Down:
        return NetworkState.kNetworkQualityDown;
      case NetworkQuality.Unknown:
      case NetworkQuality.Detecting:
      default:
        return NetworkState.kNetworkStateUnknown;
    }
  }

  Future<void> _handleMessage(SessionDataMessage? message) async {
    if (message == null) return;
    debugPrint('Received Message: ${message.type.name}');
    try {
      switch (message.type) {
        case CommunicationMessageType.muteAllExceptTotem:
          _handleMuteAllExceptTotem(message.data);
          break;
        default:
          debugPrint('Unknown message type: ${message.type}');
          break;
      }
    } catch (ex, stack) {
      debugPrint('Error decoding stream message: $ex');
      await reportError(ex, stack);
    }
  }
}
