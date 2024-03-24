import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:totem/app.dart';
import 'package:totem/config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initConfig();
  // remove # from url
  usePathUrlStrategy();

  // Initialize the App Check interface which allows access
  // to firebase
  // TODO - need to initialize web with recaptcha, for now disabled
  // if (!kIsWeb) {
  //   await FirebaseAppCheck.instance.activate();
  //   await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
  // }

  var release = await PackageInfo.fromPlatform();
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://66cc97ae272344978f48840710f857a0@o1324443.ingest.sentry.io/6582849';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 0.1;
      options.release = '${release.version} (${release.buildNumber})';
      if (kDebugMode) {
        options.environment = 'debug';
      } else {
        options.environment = 'production';
      }
    },
    appRunner: () {
      runApp(const ProviderScope(
        child: App(),
      ));
    },
  );
}
