import 'package:totem/models/index.dart';

class SessionParticipant extends Participant {
  bool _muted = false;
  String? sessionUserId;
  String? status;

  SessionParticipant.fromJson(Map<String, dynamic> json,
      {required UserProfile userProfile, bool me = false})
      : super.fromJson(json, userProfile: userProfile, me: me) {
    status = json['status'];
    _muted = json['muted'] ?? false;
    sessionUserId = json["sessionUserId"];
  }

  bool get muted {
    return _muted;
  }

  set muted(bool isMuted) {
    if (_muted != isMuted) {
      _muted = isMuted;
      notifyListeners();
    }
  }
}
