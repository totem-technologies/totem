import 'package:rxdart/rxdart.dart';

import 'app_link_type.dart';

class AppLinks {
  static late AppLinks? _instance;
  static AppLinks get instance {
    _instance ??= AppLinks();
    return _instance!;
  }

  late BehaviorSubject<AppLink?> _stream;

  AppLinks() {
    _stream = BehaviorSubject<AppLink?>();
  }

  Future<void> initialize() async {}

  Stream<AppLink?> get linkStream {
    return _stream.stream;
  }
}
