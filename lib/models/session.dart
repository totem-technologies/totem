import 'package:totem/models/index.dart';

class Session {
  late final Circle circle;
  late final String id;
  late String topic;
  UserProfile? createdBy;
  late DateTime createdOn;
  DateTime? updatedOn;
  DateTime? startsOn;

  Session.fromJson(Map<String, dynamic> json, {required this.id, required this.circle, this.createdBy}) {
    topic = json['topic'] ?? "";
    createdOn = DateTimeEx.fromMapValue(json['createdOn']) ?? DateTime.now();
    updatedOn = DateTimeEx.fromMapValue(json['updatedOn']);
    startsOn = DateTimeEx.fromMapValue(json['startsOn']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> item = {
      "createdOn": createdOn.toIso8601String(),
      "topic": topic,
    };
    if (updatedOn != null) {
      item["updatedOn"] = updatedOn!.toIso8601String();
    }
    if (startsOn != null) {
      item['startsOn'] = startsOn!.toIso8601String();
    }
    return item;
  }
}