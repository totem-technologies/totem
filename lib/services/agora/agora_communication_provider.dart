import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:totem/models/index.dart';
import 'package:totem/models/session.dart';
import 'package:totem/services/communication_provider.dart';
import 'package:totem/services/index.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraCommunicationProvider extends CommunicationProvider {
  static const String appId = "4880737da9bf47e290f46d847cd1c3b1";

  // FOR TESTING
  // Currently this is a test token and is short lived.
  // Token valid till: 8-nov-20201 @ 5:52PM UTC
  // generated for session id of '
  static const String tokenId =
      "0064880737da9bf47e290f46d847cd1c3b1IADRsXHsREg5T7O5TPEvgjHClfSo9vWM28C0LzcVpnBSxFQp/7cAAAAAEAD3dRUD3FqMYQEAAQDcWoxh";
  // END FOR TESTING

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
      await _engine!.joinChannel(_sessionToken.token, session.id, null, 0);
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
    await _engine?.leaveChannel();
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
          // setup event handlers that will let us know about connections
          // and other events
          _engine!.setEventHandler(
            RtcEngineEventHandler(
              joinChannelSuccess: _handleJoinSession,
              leaveChannel: _handleLeaveSession,
              userJoined: _userJoined,
              userOffline: _userOffline,
              connectionLost: () {
                debugPrint('connection lost');
              },
              error: _handleSessionError,
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

  void _handleSessionError(error) {
    _lastError = error.toString();
    _updateState(CommunicationState.failed);
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
    await _engine!.muteAllRemoteAudioStreams(false);
    await _engine!.muteLocalAudioStream(false);
    await _engine!.setEnableSpeakerphone(true);
    _updateState(CommunicationState.active);
  }

  Future<void> _handleLeaveSession(stats) async {
    // update state
    if (_handler != null && _handler!.leaveCircle != null) {
      _handler!.leaveCircle!();
    }
    if (_pendingComplete) {
      await sessionProvider.endActiveSession();
    } else {
      await sessionProvider.leaveSession(
          session: _session!, sessionUid: commUid.toString());
    }
    _pendingComplete = false;
    _updateState(CommunicationState.disconnected);
    _handler = null;
  }

  void _userJoined(int user, int elapsed) {
    sessionProvider.activeSession?.userJoined(sessionUserId: user.toString());
    debugPrint('User joined event: ' +
        user.toString() +
        " elapsed" +
        elapsed.toString());
  }

  void _userOffline(int user, UserOfflineReason reason) {
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
}
