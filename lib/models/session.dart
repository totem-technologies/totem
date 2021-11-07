import 'package:totem/models/index.dart';

class Session {
  late final Circle circle;
  late final String id;
  late final String ref;
  late String topic;
  late DateTime scheduledDate;

  Session.fromJson(Map<String, dynamic> json,
      {required this.id, required this.ref, required this.circle}) {
    topic = json['topic'] ?? "";
    scheduledDate = DateTimeEx.fromMapValue(json['scheduledDate'])!;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> item = {
      "topic": topic,
      "scheduledData": scheduledDate,
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
