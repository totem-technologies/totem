import 'package:totem/models/index.dart';

abstract class Session {
  late final String id;
  late final Circle circle;
  late String topic;

  String get ref {
    return "";
  }

  SessionState get state;
  set state(SessionState stateVal);

  Session.fromJson(Map<String, dynamic> json,
      {required this.id, required this.circle}) {
    topic = json['topic'] ?? "";
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> item = {
      "topic": topic,
      "state": state.name,
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
