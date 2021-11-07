import 'package:collection/collection.dart';
import 'package:totem/models/index.dart';

enum CircleStatus {
  idle,
  preSession,
  active,
  complete,
}

class Circle {
  late final String id;
  late String name;
  late final String ref;

  String? description;
  UserProfile? createdBy;
  late DateTime createdOn;
  DateTime? updatedOn;
  List<Session> sessions = [];
  CircleStatus _status = CircleStatus.idle;
  List<Participant> participants = [];
  Session? activeSession;

  Circle.fromJson(Map<String, dynamic> json,
      {required this.id, required this.ref, UserProfile? createdUser}) {
    name = json['name'] ?? "";
    description = json['description'];
    createdBy = createdUser;
    createdOn = DateTimeEx.fromMapValue(json['createdOn']) ?? DateTime.now();
    updatedOn = DateTimeEx.fromMapValue(json['updatedOn']);
  }

  CircleStatus get status {
    return _status;
  }

  Session? get nextSession {
    DateTime now = DateTime.now();
    _status = CircleStatus.idle;
    if (sessions.isNotEmpty) {
      int index = sessions.indexWhere((element) =>
          element == activeSession || element.scheduledDate.isAfter(now));
      if (index != -1) {
        Session session = sessions[index];
        if (session == activeSession) {
          _status = CircleStatus.active;
        } else {
          Duration duration = session.scheduledDate.difference(now);
          if (duration.inMinutes <= 10) {
            _status = CircleStatus.preSession;
          }
        }
        return session;
      }
    }
    return null;
  }

  Role participantRole(String participantId) {
    Participant? participant = participants.firstWhereOrNull(
        (element) => element.userProfile.uid == participantId);
    if (participant != null) {
      return participant.role;
    }
    return Roles.member;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {"name": name, "createdOn": createdOn};
    if (description != null) {
      data["description"] = description!;
    }
    if (updatedOn != null) {
      data["updatedOn"] = updatedOn!;
    }
    return data;
  }
}
