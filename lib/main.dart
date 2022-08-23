import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart'
    show kDebugMode, kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:totem/app.dart';
import 'package:totem/config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (const String.fromEnvironment('USE_EMULATOR') == 'true') {
    await _connectToFirebaseEmulator();
  }
  // remove # from url
  GoRouter.setUrlPathStrategy(UrlPathStrategy.path);

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

Future _connectToFirebaseEmulator() async {
  final emulatorHost = defaultTargetPlatform == TargetPlatform.android
      ? '10.0.2.2'
      : 'localhost';

  FirebaseFirestore.instance.settings = Settings(
    host: '$emulatorHost:8080',
    sslEnabled: false,
    persistenceEnabled: false,
  );
  FirebaseFunctions.instance.useFunctionsEmulator(emulatorHost, 5001);
  await FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);
}
