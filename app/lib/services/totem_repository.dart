import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/agora/agora_communication_provider.dart';
import 'package:totem/services/analytics_provider.dart';
import 'package:totem/services/circles_provider.dart';
import 'package:totem/services/firebase_providers/firebase_analytics_provider.dart';
import 'package:totem/services/firebase_providers/firebase_circles_provider.dart';
import 'package:totem/services/firebase_providers/firebase_session_provider.dart';
import 'package:totem/services/firebase_providers/firebase_system_provider.dart';
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
  late final SystemProvider _systemProvider;
  AuthUser? user;
  String? pendingSessionId;

  TotemRepository(ProviderRef ref) {
    _analyticsProvider = FirebaseAnalyticsProvider();
    _topicsProvider = FirebaseTopicsProvider();
    _circlesProvider = FirebaseCirclesProvider();
    _userProvider = FirebaseUserProvider();
    _systemProvider = FirebaseSystemProvider();
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

  Future<Circle?> createCircle({
    required String name,
    String? description,
    String? keeper,
    String? previousCircle,
    Map<String, dynamic>? bannedParticipants,
    bool addAsMember = true,
    bool isPrivate = false,
    int? duration,
    int? maxParticipants,
    String? themeRef,
    String? imageUrl,
    String? bannerUrl,
    RecurringType? recurringType,
    List<DateTime>? instances,
    RepeatOptions? repeatOptions,
  }) =>
      _circlesProvider.createCircle(
        name: name,
        description: description,
        uid: user!.uid,
        keeper: keeper,
        previousCircle: previousCircle,
        bannedParticipants: bannedParticipants,
        isPrivate: isPrivate,
        duration: duration,
        maxParticipants: maxParticipants,
        themeRef: themeRef,
        imageUrl: imageUrl,
        bannerUrl: bannerUrl,
        recurringType: recurringType,
        instances: instances,
        repeatOptions: repeatOptions,
      );
  Future<bool> removeCircle({required Circle circle}) =>
      _circlesProvider.removeCircle(circle: circle, uid: user!.uid);
  Stream<List<Circle>> circles() => _circlesProvider.circles();
  Stream<List<Circle>> rejoinableCircles() =>
      _circlesProvider.rejoinableCircles(user!.uid);
  Stream<List<Circle>> myCircles(
          {bool privateOnly = true, bool activeOnly = true}) =>
      _circlesProvider.myCircles(user!.uid,
          privateOnly: privateOnly, activeOnly: activeOnly);
  Future<Circle?> circleFromId(String id) =>
      _circlesProvider.circleFromId(id, user!.uid);
  Future<Circle?> circleFromPreviousIdAndState(
          String previousId, List<SessionState> state) =>
      _circlesProvider.circleFromPreviousIdAndState(
          previousId: previousId, state: state, uid: user!.uid);
  Future<Circle?> circleFromPreviousIdAndNotState(
          String previousId, List<SessionState> state) =>
      _circlesProvider.circleFromPreviousIdAndNotState(
          previousId: previousId, state: state, uid: user!.uid);
  Future<bool> canJoinCircle(String circleId) =>
      _circlesProvider.canJoinCircle(circleId: circleId, uid: user!.uid);
  Stream<Circle?> circleStream(String circleId) =>
      _circlesProvider.circleStream(circleId);
  Stream<List<Circle>> scheduledUpcomingCircles(
          {required int timeWindowDuration}) =>
      _circlesProvider.scheduledUpcomingCircles(
          timeWindowDuration: timeWindowDuration);
  Stream<List<Circle>> ownerUpcomingCircles() =>
      _circlesProvider.ownerUpcomingCircles(uid: user!.uid);

  // Sessions
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
  Future<void> cancelPendingSession({required Circle circle}) =>
      _sessionProvider.cancelPendingSession(session: circle.session);
  Future<void> addTimeToActiveSession({required int minutes}) =>
      _sessionProvider.addTimeToSession(minutes: minutes);

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

  // System
  Future<SystemVideo> getSystemVideo() => _systemProvider.getSystemVideo();
  Future<List<CircleTheme>> getSystemCircleThemes() =>
      _systemProvider.getSystemCircleThemes();
  Future<List<CircleTemplate>> getSystemCircleTemplates() =>
      _systemProvider.getSystemCircleTemplates();
}
