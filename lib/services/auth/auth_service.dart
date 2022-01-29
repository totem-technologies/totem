import 'package:totem/models/index.dart';
import 'package:flutter/foundation.dart';
// AuthService
// defines the auth service interface for specific auth service instances

enum AuthRequestState { entry, failed, pending, complete, timeout }

abstract class AuthService {
  AuthUser? currentUser();
  Future<void> initialize();
  Future<AuthUser?> signInWithCode(String code);
  Future<void> signInWithPhoneNumber(String phoneNumber,
      {required VoidCallback completed,
      required VoidCallback failed,
      required VoidCallback codeSent,
      required VoidCallback timeout});
  Future<void> signOut();
  Future<void> verifyCode(String code);
  Stream<AuthUser?> get onAuthStateChanged;
  String? get lastRegisterError;
  void resetAuthError();
  void dispose();
}
