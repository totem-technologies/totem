import 'package:flutter/material.dart';
import 'package:totem/models/index.dart';

class Participant extends ChangeNotifier {
  UserProfile userProfile;
  Role role = Role.member;
  DateTime? joined;
  final bool me;

  Participant.fromJson(Map<String, dynamic> json,
      {required this.userProfile, this.me = false}) {
    if (json['role'] != null) {
      role = Role.values.byName(json['role']);
    }
    joined = DateTimeEx.fromMapValue(json['joined']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "ref": userProfile.ref,
      "role": role.name,
    };
    if (joined != null) {
      data["joined"] = joined;
    }
    return data;
  }
}
