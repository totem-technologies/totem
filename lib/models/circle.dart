import 'package:totem/models/index.dart';

enum CircleStatus {
  idle,
  preSession,
  active,
  complete,
}

class Circle {
  late String id;
  late String name;
  String? description;
  UserProfile? createdBy;
  late DateTime createdOn;
  DateTime? updatedOn;
  List<Session> sessions = [];
  CircleStatus _status = CircleStatus.idle;
  String? activeSession;

  Circle.fromJson(Map<String, dynamic> json, {required this.id, UserProfile? createdUser}) {
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
      int index = sessions.indexWhere((element) => element.id == activeSession || element.scheduledDate.isAfter(now));
      if (index != -1) {
        Session session = sessions[index];
        if (session.id == activeSession) {
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

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "name": name,
      "createdOn": createdOn
    };
    if (description != null) {
      data["description"] = description!;
    }
    if (updatedOn != null) {
      data["updatedOn"] = updatedOn!;
    }
    return data;
  }
}