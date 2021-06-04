import 'package:flutter/foundation.dart';

@immutable
class Topic {
  final String title;
  final String description;

  Topic({required this.title, required this.description});

  Topic.fromJson(Map<String, Object?> json)
      : title = json['title']! as String,
        description = json['description']! as String;

  Map<String, Object?> toJson() => {
        'title': title,
        'description': description,
      };
}
