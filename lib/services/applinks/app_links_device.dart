import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import 'app_link_type.dart';

class AppLinks {
  static AppLinks? _instance;
  static AppLinks get instance {
    _instance ??= AppLinks();
    return _instance!;
  }

  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  late BehaviorSubject<AppLink?> _stream;
  late StreamSubscription _subscription;

  AppLinks() {
    _stream = BehaviorSubject<AppLink?>();
  }

  void dispose() {
    _subscription.cancel();
  }

  Future<void> initialize() async {
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      await _handleDynamicLink(initialLink.link);
    }
    _subscription = dynamicLinks.onLink.listen((dynamicLinkData) {
      _handleDynamicLink(dynamicLinkData.link);
    })
      ..onError((error) {
        debugPrint('onLink error');
        debugPrint(error.message);
      });
  }

  Stream<AppLink?> get linkStream {
    return _stream.stream;
  }

  Future<void> _handleDynamicLink(Uri link) async {
    debugPrint('Handling dynamic link: ${link.queryParameters.toString()}');
    for (var key in link.queryParameters.keys) {
      if (key == "snap") {
        _stream.add(AppLink(
            type: AppLinkType.snapSession, value: link.queryParameters[key]!));
      }
    }
  }
}
