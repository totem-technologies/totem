import 'package:flutter/foundation.dart';

@immutable
class UserCircle {
  final String circle;
  final String user;

  UserCircle({required this.circle, required this.user});

  UserCircle.fromJson(Map<String, Object?> json)
      : circle = json['circle']! as String,
        user = json['user']! as String;

  Map<String, Object?> toJson() => {
        'circle': circle,
        'user': user,
      };
}
