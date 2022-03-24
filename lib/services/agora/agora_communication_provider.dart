import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';

class AgoraCommunicationProvider extends CommunicationProvider {
  static const String appId = "4880737da9bf47e290f46d847cd1c3b1";

  // These are used as default values for the video preview, modify
  // as needed to define a different default as these get set on the engine
  static const int videoHeight = 180;
  static const int videoWidth = 180;

  AgoraCommunicationProvider(
      {required this.sessionProvider, required this.userId}) {
    sessionProvider.addListener(_updateCommunicationFromSession);
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
  late Size _fullscreenSize;

  @override
  String? get lastError {
    return _lastError;
  }

  @override
  void dispose() {
    _channel = null;
    try {
      sessionProvider.removeListener(_updateCommunicationFromSession);
      _engine?.destroy();
      _engine = null;
      _audioIndicatorStreamController?.close();
      super.dispose();
    } catch (ex) {
      debugPrint("unable to break down engine: " + ex.toString());
    }
  }

  @override
  Future<bool> joinSession({
    required Session session,
    required CommunicationHandler handler,
    String? sessionImage,
    bool enableVideo = false,
    required Size fullScreenSize,
  }) async {
    _fullscreenSize = fullScreenSize;
    _sessionImage = sessionImage;
    _handler = handler;
    _session = session;
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
      // TODO - Call SessionProvider to get token for current session
      // This will hit the server which will generate a token for the user
      // this is currently using the test token
      if (!kIsWeb) {
        await _engine!.registerLocalUserAccount(appId, userId);
        _sessionToken =
            await sessionProvider.requestSessionToken(session: session);
        await _engine!.joinChannelWithUserAccount(
            _sessionToken.token, session.id, userId);
      } else {
        int uid = Random().nextInt(100000);
        _sessionToken = await sessionProvider.requestSessionTokenWithUID(
            session: session, uid: uid);
        await _engine!.joinChannel(_sessionToken.token, session.id, null, uid);
      }
    } catch (ex) {
      debugPrint('unable to activate agora session: ' + ex.toString());
      _updateState(CommunicationState.failed);
    }
    return false;
  }

