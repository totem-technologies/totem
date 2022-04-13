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
  cancelling,
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
  List<SessionParticipant> _activeParticipants = [];
  final List<String> _pendingUserAdded = [];
  String? _totemUser;
  bool totemReceived = false;
  bool locked = true;
  ActiveSessionChange lastChange = ActiveSessionChange.none;
  final List<String> _connectedUsers = [];

  @override
  void dispose() {
    _activeParticipants = [];
    super.dispose();
  }

  String? get totemUser {
    if (_totemUser != null && _totemUser!.isNotEmpty) {
      return _totemUser;
    }
    return null;
  }

  List<SessionParticipant> get activeParticipants {
    List<SessionParticipant> activeUsers = _activeParticipants
        .where((element) => _connectedUsers.contains(element.sessionUserId))
        .toList();
    return activeUsers;
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
    for (SessionParticipant participant in _activeParticipants) {
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
      if (_activeParticipants.length > 1) {
        nextIndex = 1;
        nextSessionId = _activeParticipants[nextIndex].sessionUserId;
        while (!_connectedUsers.contains(nextSessionId)) {
          if (nextIndex < _activeParticipants.length - 1) {
            nextIndex++;
          } else {
            nextIndex = 0;
          }
          nextSessionId = _activeParticipants[nextIndex].sessionUserId;
        }
      } else {
        // This would be a test session with a single participant
        nextIndex = 0;
        nextSessionId = _activeParticipants[0].sessionUserId;
      }
    } else {
      nextIndex = _activeParticipants
          .indexWhere((element) => element.sessionUserId == nextSessionId);
    }
    if (nextIndex != -1) {
      List<SessionParticipant> usersToMove =
          _activeParticipants.sublist(0, nextIndex);
      _activeParticipants.removeRange(0, nextIndex);
      _activeParticipants.addAll(usersToMove);
      List<Map<String, dynamic>> updatedParticipants = [];
      for (SessionParticipant participant in _activeParticipants) {
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
    return _activeParticipants.firstWhereOrNull((element) => element.me);
  }

  SessionParticipant? participantWithID(String id) {
    SessionParticipant? participant =
        _activeParticipants.firstWhereOrNull((element) => element.uid == id);
    if (participant != null) {
      int index = _activeParticipants.indexOf(participant);
      SessionParticipant newParticipant = SessionParticipant.from(participant);
      _activeParticipants[index] = newParticipant;
      return newParticipant;
    }
    return null;
  }

  SessionParticipant? participantWithSessionID(String sessionId) {
    return _activeParticipants
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
        List<SessionParticipant> participants = [];
        // find the items not already in the list of active participants
        List<SessionParticipant> sessionParticipants =
            data['activeParticipants'] as List<SessionParticipant>;
        for (SessionParticipant participant in sessionParticipants) {
          SessionParticipant? existing = _activeParticipants.firstWhereOrNull(
              (activeUser) => activeUser.uid == participant.uid);
          if (existing == null) {
            participants.add(participant);
          } else {
            participants.add(existing);
          }
        }
        _activeParticipants = participants;
      } else {
        // update the active users
        for (var participant in participants) {
          var activeParticipant = _activeParticipants
              .firstWhereOrNull((element) => element.uid == participant.uid);
          if (activeParticipant != null) {
            activeParticipant.updateFromParticipant(participant);
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
    bool added = _assertUser(sessionUserId);
    SessionParticipant? participant = _activeParticipants
        .firstWhereOrNull((element) => element.sessionUserId == sessionUserId);
    // a user has joined the call, add them to the list of session participants
    if (participant != null) {
      // already in the active list
      if (added) {
        notifyListeners();
      }
      return true;
    }
    participant = participants
        .firstWhereOrNull((element) => element.sessionUserId == sessionUserId);
    bool found = false;
    if (participant != null) {
      _activeParticipants.add(participant);
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
    _connectedUsers.remove(sessionUserId);
    if (state == SessionState.waiting) {
      // make sure the user is already in the active participants list
      SessionParticipant? participant = _activeParticipants.firstWhereOrNull(
          (element) => element.sessionUserId == sessionUserId);
      if (participant != null) {
        _activeParticipants.remove(participant);
      }
    }
    notifyListeners();
    return true;
  }

  void updateStateForUser(
      {required String sessionUserId, bool? muted, bool? videoMuted}) {
    bool added = _assertUser(sessionUserId);
    SessionParticipant? participant = _activeParticipants
        .firstWhereOrNull((element) => element.sessionUserId == sessionUserId);
    if (participant != null) {
      participant.muted = muted ?? participant.muted;
      participant.videoMuted = videoMuted ?? participant.videoMuted;
    }
    if (added) {
      notifyListeners();
    }
  }

  void updateMutedStateForUser(
      {required String sessionUserId, required bool muted}) {
    SessionParticipant? participant = _activeParticipants
        .firstWhereOrNull((element) => element.sessionUserId == sessionUserId);
    if (participant != null) {
      participant.muted = muted;
    }
  }

  bool mutedStateForUser({required String sessionUserId}) {
    SessionParticipant? participant = _activeParticipants
        .firstWhereOrNull((element) => element.sessionUserId == sessionUserId);
    if (participant == null) {
      // not in the active list
      return false;
    }
    return participant.muted;
  }

  void updateVideoMutedStateForUser(
      {required String sessionUserId, required bool muted}) {
    SessionParticipant? participant = _activeParticipants
        .firstWhereOrNull((element) => element.sessionUserId == sessionUserId);
    if (participant != null) {
      participant.videoMuted = muted;
    }
  }

  bool videoMutedStateForUser({required String sessionUserId}) {
    SessionParticipant? participant = _activeParticipants
        .firstWhereOrNull((element) => element.sessionUserId == sessionUserId);
    if (participant == null) {
      // not in the active list
      return false;
    }
    return participant.videoMuted;
  }

  bool participantInSession(String uid) {
    return _activeParticipants
            .firstWhereOrNull((participant) => participant.uid == uid) !=
        null;
  }

  Role participantRole(String participantId) {
    SessionParticipant? participant = participants
        .firstWhereOrNull((element) => element.uid == participantId);
    participant ??= _activeParticipants
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
        in (participants ?? _activeParticipants)) {
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

  bool _assertUser(String sessionUserId) {
    if (!_connectedUsers.contains(sessionUserId)) {
      _connectedUsers.add(sessionUserId);
      return true;
    }
    return false;
  }
}
