import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/circles_provider.dart';
import 'package:totem/services/firebase_providers/firebase_circles_provider.dart';
import 'package:totem/services/firebase_providers/firebase_user_provider.dart';
import 'package:totem/services/topics_provider.dart';
import 'package:totem/services/user_provider.dart';
import 'package:totem/services/index.dart';
import 'firebase_providers/firebase_topics_provider.dart';

class TotemRepository {

  static final userProfileProvider = StreamProvider.autoDispose<UserProfile?>((ref) {
    final repo = ref.read(repositoryProvider);
    final authUser = ref.watch(authStateChangesProvider).data?.value;
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
  AuthUser? user;

  TotemRepository() {
    _topicsProvider = FirebaseTopicsProvider();
    _circlesProvider = FirebaseCirclesProvider();
    _userProvider = FirebaseUserProvider();
  }

  // Topics
  Stream<List<Topic>> topics({String sort = TopicSort.title}) => _topicsProvider.topics(sort: sort);

  // Circles
  Future<Circle?> createCircle({
    required String name,
    required int numSessions,
    required DateTime startDate,
    required DateTime startTime,
    required List<int> daysOfTheWeek,
    String? description,
    bool addAsMember = true,
  }) => _circlesProvider.createCircle(
      name: name,
      numSessions: numSessions,
      startDate: startDate,
      startTime: startTime,
      daysOfTheWeek: daysOfTheWeek,
      description: description,
      uid: user!.uid,
      addAsMember: addAsMember,
    );
  Stream<List<Circle>> circles({bool allCircles = false}) => _circlesProvider.circles(!allCircles ? user?.uid : null);

  // Users
  Stream<UserProfile> userProfileStream() => _userProvider.userProfileStream(uid: user!.uid);
  Future<UserProfile?> userProfile() => _userProvider.userProfile(uid: user!.uid);
  Future<void> updateUserProfile(UserProfile userProfile) => _userProvider.updateUserProfile(userProfile: userProfile, uid: user!.uid);
}