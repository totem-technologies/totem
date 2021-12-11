import 'package:totem/models/index.dart';

class ScheduledSession extends Session {
  late final String _ref;
  late DateTime scheduledDate;
  late SessionState _state;

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
    if (json['state'] != null) {
      _state = SessionState.values.byName(json['state']);
    } else {
      _state = SessionState.pending;
    }
  }

  @override
  SessionState get state {
    return _state;
  }

  @override
  set state(SessionState stateVal) {
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
    item["state"] = _state.name;
    return item;
  }
}
