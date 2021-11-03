import 'package:totem/models/index.dart';

class Session {
  late final Circle circle;
  late final String id;
  late String topic;
  late DateTime scheduledDate;

  Session.fromJson(Map<String, dynamic> json, {required this.id, required this.circle}) {
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
}