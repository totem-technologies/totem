import 'package:totem/models/index.dart';

abstract class CirclesProvider {
  Stream<List<Circle>> circles();
  Stream<List<Circle>> rejoinableCircles(String uid);
  Stream<List<Circle>> myCircles(String uid,
      {bool privateOnly, bool activeOnly});
  Future<Circle?> createCircle({
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
    RecurringType? recurringType,
    List<DateTime>? instances,
    RepeatOptions? repeatOptions,
  });

  Future<bool> removeCircle({required Circle circle, required String uid});
  Future<Circle?> circleFromId(String id, String uid);
  Future<Circle?> circleFromPreviousIdAndState(
      {required String previousId,
      required List<SessionState> state,
      required String uid});
  Future<Circle?> circleFromPreviousIdAndNotState(
      {required String previousId,
      required List<SessionState> state,
      required String uid});
  Future<bool> canJoinCircle({required String circleId, required String uid});
  Stream<Circle?> circleStream(String circleId);
}
