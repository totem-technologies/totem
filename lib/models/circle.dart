import 'package:totem/models/index.dart';
import 'package:universal_html/html.dart';

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
  late String keeper;
  String? previousCircle;
  Map<String, dynamic>? bannedParticipants;
  bool _canJoin = true;

  Circle.fromJson(Map<String, dynamic> json,
      {required this.id,
      required this.ref,
      UserProfile? createdUser,
      this.activeSession,
      String? uid}) {
    name = json['name'] ?? "";
    description = json['description'];
    createdBy = createdUser;
    createdOn = DateTimeEx.fromMapValue(json['createdOn']) ?? DateTime.now();
    updatedOn = DateTimeEx.fromMapValue(json['updatedOn']);
    participantCount = json['participantCount'] ?? 0;
    link = json['link'];
    keeper = json['keeper'];
    previousCircle = json['previousCircle'];
    if (json['bannedParticipants'] != null) {
      bannedParticipants = Map<String, dynamic>.from(json['bannedParticipants']);
    }
    if (uid != null && bannedParticipants != null) {
      _canJoin = bannedParticipants![uid] == null;
    }
  }

  bool get canJoin => _canJoin;

  Role participantRole(String participantId) {
    return keeper == participantId ? Role.keeper : Role.member;
  }

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
    if (bannedParticipants != null) {
      data["bannedParticipants"] = bannedParticipants!;
    }
    return data;
  }
}
