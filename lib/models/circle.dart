import 'package:totem/models/index.dart';

class Circle {
  static const int maxNonKeeperParticipants = 5;
  static const int maxKeeperParticipants = 20;
  static const int minParticipants = 2;

  late final String id;
  late String name;
  String? description;
  int participantCount = 0;
  int maxParticipants = -1;
  int maxMinutes = -1;
  String? themeRef;
  String? imageUrl;
  String? bannerImageUrl;
  bool isPrivate = false;
  late int colorIndex;
  RepeatOptions? repeating;

  Circle.fromJson(
    Map<String, dynamic> json, {
    required this.id,
  }) {
    name = json['name'] ?? "";
    description = json['description'];
    participantCount = json['participantCount'] ?? 0;
    maxParticipants = json['maxParticipants'] ?? -1;
    maxMinutes = json['maxMinutes'] ?? -1;
    themeRef = json['themeRef'];
    imageUrl = json['imageUrl'];
    bannerImageUrl = json['bannerImageUrl'];
    isPrivate = json['isPrivate'] ?? false;
    if (json['repeating'] != null) {
      repeating = RepeatOptions.fromJson(json['repeating']);
    }
    colorIndex = name.hashCode;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "name": name,
      "participantCount": participantCount,
    };
    if (maxParticipants != -1) {
      data["maxParticipants"] = maxParticipants;
    }
    if (description != null) {
      data["description"] = description!;
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
