import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:totem/models/index.dart';

class SessionState {
  static const String pending = "pending";
  static const String waiting = "waiting";
  static const String live = "live";
  static const String complete = "complete";
  static const String cancelled = "cancelled";
  static const String idle = "idle";
}

class ActiveSessionChange {
  static const String none = "none";
  static const String totemPass = "pass";
  static const String participantsChange = "participants";
}

class ActiveSession extends ChangeNotifier {
  ActiveSession(
      {required this.session, required this.userId, this.isSnap = true});

  final Session session;
  final String userId;
  final bool isSnap;
  late List<SessionParticipant> participants = [];
  String state = SessionState.waiting;
  DateTime? started;
  List<SessionParticipant> activeParticipants = [];
  final List<String> _pendingUserAdded = [];
  String? totemUser;
  bool locked = true;
  String lastChange = ActiveSessionChange.none;

  Map<String, dynamic>? requestUserTotem({String? nextSessionId}) {
    // this should use the existing data to generate an data
    // update for the session to change the totem and update
    // the sort order of participants
    int nextIndex = -1;
    if (nextSessionId == null) {
      if (activeParticipants.length > 1) {
        nextSessionId = activeParticipants[1].sessionUserId;
        nextIndex = 1;
      }
    } else {
      nextIndex = activeParticipants
          .indexWhere((element) => element.sessionUserId == nextSessionId);
    }
    if (nextIndex != -1) {
      List<SessionParticipant> usersToMove =
          activeParticipants.sublist(0, nextIndex);
      activeParticipants.removeRange(0, nextIndex);
      activeParticipants.addAll(usersToMove);
      List<Map<String, dynamic>> updatedParticipants = [];
      for (SessionParticipant participant in activeParticipants) {
        updatedParticipants.add(participant.toJson());
      }
      Map<String, dynamic> request = {
        "participants": updatedParticipants,
        "totemUser": nextSessionId,
        "lastChange": ActiveSessionChange.totemPass,
      };
      return request;
    }
    return null;
  }

  SessionParticipant? participantWithID(String id) {
    return activeParticipants
        .firstWhereOrNull((element) => element.userProfile.uid == id);
  }

  void updateFromData(Map<String, dynamic> data) {
    state = data['state'] ?? state;
    if (data['participants'] != null && data['participants'].isNotEmpty) {
      // update list of participants in the session
      participants = data['participants'];
    } else {
      participants = [];
    }
    if (data['started'] != null && started == null) {
      started = DateTimeEx.fromMapValue(data['started']);
    }
    if (data["totemUser"] != null) {
      totemUser = data["totemUser"];
    }
    locked = data["locked"] ?? true;
    lastChange = data['lastChange'] ?? ActiveSessionChange.none;

    // update the active users
    for (var participant in participants) {
      var activeParticipant = activeParticipants.firstWhereOrNull(
          (element) => element.userProfile.uid == participant.userProfile.uid);
      if (activeParticipant != null) {
        activeParticipant.updateWith(participant);
      }
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
    SessionParticipant? participant = activeParticipants
        .firstWhereOrNull((element) => element.sessionUserId == sessionUserId);

    // a user has joined the call, add them to the list of session participants
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
    SessionParticipant? participant = activeParticipants
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

  void updateMutedStateForUser(
      {required String sessionUserId, required bool muted}) {
    SessionParticipant? participant = activeParticipants
        .firstWhereOrNull((element) => element.sessionUserId == sessionUserId);
    if (participant != null) {
      participant.muted = muted;
    }
  }

  bool mutedStateForUser({required String sessionUserId}) {
    SessionParticipant? participant = activeParticipants
        .firstWhereOrNull((element) => element.sessionUserId == sessionUserId);
    if (participant == null) {
      // not in the active list
      return false;
    }
    return participant.muted;
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
