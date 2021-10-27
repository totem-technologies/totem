import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:totem/services/auth/auth_exception.dart';
import 'package:totem/services/auth/index.dart';
import 'auth_service.dart';
import 'package:totem/models/index.dart';


class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  StreamSubscription<User?>? _listener;
  BehaviorSubject<AuthUser?>? streamController;
  AuthUser? _currentUser;
  String? _pendingVerificationId;
  String? _lastRegisterError;
  BehaviorSubject<AuthRequestState>? _authRequestStateStreamController;

  AuthUser? _userFromFirebase(User? user, {bool isNewUser = false}) {
    if (user == null) {
      return null;
    }

    return AuthUser(
      isNewUser: isNewUser,
      uid: user.uid,
      email: user.email,
      displayName: user.displayName ?? "",
      photoUrl: user.photoURL,
      isAnonymous: user.isAnonymous,
    );
  }

  @override
  Stream<AuthRequestState> get onAuthRequestStateChanged {
    _assertRequestStateStream();
    return _authRequestStateStreamController!.stream;
  }

  @override
  Stream<AuthUser?> get onAuthStateChanged {
    _currentUser =  _userFromFirebase(_firebaseAuth.currentUser, );
    streamController ??= BehaviorSubject<AuthUser?>();
    _listener ??= _firebaseAuth.authStateChanges().listen((User? user) async {
        // if user logs out, clear the auth state
        if (user == null) {
          _currentUser = null;
          streamController?.add(_currentUser);
        } else if (_currentUser != null) {
          // this is a load event
          streamController?.add(_currentUser);
        } else {
          _currentUser = _userFromFirebase(user);
          streamController?.add(_currentUser);
        }
      });
    return streamController!.stream;
  }

  @override
  AuthUser? currentUser() {
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _authRequestStateStreamController?.add(AuthRequestState.entry);
  }

  @override
  void dispose() {}

  @override
  Future<AuthUser?> signInWithCode(String code) async {
    return null;
  }

  @override
  Future<void> verifyCode(String code) async {
    if (_pendingVerificationId != null) {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _pendingVerificationId!,
        smsCode: code,
      );
      try {
        await _firebaseAuth.signInWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        debugPrint('Error:' + e.toString());
        throw AuthException(code: e.code, message: e.message);
      }
    } else {
      throw AuthException(code: AuthException.errorCodeRetrievalTimeout,);
    }
  }

  @override
  Future<void> signInWithPhoneNumber(String phoneNumber) async {
    _assertRequestStateStream();
    _pendingVerificationId = null;
    _lastRegisterError = null;
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Android only
        debugPrint('verificationCompleted');
        // should trigger auth state change
        await _firebaseAuth.signInWithCredential(credential);
        _authRequestStateStreamController!.add(AuthRequestState.complete);
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint('verificationFailed');
        _lastRegisterError = "code: " + e.code; //e.message;
        _authRequestStateStreamController!.add(AuthRequestState.failed);
      },
      codeSent: (String verificationId, int? resendToken) {
        debugPrint('codeSent');
        _pendingVerificationId = verificationId;
        _authRequestStateStreamController!.add(AuthRequestState.pending);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        debugPrint('codeAutoRetrievalTimeout');
      },
    );
  }

  @override
  Future<void> initialize() async {
  }

  @override
  String? get lastRegisterError {
    return _lastRegisterError;
  }

  @override
  void resetAuthError() {
    _assertRequestStateStream();
    _lastRegisterError = null;
    _authRequestStateStreamController!.add(AuthRequestState.entry);
  }


  void _assertRequestStateStream() {
    if (_authRequestStateStreamController == null) {
      _authRequestStateStreamController = BehaviorSubject<AuthRequestState>();
      _authRequestStateStreamController!.add(AuthRequestState.entry);
    }
  }
}
