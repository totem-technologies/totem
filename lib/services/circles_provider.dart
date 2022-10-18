import 'package:totem/models/index.dart';

abstract class CirclesProvider {
  Stream<List<ScheduledCircle>> scheduledCircles(String? uid);

  Stream<List<SnapCircle>> snapCircles();
  Stream<List<SnapCircle>> rejoinableSnapCircles(String uid);
  Stream<List<SnapCircle>> mySnapCircles(String uid,
      {bool privateOnly, bool activeOnly});

  Future<ScheduledCircle?> createScheduledCircle({
    required String name,
    required int numSessions,
    required DateTime startDate,
    required DateTime startTime,
    required List<int> daysOfTheWeek,
    required String uid,
    String? description,
    required bool addAsMember,
  });

  Future<SnapCircle?> createSnapCircle({
    required String name,
    String? description,
    required String uid,
    String? keeper,
    String? previousCircle,
    Map<String, dynamic>? bannedParticipants,
    bool? isPrivate,
    int? duration,
    int? maxParticipants,
    String? themeRef,
    String? imageUrl,
    String? bannerUrl,
  });

  Future<bool> removeSnapCircle(
      {required SnapCircle circle, required String uid});
  Stream<ScheduledCircle> scheduledCircle(String circleId, String uid);
  Future<SnapCircle?> circleFromId(String id, String uid);
  Future<SnapCircle?> circleFromPreviousIdAndState(
      {required String previousId,
      required List<SessionState> state,
      required String uid});
  Future<SnapCircle?> circleFromPreviousIdAndNotState(
      {required String previousId,
      required List<SessionState> state,
      required String uid});
  Future<bool> canJoinCircle({required String circleId, required String uid});
  Stream<SnapCircle?> snapCircleStream(String circleId);
}
