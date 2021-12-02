import 'package:totem/models/index.dart';

class SnapCircle extends Circle {
  static const snapSessionId = "snap";

  late String state;
  DateTime? started;
  DateTime? completed;

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
    state = json['state'] ?? SessionState.waiting;
    if (json['activeSession'] != null) {
      activeSession = SnapSession.fromJson(json['activeSession'], circle: this);
    }
    started = DateTimeEx.fromMapValue(json['started']);
    completed = DateTimeEx.fromMapValue(json['completed']);
  }

  SnapSession get snapSession {
    return activeSession! as SnapSession;
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
