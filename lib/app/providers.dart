import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/services/index.dart';
import 'package:totem/models/index.dart';

final authServiceProvider =
    Provider<AuthService>((ref) => FirebaseAuthService());

final authStateChangesProvider = StreamProvider.autoDispose<AuthUser?>(
    (ref) => ref.watch(authServiceProvider).onAuthStateChanged);

final repositoryProvider = Provider<TotemRepository>((_) => TotemRepository());
