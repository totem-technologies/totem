import 'package:totem/models/index.dart';

class Circle extends CircleTemplate {
  static const snapSessionId = "snap";

  late SessionState state;
  DateTime? started;
  DateTime? completed;
  late final String ref;
  UserProfile? createdBy;
  late DateTime createdOn;
  DateTime? updatedOn;
  DateTime? expiresOn;
  String? activeSession;
  String? link;
  late String keeper;
  String? previousCircle;
  Map<String, dynamic>? bannedParticipants;
  DateTime? nextSession;
  List<DateTime>? scheduledSessions;
  bool _canJoin = true;

  Circle.fromJson(
    Map<String, dynamic> json, {
    required String id,
    required this.ref,
    UserProfile? createdUser,
    String? uid,
  }) : super.fromJson(
          json,
          id: id,
        ) {
    createdBy = createdUser;
    createdOn = DateTimeEx.fromMapValue(json['createdOn']) ?? DateTime.now();
    updatedOn = DateTimeEx.fromMapValue(json['updatedOn']);
    expiresOn = DateTimeEx.fromMapValue(json['expiresOn']);
    link = json['link'];
    keeper = json['keeper'];
    previousCircle = json['previousCircle'];
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
    if (json['bannedParticipants'] != null) {
      bannedParticipants =
          Map<String, dynamic>.from(json['bannedParticipants']);
    }
    if (uid != null && bannedParticipants != null) {
      _canJoin = bannedParticipants![uid] == null;
    }
    nextSession = DateTimeEx.fromMapValue(json['nextSession']);
    if (json['scheduledSessions'] != null) {
      scheduledSessions = [];
      for (var date in json['scheduledSessions']) {
        scheduledSessions!.add(DateTimeEx.fromMapValue(date)!);
      }
    }
  }

  bool get canJoin => _canJoin;

  DateTime get sortDate => (nextSession ?? createdOn);

  Role participantRole(String participantId) {
    return keeper == participantId ? Role.keeper : Role.member;
  }

  bool get isComplete {
    const completeStates = [
      SessionState.complete,
      SessionState.cancelled,
    ];
    return completeStates.contains(state);
  }

  bool get isRunning {
    const runningStates = [
      SessionState.live,
      SessionState.waiting,
      SessionState.expiring,
    ];
    return runningStates.contains(state);
  }

  bool get isPending {
    const pendingStates = [
      SessionState.waiting,
      SessionState.scheduled,
    ];
    return pendingStates.contains(state);
  }

  Session get session {
    return Session.fromJson({}, circle: this, id: id);
  }

  @override
  Map<String, dynamic> toJson({bool includeParticipants = true}) {
    Map<String, dynamic> data = super.toJson();
    data["createdOn"] = createdOn;
    data["state"] = state.name;
    if (activeSession != null) {
      data['activeSession'] = activeSession;
    }
    if (updatedOn != null) {
      data["updatedOn"] = updatedOn!;
    }
    if (bannedParticipants != null) {
      data["bannedParticipants"] = bannedParticipants!;
    }
    return data;
  }
}
