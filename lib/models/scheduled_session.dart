import 'package:totem/models/index.dart';

class ScheduledSession extends Session {
  late final String _ref;
  late DateTime scheduledDate;
  late String _state;

  ScheduledSession.fromJson(
    Map<String, dynamic> json, {
    required String id,
    required String ref,
    required Circle circle,
  }) : super.fromJson(
          json,
          id: id,
          circle: circle,
        ) {
    _ref = ref;
    scheduledDate = DateTimeEx.fromMapValue(json['scheduledDate'])!;
    _state = json['state'] ?? SessionState.pending;
  }

  @override
  String get state {
    return _state;
  }

  @override
  set state(String stateVal) {
    _state = stateVal;
  }

  @override
  String get ref {
    return _ref;
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> item = super.toJson();
    item["scheduledData"] = scheduledDate;
    item["state"] = _state;
    return item;
  }
}
