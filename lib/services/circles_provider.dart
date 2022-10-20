import 'package:totem/models/index.dart';
import 'package:totem/models/repeat_options.dart';

abstract class CirclesProvider {
  Stream<List<SnapCircle>> snapCircles();
  Stream<List<SnapCircle>> rejoinableSnapCircles(String uid);
  Stream<List<SnapCircle>> mySnapCircles(String uid,
      {bool privateOnly, bool activeOnly});
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
    RecurringType? recurringType,
    List<DateTime>? instances,
    RepeatOptions? repeatOptions,
  });

  Future<bool> removeSnapCircle(
      {required SnapCircle circle, required String uid});
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
