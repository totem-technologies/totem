import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/analytics_provider.dart';
import 'package:totem/services/index.dart';

final authServiceProvider =
    Provider<AuthService>((ref) => FirebaseAuthService());

final authStateChangesProvider = StreamProvider<AuthUser?>(
    (ref) => ref.read(authServiceProvider).onAuthStateChanged);

final repositoryProvider =
    Provider<TotemRepository>((ref) => TotemRepository());

final analyticsProvider = Provider<AnalyticsProvider>(
    (ref) => ref.read(repositoryProvider).analyticsProvider);

final userAccountStateProvider = StreamProvider<AccountState?>((ref) {
  final authUser = ref.watch(authStateChangesProvider).asData?.value;
  if (authUser != null) {}
  return Stream<AccountState?>.value(null);
});

final userAuthAccountStateProvider =
    StreamProvider<UserAuthAccountState>((ref) {
  final authUser = ref.watch(authStateChangesProvider).asData?.value;
  final accountState = ref.watch(userAccountStateProvider).asData?.value;
  return Stream<UserAuthAccountState>.value(UserAuthAccountState(
      isLoggedIn: authUser != null, accountState: accountState));
});
