import 'package:totem/models/index.dart';

abstract class Circle {
  late final String id;
  late String name;
  late final String ref;

  String? description;
  UserProfile? createdBy;
  late DateTime createdOn;
  DateTime? updatedOn;
  String? activeSession;
  int participantCount = 0;
  String? link;
  String? keeper;
  String? previousCircle;

  Circle.fromJson(Map<String, dynamic> json,
      {required this.id,
      required this.ref,
      UserProfile? createdUser,
      this.activeSession}) {
    name = json['name'] ?? "";
    description = json['description'];
    createdBy = createdUser;
    createdOn = DateTimeEx.fromMapValue(json['createdOn']) ?? DateTime.now();
    updatedOn = DateTimeEx.fromMapValue(json['updatedOn']);
    participantCount = json['participantCount'] ?? 0;
    link = json['link'];
    keeper = json['keeper'];
    previousCircle = json['previousCircle'];
  }

  Role participantRole(String participantId);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "name": name,
      "createdOn": createdOn,
      "participantCount": participantCount
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
