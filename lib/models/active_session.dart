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
  List<Participant> activeParticipants = [];
  final List<String> _pendingUserAdded = [];

  void updateFromData(Map<String, dynamic> data) {
    state = data['state'] ?? state;
    if (data['participants'] != null) {
      // update list of participants in the session
      participants = data['participants'];
    }
    if (data['started'] != null && started == null) {
      started = DateTimeEx.fromMapValue(data['started']);
    }
    if (_pendingUserAdded.isNotEmpty) {
      List<String> pending = List<String>.from(_pendingUserAdded);
      for (var element in pending) {
        userJoined(sessionUserId: element, pending: true);
      }
    }
    notifyListeners();
  }

  bool userJoined({required String sessionUserId, bool pending = false}) {
    Participant? participant = activeParticipants
        .firstWhereOrNull((element) => element.sessionUserId == sessionUserId);
    if (participant != null) {
      // already in the active list
      return true;
    }
    participant = participants
        .firstWhereOrNull((element) => element.sessionUserId == sessionUserId);
    bool found = false;
    if (participant != null) {
      activeParticipants.add(participant);
      _pendingUserAdded.remove(sessionUserId);
      found = true;
    } else if (!pending) {
      // user is not in the list yet, wait for next update
      if (!_pendingUserAdded.contains(sessionUserId)) {
        _pendingUserAdded.add(sessionUserId);
      }
    }
    if (found && !pending) {
      notifyListeners();
    }
    return found;
  }

  bool userOffline({required String sessionUserId}) {
    // if pending, just remove
    _pendingUserAdded.remove(sessionUserId);
    // make sure the user is already in the active participants list
    Participant? participant = activeParticipants
        .firstWhereOrNull((element) => element.sessionUserId == sessionUserId);
    if (participant == null) {
      // not in the active list
      return false;
    }
    participant.status = "offline";
    activeParticipants.remove(participant);
    notifyListeners();
    return true;
  }

  bool participantInSession(String uid) {
    return participants.firstWhereOrNull(
            (participant) => participant.userProfile.uid == uid) !=
        null;
  }

  Role participantRole(String participantId) {
    Participant? participant = participants.firstWhereOrNull(
        (element) => element.userProfile.uid == participantId);
    if (participant != null) {
      return participant.role;
    }
    return Roles.member;
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
