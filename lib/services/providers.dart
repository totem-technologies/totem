import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/analytics_provider.dart';
import 'package:totem/services/index.dart';

final authServiceProvider =
    Provider<AuthService>((ref) => FirebaseAuthService());

final authStateChangesProvider = StreamProvider<AuthUser?>(
    (ref) => ref.read(authServiceProvider).onAuthStateChanged);

final repositoryProvider =
    Provider<TotemRepository>((ref) => TotemRepository(ref));

final analyticsProvider = Provider<AnalyticsProvider>(
    (ref) => ref.read(repositoryProvider).analyticsProvider);
