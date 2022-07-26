import 'package:totem/models/index.dart';

abstract class CirclesProvider {
  Stream<List<ScheduledCircle>> scheduledCircles(String? uid);

  Stream<List<SnapCircle>> snapCircles();

  Stream<List<SnapCircle>> rejoinableSnapCircles(String uid);

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
  });

  Future<bool> removeSnapCircle(
      {required SnapCircle circle, required String uid});
  Stream<ScheduledCircle> scheduledCircle(String circleId, String uid);
  Future<SnapCircle?> circleFromId(String id);
  Future<SnapCircle?> circleFromPreviousIdAndState(
      String previousId, List<SessionState> state);
  Future<SnapCircle?> circleFromPreviousIdAndNotState(
      String previousId, List<SessionState> state);
}
