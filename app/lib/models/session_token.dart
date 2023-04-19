import 'package:totem/models/index.dart';

class SessionToken {
  late final String token;
  late final DateTime? expires;

  SessionToken.fromJson(Map<String, dynamic> json) {
    token = json["token"] ?? "";
    expires = DateTimeEx.fromMapValue((json["expiration"] ?? 0) * 1000);
  }
}
