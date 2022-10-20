import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:totem/models/index.dart';

enum SessionState {
  waiting,
  starting,
  live,
  ending,
  complete,
  cancelling,
  cancelled,
  removed,
  expiring,
  expired,
  scheduled,
}

enum ActiveSessionChange {
  none,
  totemReceive,
  totemChange,
  started,
  participantsChange,
  userRemoved
}

class ActiveSession extends ChangeNotifier {
  static const int tooltipCount = 3;

  ActiveSession(
      {required this.circle, required this.userId, this.isSnap = true});
  String topic = "";
  final Circle circle;
  final String userId;
  final bool isSnap;
  final Map<String, SessionParticipant> _activeParticipants = {};
  final List<String> _pendingUserAdded = [];
  String? _totemUser;
  bool totemReceived = false;
  bool locked = true;
  ActiveSessionChange lastChange = ActiveSessionChange.none;
  final List<String> _connectedUsers = [];
  List<String> _speakingOrder = [];
  SessionState _state = SessionState.waiting;
  bool _userStatus = false;
  Map<String, dynamic> _removedUsers = {};
  UserProfile? userProfile;

  @override
  void dispose() {
    _activeParticipants.clear();
    super.dispose();
  }

  String? get totemUser {
    if (_totemUser != null && _totemUser!.isNotEmpty) {
      return _totemUser;
    }
    return null;
  }

  bool get ended {
    return [
      SessionState.complete,
      SessionState.cancelled,
      SessionState.removed,
      SessionState.scheduled
    ].contains(_state);
  }

  bool get userStatus {
    return _userStatus;
  }

  bool get showTooltips {
    return (userProfile?.completedCircles ?? 0) < tooltipCount;
  }

  List<SessionParticipant> get activeParticipants {
    List<SessionParticipant> activeUsers = _activeParticipants.values
        .where((element) => _connectedUsers.contains(element.sessionUserId))
        .toList();
    return activeUsers;
  }

  List<SessionParticipant> get speakOrderParticipants {
    List<SessionParticipant> activeUsers = _activeParticipants.values
        .where((element) => _connectedUsers.contains(element.sessionUserId))
        .toList();
    List<SessionParticipant> order = [];
    if (_speakingOrder.isNotEmpty && activeUsers.isNotEmpty) {
      for (String sessionId in _speakingOrder) {
        SessionParticipant? participant = activeUsers
            .firstWhereOrNull((element) => sessionId == element.sessionUserId);
        if (participant != null) {
          order.add(participant);
        }
      }
    }
    return order;
  }

  SessionState get state {
    return _state;
  }

  SessionParticipant? get totemParticipant {
    if (_totemUser != null && _totemUser!.isNotEmpty) {
      return participantWithSessionID(_totemUser!);
    }
    return null;
  }

