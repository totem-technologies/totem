import 'dart:io';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';

class AgoraCommunicationProvider extends CommunicationProvider {
  static const String appId = "4880737da9bf47e290f46d847cd1c3b1";

  AgoraCommunicationProvider(
      {required this.sessionProvider, required this.userId}) {
    sessionProvider.addListener(_updateCommunicationFromSession);
  }

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

  @override
  String? get lastError {
    return _lastError;
  }

  @override
  void dispose() {
    try {
      sessionProvider.removeListener(_updateCommunicationFromSession);
      _engine?.destroy();
      _engine = null;
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
  }) async {
    // This is for test purposes, this should be moved
    // to the cloud function that generates a new session at
    // a specific time - this is using a predefined test token that is short lived
    _sessionImage = sessionImage;
    _handler = handler;
    _session = session;
    _lastError = null;
    _updateState(CommunicationState.joining);
    try {
      await _assertEngine();
      // TODO - Call SessionProvider to get token for current session
      // This will hit the server which will generate a token for the user
      // this is currently using the test token
      _sessionToken =
          await sessionProvider.requestSessionToken(session: session);
      await _engine!
          .joinChannelWithUserAccount(_sessionToken.token, session.id, userId);
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

  Future<void> _assertEngine() async {
    if (_engine == null) {
      try {
        PermissionStatus statusValue = await Permission.microphone.request();
        if (statusValue == PermissionStatus.granted ||
            statusValue == PermissionStatus.limited) {
          _engine = await RtcEngine.create(appId);
          // enable audio and fancy noise cancelling
          await _engine!.enableAudio();
          await _engine!.setDefaultAudioRoutetoSpeakerphone(true);
          await _engine!.enableDeepLearningDenoise(true);
          await _engine!.enableAudioVolumeIndication(200, 3, true);
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
    if (Platform.isAndroid) {
      SessionForeground.instance.startSessionTask();
    }
  }

  Future<void> _handleLeaveSession(stats) async {
    // for android, start a foreground service to keep the process running
    // to prevent drops in connection
    if (Platform.isAndroid) {
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
            muteAudio(!participant.me || !session.totemReceived);
          }
        }
      }
      _lastState = session.state;
    }
  }

  void _handleAudioVolumeIndication(
      List<AudioVolumeInfo> speakers, int totalVolume) {
    // TODO - handle volume indication
  }
}
