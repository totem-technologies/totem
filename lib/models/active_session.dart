import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:totem/models/index.dart';

enum SessionState {
  pending,
  waiting,
  starting,
  live,
  ending,
  complete,
  cancelled,
  idle,
}

enum ActiveSessionChange {
  none,
  totemReceive,
  totemChange,
  started,
  participantsChange,
}

class ActiveSession extends ChangeNotifier {
  ActiveSession(
      {required this.session, required this.userId, this.isSnap = true});

  final Session session;
  final String userId;
  final bool isSnap;
  late List<SessionParticipant> participants = [];
  DateTime? started;
  List<SessionParticipant> activeParticipants = [];
  final List<String> _pendingUserAdded = [];
  String? _totemUser;
  bool totemReceived = false;
  bool locked = true;
  ActiveSessionChange lastChange = ActiveSessionChange.none;

  String? get totemUser {
    if (_totemUser != null && _totemUser!.isNotEmpty) {
      return _totemUser;
    }
    return null;
  }

  SessionState get state {
    return session.state;
  }

  SessionParticipant? get totemParticipant {
    if (_totemUser != null && _totemUser!.isNotEmpty) {
      return participantWithSessionID(_totemUser!);
    }
    return null;
  }

  Map<String, dynamic>? receiveUserTotem() {
    List<Map<String, dynamic>> updatedParticipants = [];
    for (SessionParticipant participant in activeParticipants) {
      updatedParticipants.add(participant.toJson());
    }
    return _toJson(
      received: true,
      sessionChange: ActiveSessionChange.totemReceive,
    );
  }

  Map<String, dynamic>? requestNextUserTotem({String? nextSessionId}) {
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
      return _toJson(
        nextTotemUser: nextSessionId,
        received: false,
        sessionChange: ActiveSessionChange.totemChange,
      );
    }
    return null;
  }

  SessionParticipant? me() {
    return activeParticipants.firstWhereOrNull((element) => element.me);
  }

  SessionParticipant? participantWithID(String id) {
    return activeParticipants.firstWhereOrNull((element) => element.uid == id);
  }

  SessionParticipant? participantWithSessionID(String sessionId) {
    return activeParticipants
        .firstWhereOrNull((element) => element.sessionUserId == sessionId);
  }

  Map<String, dynamic> reorderParticipants(
      List<SessionParticipant> participants) {
    return _toJson(participants: participants);
  }

  void updateFromData(Map<String, dynamic> data) {
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
      _totemUser = data["totemUser"];
    } else {
      _totemUser = null;
    }
    totemReceived = data["totemReceived"] ?? false;
    locked = data["locked"] ?? true;
    if (data['lastChange'] != null) {
      lastChange = ActiveSessionChange.values.byName(data['lastChange']);
    }
    if (data['state'] != null) {
      session.state = SessionState.values.byName(data['state']);
    }
    if (session.state != SessionState.complete ||
        session.state != SessionState.cancelled) {
      if (data['activeParticipants'] != null) {
        activeParticipants =
            data['activeParticipants'] as List<SessionParticipant>;
      } else {
        // update the active users
        for (var participant in participants) {
          var activeParticipant = activeParticipants
              .firstWhereOrNull((element) => element.uid == participant.uid);
          if (activeParticipant != null) {
            activeParticipant.updateWith(participant);
          }
        }
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
    return activeParticipants
            .firstWhereOrNull((participant) => participant.uid == uid) !=
        null;
  }

  Role participantRole(String participantId) {
    SessionParticipant? participant = participants
        .firstWhereOrNull((element) => element.uid == participantId);
    participant ??= activeParticipants
        .firstWhereOrNull((element) => element.uid == participantId);
    if (participant != null) {
      return participant.role;
    }
    return Role.member;
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

  Map<String, dynamic> _toJson(
      {List<SessionParticipant>? participants,
      String? nextTotemUser,
      bool? received,
      ActiveSessionChange? sessionChange}) {
    List<Map<String, dynamic>> updatedParticipants = [];
    for (SessionParticipant participant
        in (participants ?? activeParticipants)) {
      updatedParticipants.add(participant.toJson());
    }
    Map<String, dynamic> data = {
      "participants": updatedParticipants,
      "totemUser": nextTotemUser ?? _totemUser,
      "totemReceived": received ?? totemReceived,
      "lastChange":
          sessionChange != null ? sessionChange.name : lastChange.name,
    };
    return data;
  }
}
