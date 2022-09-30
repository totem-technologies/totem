import 'package:flutter/material.dart';
import 'package:totem/models/index.dart';

class SessionParticipant extends ChangeNotifier {
  bool _muted = false;
  bool _videoMuted = false;
  String? sessionUserId;
  String? status;
  String? sessionImage;
  late String name;
  late String uid;
  Role role = Role.member;
  DateTime? joined;
  late bool me;
  bool _networkUnstable = false;
  final NetworkState _networkState = NetworkState();

  SessionParticipant.from(SessionParticipant participant) {
    me = participant.me;
    joined = participant.joined;
    role = participant.role;
    _muted = participant._muted;
    _videoMuted = participant._videoMuted;
    sessionUserId = participant.sessionUserId;
    name = participant.name;
    uid = participant.uid;
    sessionImage = participant.sessionImage;
    status = participant.status;
    _networkUnstable = participant._networkUnstable;
  }

  SessionParticipant.fromJson(Map<String, dynamic> json, {this.me = false}) {
    uid = json['uid'] ?? "";
    name = json['name'] ?? "";
    status = json['status'];
    if (json['role'] != null) {
      role = Role.values.byName(json['role']);
    }
//    _muted = json['muted'] ?? _muted;
//    _videoMuted = json['videoMuted'] ?? _videoMuted;
    sessionUserId = json["sessionUserId"];
    sessionImage = json["sessionImage"];
  }

  bool get muted {
    return _muted;
  }

  bool get videoMuted {
    return _videoMuted;
  }

  bool get hasImage {
    return sessionImage != null && sessionImage!.isNotEmpty;
  }

  bool get networkUnstable {
    return _networkUnstable;
  }

  bool addNetworkSample(NetworkSample sample) {
    _networkState.addQualitySample(sample);
    bool unstable = _networkState.transmitUnstable;
    if (_networkUnstable != unstable) {
      debugPrint('toggling unstable network:  $unstable');
      _networkUnstable = unstable;
      notifyListeners();
      return true;
    }
    return false;
  }

  set muted(bool isMuted) {
    if (_muted != isMuted) {
      _muted = isMuted;
      notifyListeners();
    }
  }

  set videoMuted(bool isMuted) {
    if (_videoMuted != isMuted) {
      _videoMuted = isMuted;
      notifyListeners();
    }
  }

  void updateFromData(Map<String, dynamic> data) {
    bool changed = false;
    if (sessionImage != data['sessionImage']) {
      changed = true;
      sessionImage = data['sessionImage'];
    }
/*    if (_muted != data['muted']) {
      _muted = data['muted'];
      changed = true;
    }
    if (_videoMuted != data['videoMuted']) {
      _videoMuted = data['videoMuted'];
      changed = true;
    } */
    if (changed) {
      notifyListeners();
    }
  }

  void updateFromParticipant(SessionParticipant participant) {
    bool changed = false;
    if (sessionImage != participant.sessionImage) {
      changed = true;
      sessionImage = participant.sessionImage;
    }
    if (_muted != participant.muted) {
      _muted = participant.muted;
      changed = true;
    }
    if (_videoMuted != participant.videoMuted) {
      _videoMuted = participant.videoMuted;
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "name": name,
      "uid": uid,
      "role": role.name,
      "muted": _muted,
      "videoMuted": _videoMuted,
    };
    if (joined != null) {
      data["joined"] = joined;
    }
    if (sessionUserId != null) {
      data["sessionUserId"] = sessionUserId;
    }
    if (hasImage) {
      // store the image as the session image
      data["sessionImage"] = sessionImage;
    }
    return data;
  }

  @override
  bool operator ==(other) {
    if (other is! SessionParticipant) {
      return false;
    }
    return other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
