import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:universal_html/html.dart';

import 'app_link_type.dart';

class AppLinks {
  static AppLinks? _instance;
  static AppLinks get instance {
    _instance ??= AppLinks();
    return _instance!;
  }

  late BehaviorSubject<AppLink?> _stream;

  AppLinks() {
    _stream = BehaviorSubject<AppLink?>();
  }

  Stream<AppLink?> get linkStream {
    return _stream.stream;
  }

  Future<void> initialize() async {
    _getInitialLink();
  }

  void _getInitialLink() {
    // try reading the web parameters if present
    var uri = Uri.dataFromString(window.location.href);
    Map<String, String> params = uri.queryParameters;
//    var origin = params['origin'];
//    var destiny = params['destiny'];
    if (params.isNotEmpty) {
      for (var key in params.keys) {
        if (key == "snap") {
          debugPrint('Found snap session: $key > ${params[key]!}');
          _stream
              .add(AppLink(type: AppLinkType.snapSession, value: params[key]!));
        }
      }
    }
  }
}
