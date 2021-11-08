import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:totem/models/session.dart';
import 'package:totem/services/communication_provider.dart';
import 'package:totem/services/index.dart';

class AgoraCommunicationProvider extends CommunicationProvider {
  static const String appId = "4880737da9bf47e290f46d847cd1c3b1";

  // FOR TESTING
  // Currently this is a test token and is short lived.
  // Token valid till: 8-nov-20201 @ 5:52PM UTC
  static const String tokenId =
      "0064880737da9bf47e290f46d847cd1c3b1IADPQarAx4XXAm7aFYIutDZTH+5ofRzp4yxFgE/m8aRujFQp/7cAAAAAEAD3dRUDetaKYQEAAQB61oph";
  // This can be removed once a cloud function is enabled to generate tokens
  // based on the session id
  static const String channelName = "channel_test";
  // END FOR TESTING

  AgoraCommunicationProvider(
      {required this.sessionProvider, required this.userId});

  RtcEngine? _engine;
  CommunicationHandler? _handler;
  int commUid = 0;
  late SessionProvider sessionProvider;
  Session? _session;
  final String userId;
  ErrorCode? _lastError;

  @override
  String? get lastError {
    return _lastError?.toString();
  }

  @override
  void dispose() {
    try {
      _engine?.destroy();
      _engine = null;
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
      // this is currently using the test token/channelName
      await _engine!.joinChannel(tokenId, session.id, null, 0);
    } catch (ex) {
      debugPrint('unable to activate agora session: ' + ex.toString());
      _updateState(CommunicationState.disconnected);
    }
    return false;
  }

  @override
  Future<void> leaveSession() async {
    await _engine?.leaveChannel();
  }

  @override
  Future<void> endSession() async {
    // need to see if there is another call for
    // session owner to end for all?
    await _engine?.leaveChannel();
  }

  Future<void> _assertEngine() async {
    if (_engine == null) {
      _engine = await RtcEngine.create(appId);
      await _engine!.enableAudio();
      _engine!.setEventHandler(RtcEngineEventHandler(
          joinChannelSuccess: (channel, uid, elapsed) async {
        commUid = uid;
        // Update the session to add user information to session display
        await sessionProvider.joinSession(
            session: _session!, uid: userId, sessionUserId: commUid.toString());
        // notify any callbacks that the user has joined the session
        if (_handler != null && _handler!.joinedCircle != null) {
          _handler!.joinedCircle!(_session!.id, uid.toString());
        }
        _engine!.muteAllRemoteAudioStreams(false);
        _engine!.muteLocalAudioStream(false);
        _updateState(CommunicationState.active);
      }, leaveChannel: (stats) async {
        // update state
        if (_handler != null && _handler!.leaveCircle != null) {
          _handler!.leaveCircle!();
        }
        _updateState(CommunicationState.disconnected);
        _handler = null;
      }, error: (error) {
        _lastError = error;
        _updateState(CommunicationState.failed);
      }));
    }
  }

  void _updateState(CommunicationState newState) {
    if (newState != state) {
      state = newState;
      notifyListeners();
    }
  }
}
