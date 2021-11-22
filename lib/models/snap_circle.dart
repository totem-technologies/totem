import 'package:totem/models/index.dart';

class SnapCircle extends Circle {
  static const snapSessionId = "snap";
  static const String stateActive = "active";
  static const String stateComplete = "complete";

  late String state;

  SnapCircle.fromJson(
    Map<String, dynamic> json, {
    required String id,
    required String ref,
    UserProfile? createdUser,
  }) : super.fromJson(
          json,
          id: id,
          ref: ref,
          createdUser: createdUser,
        ) {
    state = json['state'] ?? stateActive;
    if (json['activeSession'] != null) {
      activeSession = SnapSession.fromJson(json['activeSession'], circle: this);
    }
  }

  String get status {
    return activeSession?.state ?? SessionState.pending;
  }

  @override
  Role participantRole(String participantId) {
    if (createdBy != null && createdBy!.uid == participantId) {
      return Roles.keeper;
    }
    return Roles.member;
  }

  @override
  Map<String, dynamic> toJson({bool includeParticipants = true}) {
    Map<String, dynamic> data = super.toJson();
    data["state"] = state;
    if (activeSession != null) {
      data['activeSession'] = (activeSession! as SnapSession)
          .toJson(includeParticipants: includeParticipants);
    }
    return data;
  }
}
