import 'package:totem/models/index.dart';

class SnapCircle extends Circle {
  static const snapSessionId = "snap";

  late SessionState state;
  DateTime? started;
  DateTime? completed;

  SnapCircle.fromJson(
    Map<String, dynamic> json, {
    required String id,
    required String ref,
    UserProfile? createdUser,
    String? uid,
  }) : super.fromJson(
          json,
          id: id,
          ref: ref,
          createdUser: createdUser,
          uid: uid,
        ) {
    if (json['state'] != null) {
      state = SessionState.values.byName(json['state']);
    } else {
      state = SessionState.waiting;
    }
    if (json['activeSession'] != null) {
      activeSession = json['activeSession'];
    }
    started = DateTimeEx.fromMapValue(json['startedDate']);
    completed = DateTimeEx.fromMapValue(json['completedDate']);
  }

  bool get isComplete {
    const completeStates = [
      SessionState.complete,
      SessionState.cancelled,
    ];
    return completeStates.contains(state);
  }

  SnapSession get snapSession {
    return SnapSession.fromJson({}, circle: this);
  }

  @override
  Map<String, dynamic> toJson({bool includeParticipants = true}) {
    Map<String, dynamic> data = super.toJson();
    data["state"] = state.name;
    if (activeSession != null) {
      data['activeSession'] = activeSession;
    }
    return data;
  }
}