  @override
  Future<void> leaveSession({bool requested = true}) async {
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
          statusValue = await Permission.microphone.request();
        }
        if (statusValue == PermissionStatus.granted ||
            statusValue == PermissionStatus.limited) {
          _engine = await RtcEngine.create(appId);
          // enable audio and fancy noise cancelling
          await _engine!.enableAudio();
          await _engine!.setDefaultAudioRoutetoSpeakerphone(true);
          await _engine!.enableDeepLearningDenoise(true);
          await _engine!.enableAudioVolumeIndication(200, 3, true);
          if (enableVideo) {
            await _engine!.setVideoEncoderConfiguration(
                VideoEncoderConfiguration(
                    dimensions: VideoDimensions(
                        width: videoWidth, height: videoHeight)));
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
              userInfoUpdated: _handleUserInfoUpdated,
              userJoined: _handleUserJoined,
              userOffline: _handleUserOffline,
              audioVolumeIndication: _handleAudioVolumeIndication,
              videoPublishStateChanged: _handleVideoPublishStateChanged,
              remoteVideoStateChanged: _handleRemoteVideoStateChanged,
            ),
          );
        } else {
          _lastError = CommunicationErrors.noMicrophonePermission;
          _updateState(CommunicationState.failed);
        }
      } catch (ex) {
        // error initializing engine
        _lastError = CommunicationErrors.communicationError;
        _updateState(CommunicationState.failed);
      }
    }
  }

  void _handleUserInfoUpdated(int uid, UserInfo userInfo) {
    // A user's information has been updated, this should be a mapping
    // of their user id and the user account id provided at join time which is the
    // totem user id.
    debugPrint('Got user update with id: ' +
        uid.toString() +
        " UserInfo: " +
        userInfo.userAccount);
  }

  void _handleSessionError(error) {
    _lastError = error.toString();
    _updateState(CommunicationState.failed);
  }

  void _handleActiveSpeaker(int uid) {
    // handle display / update of status for the current active speaker
    // this is the loudest speaker in the channel
    debugPrint('Current active speaker is now: ' + uid.toString());
  }

  void _handleAudioPublishStateChanged(String channel,
      StreamPublishState oldState, StreamPublishState newState, int elapsed) {
    debugPrint('audio state changed: ' +
        oldState.toString() +
        " > " +
        newState.toString());
    bool _mute = newState == StreamPublishState.NoPublished;
    if (muted != _mute) {
      muted = _mute;
      sessionProvider.activeSession?.updateMutedStateForUser(
          sessionUserId: commUid.toString(), muted: muted);
      notifyListeners();
    }
  }

  void _handleVideoPublishStateChanged(String channel,
      StreamPublishState oldState, StreamPublishState newState, int elapsed) {
    debugPrint('video state changed: ' +
        oldState.toString() +
        " > " +
        newState.toString());
    bool _muteVideo = newState == StreamPublishState.NoPublished;
    if (videoMuted != _muteVideo) {
      videoMuted = _muteVideo;
      notifyListeners();
    }
  }

  void _handleLocalAudioStateChanged(
      AudioLocalState state, AudioLocalError error) {
    // handles local changes to audio
    debugPrint('local audio state changes: ' + state.toString());
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
    debugPrint('Remote audio state change for user: ' +
        uid.toString() +
        ' state: ' +
        state.toString() +
        ' reason: ' +
        reason.toString());
  }

  void _handleRemoteVideoStateChanged(int uid, VideoRemoteState state,
      VideoRemoteStateReason reason, int elapsed) {
    // handle changes to the audio state for a given user. This will be called
    // when people are muted so that we can register the audio status of that
    // user for display
    if (state == VideoRemoteState.Stopped &&
        reason == VideoRemoteStateReason.RemoteMuted) {
      sessionProvider.activeSession?.updateVideoMutedStateForUser(
          sessionUserId: uid.toString(), muted: true);
    } else if (state == VideoRemoteState.Decoding &&
        reason == VideoRemoteStateReason.RemoteUnmuted) {
      sessionProvider.activeSession?.updateVideoMutedStateForUser(
          sessionUserId: uid.toString(), muted: false);
    }
    debugPrint('Remote video state change for user: ' +
        uid.toString() +
        ' state: ' +
        state.toString() +
        ' reason: ' +
        reason.toString());
  }

  void _handleConnectionStateChanged(
      ConnectionStateType state, ConnectionChangedReason reason) {
    // TODO - handle changes to connection state here
    debugPrint('connection state changed: ' +
        state.toString() +
        ' reason: ' +
        reason.toString());
  }

  Future<void> _handleJoinSession(channel, uid, elapsed) async {
    commUid = uid;
    _channel = channel;
    // Update the session to add user information to session display
    await sessionProvider.joinSession(
        session: _session!,
        uid: userId,
        sessionUserId: commUid.toString(),
        sessionImage: _sessionImage);
    sessionProvider.activeSession
        ?.userJoined(sessionUserId: commUid.toString());
    bool? onSpeaker = await _engine!.isSpeakerphoneEnabled();
    if (onSpeaker != true) {
      await _engine!.setEnableSpeakerphone(true);
    }

    // notify any callbacks that the user has joined the session
    if (_handler != null && _handler!.joinedCircle != null) {
      _handler!.joinedCircle!(_session!.id, uid.toString());
    }
    _updateState(CommunicationState.active);

    // for android, start a foreground service to keep the process running
    // to prevent drops in connection
    if (!kIsWeb && Platform.isAndroid) {
      SessionForeground.instance.startSessionTask();
    }
  }

  Future<void> _handleLeaveSession(stats) async {
    // for android, start a foreground service to keep the process running
    // to prevent drops in connection
    if (!kIsWeb && Platform.isAndroid) {
      SessionForeground.instance.stopSessionTask();
    }

    // end the data session and update state
    try {
      if (_pendingComplete) {
        await sessionProvider.endActiveSession();
      } else {
        await sessionProvider.leaveSession(
            session: _session!, sessionUid: commUid.toString());
      }
    } on ServiceException catch (ex) {
      // just log this for now
      debugPrint('Got exception trying to leave session: ${ex.toString()}');
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
    sessionProvider.activeSession?.userJoined(sessionUserId: user.toString());
    debugPrint('User joined event: ' +
        user.toString() +
        " elapsed" +
        elapsed.toString());
  }

  void _handleUserOffline(int user, UserOfflineReason reason) {
    sessionProvider.activeSession?.userOffline(sessionUserId: user.toString());
    debugPrint(
        'User left: ' + user.toString() + " reason: " + reason.toString());
  }

  void _updateState(CommunicationState newState, {bool notify = true}) {
    if (newState != state) {
      state = newState;
      if (notify) {
        notifyListeners();
      }
    }
  }

  @override
  Future<void> muteAudio(bool mute) async {
    if (state == CommunicationState.active) {
      if (mute != muted) {
        _engine?.muteLocalAudioStream(mute);
        if (kIsWeb) {
          // FIXME - TEMP - Right now it seems that the
          // audio publishing changes made locally are
          // not coming, so to work around this,
          // call the callback directly to simulate the
          // callback that should come and trigger the state change
          _handleAudioPublishStateChanged(
              _channel,
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
  }

  void _updateCommunicationFromSession() {
    // check the session state
    ActiveSession? session = sessionProvider.activeSession;
    if (session != null) {
      if (session.state == SessionState.live) {
        // have to manage mute state based on changes to the state
        bool started = (_lastState == SessionState.starting &&
            session.state == SessionState.live);
        if (started ||
            session.lastChange == ActiveSessionChange.totemChange ||
            session.lastChange == ActiveSessionChange.totemReceive) {
          SessionParticipant? participant = session.totemParticipant;
          if (participant != null) {
            setHasTotem(participant.me);
            muteAudio(!participant.me || !session.totemReceived);
          }
        }
      }
      _lastState = session.state;
    }
  }

  void _handleAudioVolumeIndication(
      List<AudioVolumeInfo> speakers, int totalVolume) {
    debugPrint('Audio volume: ${totalVolume.toString()}');
    if (!_isIndicatorStreamOpen) {
      return;
    }

    var infos = speakers.map((info) {
      debugPrint('speaker: ${info.uid.toString()} ${info.vad.toString()}');
      return CommunicationAudioVolumeInfo(
          uid: info.uid, volume: info.volume, speaking: info.vad == 1);
    }).toList();
    _audioIndicatorStreamController?.add(CommunicationAudioVolumeIndication(
        speakers: infos, totalVolume: totalVolume));
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
    if (state == CommunicationState.active) {
      if (mute != videoMuted) {
        await _engine?.muteLocalVideoStream(mute);
        // FIXME - TEMP - Right now it seems that the
        // video publishing changes made locally are
        // not coming, so to work around this,
        // call the callback directly to simulate the
        // callback that should come and trigger the state change
        _handleVideoPublishStateChanged(
            _channel,
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

  @override
  dynamic get channelId {
    return _channel;
  }

  @override
  Future<void> setHasTotem(bool hasTotem) async {
    if (_hasTotem != hasTotem) {
      _hasTotem = hasTotem;
      await _engine!.setVideoEncoderConfiguration(VideoEncoderConfiguration(
          dimensions: VideoDimensions(
              width: _hasTotem ? _fullscreenSize.width.toInt() : videoWidth,
              height:
                  _hasTotem ? _fullscreenSize.height.toInt() : videoHeight)));
    }
  }
}
