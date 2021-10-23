import 'package:totem/models/index.dart';
// AuthService
// defines the auth service interface for specific auth service instances

enum AuthRequestState {
  entry,
  failed,
  pending,
  complete,
  timeout
}

abstract class AuthService {
  AuthUser? currentUser();
  Future<void> initialize();
  Future<AuthUser?> signInWithCode(String code);
  Future<void> signInWithPhoneNumber(String phoneNumber);
  Future<void> signOut();
  Future<void> verifyCode(String code);
  Stream<AuthUser?> get onAuthStateChanged;
  Stream<AuthRequestState> get onAuthRequestStateChanged;
  void dispose();
}