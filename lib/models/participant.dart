import 'package:flutter/material.dart';
import 'package:totem/models/index.dart';

class Participant extends ChangeNotifier {
  UserProfile userProfile;
  late Role role;
  DateTime? joined;
  final bool me;

  Participant.fromJson(Map<String, dynamic> json,
      {required this.userProfile, this.me = false}) {
    role = Role.fromString(json['role']);
    joined = DateTimeEx.fromMapValue(json['joined']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "ref": userProfile.ref,
      "role": role.toString(),
    };
    if (joined != null) {
      data["joined"] = joined;
    }
    return data;
  }
}
