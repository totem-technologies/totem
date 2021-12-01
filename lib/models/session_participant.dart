import 'package:totem/models/index.dart';

class SessionParticipant extends Participant {
  bool _muted = false;
  String? sessionUserId;
  String? status;
  bool _totem = false;

  SessionParticipant.fromJson(Map<String, dynamic> json,
      {required UserProfile userProfile, bool me = false})
      : super.fromJson(json, userProfile: userProfile, me: me) {
    status = json['status'];
    _muted = json['muted'] ?? false;
    _totem = json['totem'] ?? false;
    sessionUserId = json["sessionUserId"];
  }

  void updateWith(SessionParticipant participant) {
    _totem = participant.totem;
  }

  bool get totem {
    return _totem;
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

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = super.toJson();
    if (sessionUserId != null) {
      data["sessionUserId"] = sessionUserId;
    }
    return data;
  }
}
