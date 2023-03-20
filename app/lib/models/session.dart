import 'package:totem/models/index.dart';

class Session {
  late final String id;
  late final Circle circle;
  late String topic;
  Map<String, Participant> participants = {};
  Map<String, Map<String, dynamic>> participantData = {};

  SessionState get state {
    return circle.state;
  }

  set state(SessionState stateVal) {
    circle.state = stateVal;
  }

  int get participantCount {
    return participantData.length;
  }

  String get ref {
    return circle.ref;
  }

  Session.fromJson(Map<String, dynamic> json,
      {required this.id, required this.circle}) {
    topic = json['topic'] ?? "";
    if (json['participants'] != null) {
      participantData =
          Map<String, Map<String, dynamic>>.from(json['participants']);
    }
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

  Map<String, dynamic> toJson({bool includeParticipants = true}) {
    Map<String, dynamic> item = {
      "topic": topic,
      "state": state.name,
    };
    if (includeParticipants) {
      Map<String, Map<String, dynamic>> partData = {};
      for (var key in participants.keys) {
        partData[key] = participants[key]!.toJson();
      }
      item["participants"] = partData;
    }
    return item;
  }
}
