import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/totem_repository.dart';

class ScheduledCirclesProvider {
  ScheduledCirclesProvider(
      {required Stream<AuthUser?> authStream,
      required this.repository,
      this.timeRefreshDuration = 60,
      this.timeWindowDuration = 1800}) {
    _streamController = BehaviorSubject<List<Circle>>();
    _authStateSubscription = authStream.listen((authUser) {
      if (authUser != null) {
        _updateScheduledCircles();
      } else {
        _scheduledCirclesSubscription?.cancel();
        _timer?.cancel();
      }
    });
  }

  final int timeWindowDuration;
  final int timeRefreshDuration;
  final TotemRepository repository;
  StreamSubscription? _authStateSubscription;
  StreamSubscription? _scheduledCirclesSubscription;
  Timer? _timer;
  late BehaviorSubject<List<Circle>> _streamController;

  Stream<List<Circle>> get stream => _streamController.stream;

  void _updateScheduledCircles() {
    _timer?.cancel();
    _scheduledCirclesSubscription?.cancel();
    // fetch the user profile data
    final scheduledStream = repository.scheduledUpcomingCircles(
        timeWindowDuration: timeWindowDuration);
    _scheduledCirclesSubscription = scheduledStream.listen((circles) {
      _streamController.add(circles);
    });
    _timer = Timer.periodic(Duration(seconds: timeRefreshDuration), (timer) {
      _updateScheduledCircles();
    });
  }

  void dispose() {
    _timer?.cancel();
    _scheduledCirclesSubscription?.cancel();
    _authStateSubscription?.cancel();
    _streamController.close();
  }
}
