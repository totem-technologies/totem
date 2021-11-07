import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:totem/models/index.dart';

class SessionState {
  static const String pending = "pending";
  static const String waiting = "waiting";
  static const String live = "live";
  static const String complete = "complete";
}

class ActiveSession extends ChangeNotifier {
  ActiveSession({required this.session});

  final Session session;
  late List<Participant> participants = [];
  String state = SessionState.pending;
  DateTime? started;

  void updateFromData(Map<String, dynamic> data) {
    state = data['state'] ?? state;
    if (data['participants'] != null) {
      // update list of participants in the session
      participants = data['participants'];
    }
    if (data['started'] != null && started == null) {
      started = DateTimeEx.fromMapValue(data['started']);
    }
    notifyListeners();
  }

  bool participantInSession(String uid) {
    return participants.firstWhereOrNull(
            (participant) => participant.userProfile.uid == uid) !=
        null;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = session.toJson();
    if (started != null) {
      data["started"] = started;
    }
    return data;
  }

  @override
  bool operator ==(other) {
    if (other is! Session && other is! ActiveSession) {
      return false;
    }
    if (other is Session) {
      return other.id == session.id;
    }
    return (other as ActiveSession).session.id == session.id;
  }

  @override
  int get hashCode => session.id.hashCode;
}
