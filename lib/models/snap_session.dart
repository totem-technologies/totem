import 'package:totem/models/index.dart';

class SnapSession extends Session {
  static const String snap = "snap";

  Map<String, Participant> participants = {};
  Map<String, Map<String, dynamic>> participantData = {};

  int get participantCount {
    return participantData.length;
  }

  SnapSession.fromJson(
    Map<String, dynamic> json, {
    required Circle circle,
  }) : super.fromJson(
          json,
          id: circle.id,
          circle: circle,
        ) {
    if (json['participants'] != null) {
      participantData =
          Map<String, Map<String, dynamic>>.from(json['participants']);
    }
  }

  @override
  String get ref {
    return circle.ref;
  }

  @override
  SessionState get state {
    return (circle as SnapCircle).state;
  }

  @override
  set state(SessionState stateVal) {
    (circle as SnapCircle).state = stateVal;
  }

  @override
  Map<String, dynamic> toJson({bool includeParticipants = true}) {
    Map<String, dynamic> data = super.toJson();
    if (includeParticipants) {
      Map<String, Map<String, dynamic>> partData = {};
      for (var key in participants.keys) {
        partData[key] = participants[key]!.toJson();
      }
      data["participants"] = partData;
    }
    return data;
  }
}
