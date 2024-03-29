import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';

import './firebase_options_dev.dart' as dev;
import './firebase_options_prod.dart' as prod;

class AppConfig {
  static const agoriaAppID = '4880737da9bf47e290f46d847cd1c3b1';
  static const environment =
      String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');
  static const useEmulator = String.fromEnvironment('USE_EMULATOR') == 'true';
  static const isDev = environment == 'dev';
}

Future<void> initConfig() async {
  debugPrint('Initializing Firebase for ${AppConfig.environment}...');

  try {
    if (Firebase.apps.isNotEmpty) {
      debugPrint('Firebase already initialized');
      return;
    }
  } catch (_) {}

  var environments = {
    'dev': dev.DefaultFirebaseOptions.currentPlatform,
    'prod': prod.DefaultFirebaseOptions.currentPlatform
  };

  try {
    await Firebase.initializeApp(options: environments[AppConfig.environment]);
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }

  if (AppConfig.useEmulator) {
    await _connectToFirebaseEmulator();
  }
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
