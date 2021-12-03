import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:totem/models/index.dart';
import 'package:totem/models/session.dart';
import 'package:totem/services/communication_provider.dart';
import 'package:totem/services/index.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraCommunicationProvider extends CommunicationProvider {
  static const String appId = "4880737da9bf47e290f46d847cd1c3b1";

  AgoraCommunicationProvider(
      {required this.sessionProvider, required this.userId});

  RtcEngine? _engine;
  CommunicationHandler? _handler;
  int commUid = 0;
  late SessionProvider sessionProvider;
  Session? _session;
  final String userId;
  String? _lastError;
  bool _pendingComplete = false;
  late SessionToken _sessionToken;

  @override
  String? get lastError {
    return _lastError;
  }

  @override
  void dispose() {
    try {
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
  }) async {
    // This is for test purposes, this should be moved
    // to the cloud function that generates a new session at
    // a specific time - this is using a predefined test token that is short lived
    _handler = handler;
    _session = session;
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
  Future<void> leaveSession() async {
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
  Future<bool> updateActiveSessionTotem({required String sessionUserId}) async {
    Map<String, dynamic>? update = sessionProvider.activeSession
        ?.requestUserTotem(nextSessionId: sessionUserId);
    if (update != null) {
      return await sessionProvider.updateActiveSession(update);
    }
    return false;
  }

  Future<void> _assertEngine() async {
    if (_engine == null) {
      try {
        Map<Permission, PermissionStatus> status =
            await [Permission.microphone].request();
        if (status[Permission.microphone] == PermissionStatus.granted ||
            status[Permission.microphone] == PermissionStatus.limited) {
          _engine = await RtcEngine.create(appId);
          // enable audio and fancy noise cancelling
          await _engine!.enableAudio();
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
            ),
          );
        } else {
          _lastError = "errorCommunicationNoMicrophonePermission";
          _updateState(CommunicationState.failed);
        }
      } catch (ex) {
        // error initializing engine
        _lastError = "errorCommunicationError";
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
        session: _session!, uid: userId, sessionUserId: commUid.toString());
    sessionProvider.activeSession
        ?.userJoined(sessionUserId: commUid.toString());
    // notify any callbacks that the user has joined the session
    if (_handler != null && _handler!.joinedCircle != null) {
      _handler!.joinedCircle!(_session!.id, uid.toString());
    }
    await _engine!.setEnableSpeakerphone(true);
    _updateState(CommunicationState.active);
  }

  Future<void> _handleLeaveSession(stats) async {
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
    _updateState(CommunicationState.disconnected);
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

  void _updateState(CommunicationState newState) {
    if (newState != state) {
      state = newState;
      notifyListeners();
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
}
