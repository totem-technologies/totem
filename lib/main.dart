import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:totem/app.dart';
import 'package:totem/firebase_options.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialize the App Check interface which allows access
  // to firebase

  // TODO - need to initialize web with recaptcha, for now disabled
  if (!kIsWeb) {
    await FirebaseAppCheck.instance.activate();
    await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
  }

  if (!kIsWeb) {
    if (kDebugMode) {
      // Force disable Crashlytics collection while doing every day development.
      // Temporarily toggle this to true if you want to test crash reporting in your app.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    } else {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    }
  }
  var release = await PackageInfo.fromPlatform();
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://66cc97ae272344978f48840710f857a0@o1324443.ingest.sentry.io/6582849';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
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
