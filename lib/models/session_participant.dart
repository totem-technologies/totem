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
  bool me;

  SessionParticipant.fromJson(Map<String, dynamic> json, {this.me = false}) {
    uid = json['uid'] ?? "";
    name = json['name'] ?? "";
    status = json['status'];
    if (json['role'] != null) {
      for (var element in Role.values) {
        debugPrint(element.name);
      }
      role = Role.values.byName(json['role']);
    }
    _videoMuted = json['videoMuted'] ?? false;
    sessionUserId = json["sessionUserId"];
    sessionImage = json["sessionImage"];
  }

  void updateWith(SessionParticipant participant) {}

  bool get muted {
    return _muted;
  }

  bool get videoMuted {
    return _videoMuted;
  }

  bool get hasImage {
    return sessionImage != null && sessionImage!.isNotEmpty;
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

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "name": name,
      "uid": uid,
      "role": role.name,
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
