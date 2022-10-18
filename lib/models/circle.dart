import 'package:totem/models/index.dart';

abstract class Circle {
  static const int maxNonKeeperParticipants = 5;
  static const int maxKeeperParticipants = 20;
  static const int minParticipants = 2;

  late final String id;
  late String name;
  late final String ref;

  String? description;
  UserProfile? createdBy;
  late DateTime createdOn;
  DateTime? updatedOn;
  String? activeSession;
  int participantCount = 0;
  int maxParticipants = -1;
  String? link;
  late String keeper;
  String? previousCircle;
  Map<String, dynamic>? bannedParticipants;
  String? themeRef;
  String? imageUrl;
  String? bannerImageUrl;
  bool isPrivate = false;
  late int colorIndex;
  DateTime? nextSession;

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
    maxParticipants = json['maxParticipants'] ?? -1;
    link = json['link'];
    keeper = json['keeper'];
    previousCircle = json['previousCircle'];
    themeRef = json['themeRef'];
    imageUrl = json['imageUrl'];
    bannerImageUrl = json['bannerImageUrl'];
    isPrivate = json['isPrivate'] ?? false;
    if (json['bannedParticipants'] != null) {
      bannedParticipants =
          Map<String, dynamic>.from(json['bannedParticipants']);
    }
    if (uid != null && bannedParticipants != null) {
      _canJoin = bannedParticipants![uid] == null;
    }
    nextSession = DateTimeEx.fromMapValue(json['nextSession']);
    colorIndex = name.hashCode;
  }

  bool get canJoin => _canJoin;

  Role participantRole(String participantId) {
    return keeper == participantId ? Role.keeper : Role.member;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "name": name,
      "createdOn": createdOn,
      "participantCount": participantCount,
    };
    if (maxParticipants != -1) {
      data["maxParticipants"] = maxParticipants;
    }
    if (description != null) {
      data["description"] = description!;
    }
    if (updatedOn != null) {
      data["updatedOn"] = updatedOn!;
    }
    if (bannedParticipants != null) {
      data["bannedParticipants"] = bannedParticipants!;
    }
    if (themeRef != null) {
      data["themeRef"] = themeRef!;
    }
    if (imageUrl != null) {
      data["imageUrl"] = imageUrl!;
    }
    if (bannerImageUrl != null) {
      data["bannerImageUrl"] = bannerImageUrl!;
    }
    return data;
  }
}
