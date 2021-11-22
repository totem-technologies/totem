import 'package:collection/collection.dart';
import 'package:totem/models/index.dart';

enum CircleStatus {
  idle,
  preSession,
  waiting,
  active,
  complete,
}

class ScheduledCircle extends Circle {
  List<ScheduledSession> sessions = [];
  CircleStatus _status = CircleStatus.idle;
  List<Participant> participants = [];
  bool hasActiveSession = false;

  ScheduledCircle.fromJson(Map<String, dynamic> json,
      {required String id, required String ref, UserProfile? createdUser})
      : super.fromJson(json, id: id, ref: ref, createdUser: createdUser) {
    hasActiveSession = json['activeSession'] != null;
  }

  CircleStatus get status {
    return _status;
  }

  ScheduledSession? get nextSession {
    DateTime now = DateTime.now();
    _status = CircleStatus.idle;
    if (sessions.isNotEmpty) {
      int index = sessions.indexWhere((element) =>
          element == activeSession || element.scheduledDate.isAfter(now));
      if (index != -1) {
        ScheduledSession session = sessions[index];
        if (session == activeSession) {
          _status = session.state == SessionState.waiting
              ? CircleStatus.waiting
              : _status = CircleStatus.active;
        } else {
          Duration duration = session.scheduledDate.difference(now);
          if (duration.inMinutes <= 10) {
            _status = CircleStatus.preSession;
          }
        }
        return session;
      } else {
        _status = CircleStatus.complete;
      }
    } else if (activeSession != null) {
      _status = activeSession!.state == SessionState.waiting
          ? CircleStatus.waiting
          : _status = CircleStatus.active;
    }
    return null;
  }

  @override
  Role participantRole(String participantId) {
    Participant? participant = participants.firstWhereOrNull(
        (element) => element.userProfile.uid == participantId);
    if (participant != null) {
      return participant.role;
    }
    return Roles.member;
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = super.toJson();
    return data;
  }
}
