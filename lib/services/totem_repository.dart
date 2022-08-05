import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/agora/agora_communication_provider.dart';
import 'package:totem/services/analytics_provider.dart';
import 'package:totem/services/circles_provider.dart';
import 'package:totem/services/firebase_providers/firebase_analytics_provider.dart';
import 'package:totem/services/firebase_providers/firebase_circles_provider.dart';
import 'package:totem/services/firebase_providers/firebase_session_provider.dart';
import 'package:totem/services/firebase_providers/firebase_user_provider.dart';
import 'package:totem/services/index.dart';

import 'firebase_providers/firebase_topics_provider.dart';

class TotemRepository {
  static final userProfileProvider =
      StreamProvider.autoDispose<UserProfile?>((ref) {
    final repo = ref.read(repositoryProvider);
    final authUser = ref.watch(authStateChangesProvider).asData?.value;
    if (authUser == null) {
      final streamController = StreamController<UserProfile?>();
      streamController.add(null);
      return streamController.stream;
    } else {
      return repo.userProfileStream();
    }
  });

  late final TopicsProvider _topicsProvider;
  late final CirclesProvider _circlesProvider;
  late final UserProvider _userProvider;
  late final SessionProvider _sessionProvider;
  late final AnalyticsProvider _analyticsProvider;
  AuthUser? user;
  String? pendingSessionId;

  TotemRepository(ProviderRef ref) {
    _analyticsProvider = FirebaseAnalyticsProvider();
    _topicsProvider = FirebaseTopicsProvider();
    _circlesProvider = FirebaseCirclesProvider();
    _userProvider = FirebaseUserProvider();
    _sessionProvider =
        FirebaseSessionProvider(analyticsProvider: _analyticsProvider);
    final serv = ref.read(authServiceProvider);
    user = serv.currentUser();
    serv.onAuthStateChanged.listen((event) {
      user = event;
    });
  }

  // Topics
  Stream<List<Topic>> topics({String sort = TopicSort.title}) =>
      _topicsProvider.topics(sort: sort);

  // Circles
  Future<ScheduledCircle?> createScheduledCircle({
    required String name,
    required int numSessions,
    required DateTime startDate,
    required DateTime startTime,
    required List<int> daysOfTheWeek,
    String? description,
    bool addAsMember = true,
  }) =>
      _circlesProvider.createScheduledCircle(
        name: name,
        numSessions: numSessions,
        startDate: startDate,
        startTime: startTime,
        daysOfTheWeek: daysOfTheWeek,
        description: description,
        uid: user!.uid,
        addAsMember: addAsMember,
      );
  Future<SnapCircle?> createSnapCircle({
    required String name,
    String? description,
    String? keeper,
    String? previousCircle,
    bool addAsMember = true,
  }) =>
      _circlesProvider.createSnapCircle(
        name: name,
        description: description,
        uid: user!.uid,
        keeper: keeper,
        previousCircle: previousCircle,
      );
  Future<bool> removeSnapCircle({required SnapCircle circle}) =>
      _circlesProvider.removeSnapCircle(circle: circle, uid: user!.uid);
  Stream<List<ScheduledCircle>> scheduledCircles({bool allCircles = false}) =>
      _circlesProvider.scheduledCircles(!allCircles ? user?.uid : null);
  Stream<List<SnapCircle>> snapCircles() => _circlesProvider.snapCircles();
  Stream<List<SnapCircle>> rejoinableSnapCircles() =>
      _circlesProvider.rejoinableSnapCircles(user!.uid);
  Stream<ScheduledCircle> scheduledCircle({required String circleId}) =>
      _circlesProvider.scheduledCircle(circleId, user!.uid);
  Future<SnapCircle?> circleFromId(String id) =>
      _circlesProvider.circleFromId(id);
  Future<SnapCircle?> circleFromPreviousIdAndState(
          String previousId, List<SessionState> state) =>
      _circlesProvider.circleFromPreviousIdAndState(previousId, state);
  Future<SnapCircle?> circleFromPreviousIdAndNotState(
          String previousId, List<SessionState> state) =>
      _circlesProvider.circleFromPreviousIdAndNotState(previousId, state);

  // Sessions
  Future<ActiveSession> activateSession({required ScheduledSession session}) =>
      _sessionProvider.activateSession(session: session, uid: user!.uid);
  Future<void> joinSession(
          {required Session session,
          String? sessionImage,
          required String sessionUserId}) =>
      _sessionProvider.joinSession(
          session: session,
          uid: user!.uid,
          sessionImage: sessionImage,
          sessionUserId: sessionUserId);
  Future<ActiveSession> createActiveSession({required Circle circle}) =>
      _sessionProvider.createActiveSession(circle: circle, uid: user!.uid);
  Future<void> startActiveSession() => _sessionProvider.startActiveSession();
  Future<void> endActiveSession() => _sessionProvider.endActiveSession();
  void clearActiveSession() => _sessionProvider.clear();
  ActiveSession? get activeSession => _sessionProvider.activeSession;
  Future<void> updateActiveSession(Map<String, dynamic> sessionData) =>
      _sessionProvider.updateActiveSession(sessionData);

  // Analytics
  AnalyticsProvider get analyticsProvider {
    return _analyticsProvider;
  }

  // Communications for Session
  CommunicationProvider createCommunicationProvider() {
    CommunicationProvider provider = AgoraCommunicationProvider(
        sessionProvider: _sessionProvider, userId: user!.uid);
    return provider;
  }

  // Users
  Stream<UserProfile> userProfileStream() =>
      _userProvider.userProfileStream(uid: user!.uid);
  Future<UserProfile?> userProfile({bool circlesCompleted = false}) =>
      _userProvider.userProfile(
          uid: user!.uid, circlesCompleted: circlesCompleted);
  Future<UserProfile?> userProfileWithId(
          {required String uid, bool circlesCompleted = false}) =>
      _userProvider.userProfile(uid: uid, circlesCompleted: circlesCompleted);
  Future<void> updateUserProfile(UserProfile userProfile) =>
      _userProvider.updateUserProfile(userProfile: userProfile, uid: user!.uid);
  Future<void> updateUserProfileImage(String imageUrl) =>
      _userProvider.updateUserProfileImage(imageUrl: imageUrl, uid: user!.uid);
  Stream<AccountState> userAccountStateStream() =>
      _userProvider.userAccountStateStream(uid: user!.uid);
  Future<AccountState> userAccountState() =>
      _userProvider.userAccountState(uid: user!.uid);
  Future<void> updateAccountStateValue(String key, dynamic value) =>
      _userProvider.updateAccountStateValue(
          key: key, value: value, uid: user!.uid);
}