  Map<String, dynamic>? receiveUserTotem() {
    /*List<Map<String, dynamic>> updatedParticipants = [];
    for (SessionParticipant participant in _activeParticipants) {
      updatedParticipants.add(participant.toJson());
    } */
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
      if (_speakingOrder.length > 1) {
        nextIndex = 1;
        nextSessionId = _speakingOrder[nextIndex];
        while (!_connectedUsers.contains(nextSessionId)) {
          if (nextIndex < _speakingOrder.length - 1) {
            nextIndex++;
          } else {
            nextIndex = 0;
          }
          nextSessionId = _speakingOrder[nextIndex];
        }
      } else {
        // This would be a test session with a single participant
        nextIndex = 0;
        nextSessionId = _speakingOrder[0];
      }
    } else {
      nextIndex =
          _speakingOrder.indexWhere((element) => element == nextSessionId);
    }
    if (nextIndex != -1) {
      List<String> usersToMove = _speakingOrder.sublist(0, nextIndex);
      _speakingOrder.removeRange(0, nextIndex);
      _speakingOrder.addAll(usersToMove);
      return _toJson(
        nextTotemUser: nextSessionId,
        received: false,
        sessionChange: ActiveSessionChange.totemChange,
      );
    }
    return null;
  }

  SessionParticipant? me() {
    return _activeParticipants.values.firstWhereOrNull((element) => element.me);
  }

  SessionParticipant? participantWithSessionID(String sessionId) {
    return _activeParticipants.values
        .firstWhereOrNull((element) => element.sessionUserId == sessionId);
  }

  Map<String, dynamic> reorderParticipants(List<String> participantsOrder) {
    return _toJson(participantsOrder: participantsOrder);
  }

  void updateSessionState(Map<String, dynamic> data) {
    _removedUsers =
        Map<String, dynamic>.from(data['bannedParticipants'] as Map? ?? {});
    SessionState newState = data["state"] != null
        ? SessionState.values.byName(data["state"]!)
        : SessionState.waiting;
    bool removed = _removedUsers[userId] != null;
    if (newState != _state && !removed) {
      _state = newState;
      notifyListeners();
    } else if (removed) {
      // User has been removed from the session by keeper, so update state
      _state = SessionState.removed;
      notifyListeners();
    }
  }

  Map<String, dynamic>? updateFromData(Map<String, dynamic> data) {
    if (data["totemUser"] != null) {
      _totemUser = data["totemUser"];
    } else {
      _totemUser = null;
    }
    Map<String, dynamic>? request;
    totemReceived = data["totemReceived"] ?? false;
    locked = data["locked"] ?? true;
    if (data['lastChange'] != null) {
      lastChange = ActiveSessionChange.values.byName(data['lastChange']);
    }
    _userStatus = data['userStatus'] ?? false;
    if (_state != SessionState.complete || _state != SessionState.cancelled) {
      if (data['participants'] != null) {
        Map<String, SessionParticipant> participants = {};
        // find the items not already in the list of active participants
        Map<String, dynamic> sessionParticipants =
            data['participants'] as Map<String, dynamic>;
        for (String key in sessionParticipants.keys) {
          SessionParticipant? existing = _activeParticipants[key];
          if (existing == null) {
            _activeParticipants[key] = SessionParticipant.fromJson(
                sessionParticipants[key]!,
                me: userId == sessionParticipants[key]['uid']);
          } else {
            existing.updateFromData(sessionParticipants[key]!);
            participants[key] = existing;
          }
        }
        List<String> keys = List<String>.from(_activeParticipants.keys);
        for (String key in keys) {
          if (sessionParticipants[key] == null) {
            _activeParticipants.remove(key);
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
    _speakingOrder = List<String>.from(data["speakingOrder"] ?? []);
    if (totemUser != null && state == SessionState.live) {
      // ensure the totemUser is still valid... if not patch
      if (!_speakingOrder.contains(totemUser) && _speakingOrder.isNotEmpty) {
        //need to set a new totemUser
        _totemUser = _speakingOrder.first;
        request = _toJson(
          nextTotemUser: _totemUser,
          received: false,
          sessionChange: ActiveSessionChange.totemChange,
        );
      }
    }
    notifyListeners();
    return request;
  }

  bool userJoined({required String sessionUserId, bool pending = false}) {
    bool added = _assertUser(sessionUserId);
    SessionParticipant? participant = _activeParticipants.values
        .firstWhereOrNull((element) => element.sessionUserId == sessionUserId);
    // a user has joined the call, add them to the list of session participants
    if (participant != null) {
      // already in the active list
      _pendingUserAdded.remove(sessionUserId);
      if (added) {
        notifyListeners();
      }
      return true;
    }
    if (!pending) {
      // user is not in the list yet, wait for next update
      if (!_pendingUserAdded.contains(sessionUserId)) {
        _pendingUserAdded.add(sessionUserId);
      }
    }
    return false;
  }

  bool userOffline({required String sessionUserId}) {
    // if pending, just remove
    _pendingUserAdded.remove(sessionUserId);
    _connectedUsers.remove(sessionUserId);
    if (state == SessionState.waiting) {
      // make sure the user is already in the active participants list
      SessionParticipant? participant = _activeParticipants.values
          .firstWhereOrNull(
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
    SessionParticipant? participant = _activeParticipants.values
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
    SessionParticipant? participant = _activeParticipants.values
        .firstWhereOrNull((element) => element.sessionUserId == sessionUserId);
    if (participant != null) {
      participant.muted = muted;
    }
  }

  void updateUnstableNetworkForUser(
      {required String sessionUserId, required NetworkSample sample}) {
    SessionParticipant? participant = _activeParticipants.values
        .firstWhereOrNull((element) => element.sessionUserId == sessionUserId);
    if (participant != null &&
        participant.addNetworkSample(sample) &&
        participant.me) {
      notifyListeners();
    }
  }

  bool mutedStateForUser({required String sessionUserId}) {
    SessionParticipant? participant = _activeParticipants.values
        .firstWhereOrNull((element) => element.sessionUserId == sessionUserId);
    if (participant == null) {
      // not in the active list
      return false;
    }
    return participant.muted;
  }

  void updateVideoMutedStateForUser(
      {required String sessionUserId, required bool muted}) {
    SessionParticipant? participant = _activeParticipants.values
        .firstWhereOrNull((element) => element.sessionUserId == sessionUserId);
    if (participant != null) {
      participant.videoMuted = muted;
    }
  }

  bool videoMutedStateForUser({required String sessionUserId}) {
    SessionParticipant? participant = _activeParticipants.values
        .firstWhereOrNull((element) => element.sessionUserId == sessionUserId);
    if (participant == null) {
      // not in the active list
      return false;
    }
    return participant.videoMuted;
  }

  bool participantInSession(String uid) {
    return _activeParticipants[uid] != null;
  }

  Role participantRole(String participantId) {
    SessionParticipant? participant = _activeParticipants.values
        .firstWhereOrNull((element) => element.uid == participantId);
    if (participant != null) {
      return participant.role;
    }
    return Role.member;
  }

/*  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = session.toJson();
    return data;
  } */

  @override
  bool operator ==(other) {
    if (other is! Session && other is! ActiveSession) {
      return false;
    }
    if (other is Session) {
      return other.id == circle.id;
    }
    return (other as ActiveSession).circle.id == circle.id;
  }

  @override
  int get hashCode => circle.id.hashCode;

  Map<String, dynamic> _toJson(
      {List<String>? participantsOrder,
      String? nextTotemUser,
      bool? received,
      ActiveSessionChange? sessionChange}) {
    List<String> items = (participantsOrder ?? _speakingOrder);
    Map<String, dynamic> data = {
      "totemUser": nextTotemUser ?? _totemUser,
      "totemReceived": received ?? totemReceived,
      "lastChange":
          sessionChange != null ? sessionChange.name : lastChange.name,
      "speakingOrder": items,
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
