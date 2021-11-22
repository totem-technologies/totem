import 'package:totem/models/index.dart';

abstract class CirclesProvider {
  Stream<List<ScheduledCircle>> scheduledCircles(String? uid);
  Stream<List<SnapCircle>> snapCircles();
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
    required bool addAsMember,
    required String uid,
  });
  Stream<ScheduledCircle> scheduledCircle(String circleId, String uid);
}
