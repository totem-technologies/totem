import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/account_state/account_state_event_manager.dart';
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

final userAccountStateProvider = StreamProvider<UserAuthAccountState>((ref) {
  final authService = ref.read(authServiceProvider);
  final totemRepository = ref.read(repositoryProvider);
  return UserAccountStateProvider(
          authStream: authService.onAuthStateChanged,
          repository: totemRepository)
      .stream;
});

final accountStateEventManager = StateProvider<AccountStateEventManager>((ref) {
  final userAccountState = ref.watch(userAccountStateProvider);
  return AccountStateEventManager(
      authAccountState: userAccountState.asData?.value);
});
