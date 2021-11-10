import 'package:totem/models/index.dart';

class Participant {
  UserProfile userProfile;
  late Role role;
  DateTime? joined;
  String? sessionUserId;
  String? status;

  Participant.fromJson(Map<String, dynamic> json, {required this.userProfile}) {
    role = Role.fromString(json['role']);
    joined = DateTimeEx.fromMapValue(json['joined']);
    status = json['status'];
    sessionUserId = json["sessionUserId"];
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
