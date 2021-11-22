import 'package:totem/models/index.dart';

class Session {
  late final String id;
  late final Circle circle;
  late String topic;
  late String state;

  String get ref {
    return "";
  }

  Session.fromJson(Map<String, dynamic> json,
      {required this.id, required this.circle}) {
    topic = json['topic'] ?? "";
    state = json['state'] ?? SessionState.pending;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> item = {
      "topic": topic,
      "state": state,
    };
    return item;
  }

  @override
  bool operator ==(other) {
    if (other is! Session) {
      return false;
    }
    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
