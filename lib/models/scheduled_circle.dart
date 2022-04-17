import 'package:collection/collection.dart';
import 'package:totem/models/index.dart';

class ScheduledCircle extends Circle {
  List<ScheduledSession> sessions = [];
  final SessionState _state = SessionState.idle;
  List<Participant> participants = [];
  bool hasActiveSession = false;

  ScheduledCircle.fromJson(Map<String, dynamic> json,
      {required String id, required String ref, UserProfile? createdUser})
      : super.fromJson(json, id: id, ref: ref, createdUser: createdUser) {
    hasActiveSession = json['activeSession'] != null;
  }

  SessionState get state {
    return _state;
  }

  ScheduledSession? get nextSession {
    /* Review this later when scheduled sessions become a thing
    DateTime now = DateTime.now();
    _state = SessionState.idle;
    if (sessions.isNotEmpty) {
      int index = sessions.indexWhere((element) =>
          element == activeSession || element.scheduledDate.isAfter(now));
      if (index != -1) {
        ScheduledSession session = sessions[index];
        if (session == activeSession) {
          _state = session.state == SessionState.waiting
              ? SessionState.waiting
              : _state = SessionState.live;
        } else {
          Duration duration = session.scheduledDate.difference(now);
          if (duration.inMinutes <= 10) {
            _state = SessionState.pending;
          }
        }
        return session;
      } else {
        _state = SessionState.complete;
      }
    } else if (activeSession != null) {
      _state = SessionState.live;
    } */
    return null;
  }

  @override
  Role participantRole(String participantId) {
    Participant? participant = participants.firstWhereOrNull(
        (element) => element.userProfile.uid == participantId);
    if (participant != null) {
      return participant.role;
    }
    return Role.member;
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = super.toJson();
    return data;
  }
}
