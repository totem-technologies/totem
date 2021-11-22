import 'package:totem/models/index.dart';

class SnapSession extends Session {
  static const String snap = "snap";

  late DateTime started;
  List<Participant> participants = [];

  SnapSession.fromJson(
    Map<String, dynamic> json, {
    required Circle circle,
  }) : super.fromJson(
          json,
          id: circle.id,
          circle: circle,
        ) {
    started = DateTimeEx.fromMapValue(json['started'])!;
  }

  @override
  String get ref {
    return circle.ref;
  }

  @override
  Map<String, dynamic> toJson({bool includeParticipants = true}) {
    Map<String, dynamic> data = super.toJson();
    data["started"] = started;
    if (includeParticipants) {
      List<Map<String, dynamic>> partData = [];
      for (var participant in participants) {
        partData.add(participant.toJson());
      }
      data["participants"] = partData;
    }
    return data;
  }
}
