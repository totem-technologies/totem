
import 'package:totem/models/index.dart';

abstract class CirclesProvider {
  Stream<List<Circle>> circles(String? uid);
  Future<Circle?> createCircle({
    required String name,
    required int numSessions,
    required DateTime startDate,
    required DateTime startTime,
    required List<int> daysOfTheWeek,
    required String uid,
    String? description,
    required bool addAsMember,
  });
}