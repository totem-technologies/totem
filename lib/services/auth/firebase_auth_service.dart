import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/auth/index.dart';
import 'package:totem/services/firebase_providers/paths.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  StreamSubscription<User?>? _listener;
  StreamSubscription<DocumentSnapshot?>? _reauthListener;
  BehaviorSubject<AuthUser?>? streamController;
  AuthUser? _currentUser;
  String? _pendingVerificationId;
  String? _lastRegisterError;
  BehaviorSubject<AuthRequestState>? _authRequestStateStreamController;
  bool newUser = false;
  String? _authRequestNumber;
  ConfirmationResult? _confirmationResult;
  bool _pendingSignIn = false;

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
      phoneNumber: user.phoneNumber ?? "",
    );
  }

  @override
  Stream<AuthRequestState> get onAuthRequestStateChanged {
    _assertRequestStateStream();
    return _authRequestStateStreamController!.stream;
  }

  @override
  Stream<AuthUser?> get onAuthStateChanged {
    _currentUser ??= _userFromFirebase(
      _firebaseAuth.currentUser,
    );
    streamController ??= BehaviorSubject<AuthUser?>();
    _listener ??= _firebaseAuth.authStateChanges().listen((User? user) async {
      // if user logs out, clear the auth state
      if (user == null) {
        _currentUser = null;
        streamController?.add(_currentUser);
      } else {
        if (_currentUser == null && !_pendingSignIn) {
          debugPrint('loading currently cached user at startup: ');
          _currentUser = _userFromFirebase(_firebaseAuth.currentUser);
        }
        if (_currentUser != null) {
          IdTokenResult idToken =
              await _firebaseAuth.currentUser!.getIdTokenResult();
          _currentUser!.updateFromIdToken(idToken);
          _reauthListener ??= FirebaseFirestore.instance
              .collection(Paths.userAccountState)
              .doc(_currentUser!.uid)
              .collection("auth")
              .doc("controls")
              .snapshots()
              .listen((DocumentSnapshot snapshot) async {
            try {
              if (snapshot.exists) {
                Map<String, dynamic> data =
                    snapshot.data() as Map<String, dynamic>;
                if (data.containsKey("refresh")) {
                  Timestamp refresh = snapshot["refresh"];
                  if (idToken.issuedAtTime == null ||
                      refresh.toDate().isAfter(idToken.issuedAtTime!)) {
                    idToken =
                        await _firebaseAuth.currentUser!.getIdTokenResult(true);
                    _currentUser!.updateFromIdToken(idToken);
                    streamController?.add(_currentUser);
                  }
                }
              }
            } catch (ex) {
              debugPrint('error getting user permissions: $ex');
            }
          });

          // this is a load event
          streamController?.add(_currentUser);
        }
      }
      _pendingSignIn = false;
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
        await _handleUserAuth(
            await _firebaseAuth.signInWithCredential(credential));
      } on FirebaseAuthException catch (e) {
        debugPrint('Error:$e');
        throw AuthException(code: e.code, message: e.message);
      }
    } else if (_confirmationResult != null) {
      try {
        final UserCredential credential =
            await _confirmationResult!.confirm(code);
        await _handleUserAuth(credential);
      } on FirebaseAuthException catch (fe) {
        debugPrint('Auth Error: ${fe.message}');
        throw AuthException(code: fe.code, message: fe.message);
      } catch (ex) {
        throw AuthException(code: "invalid", message: ex.toString());
      }
    } else {
      throw AuthException(
        code: AuthException.errorCodeRetrievalTimeout,
      );
    }
  }

  @override
  Future<void> signInWithPhoneNumber(String phoneNumber) async {
    _assertRequestStateStream();
    _pendingVerificationId = null;
    _lastRegisterError = null;
    _authRequestNumber = phoneNumber;
    _pendingSignIn = true;
    try {
      if (!kIsWeb) {
        await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Android only
            debugPrint('verificationCompleted');
            // should trigger auth state change
            try {
              await _handleUserAuth(
                  await _firebaseAuth.signInWithCredential(credential));
            } on FirebaseAuthException catch (e) {
              debugPrint('Error:$e');
              throw AuthException(code: e.code, message: e.message);
            }
            _authRequestStateStreamController!.add(AuthRequestState.complete);
          },
          verificationFailed: (FirebaseAuthException e) {
            debugPrint('verificationFailed');
            _lastRegisterError = "code: ${e.code}"; //e.message;
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
      } else {
        _confirmationResult = await _firebaseAuth.signInWithPhoneNumber(
          phoneNumber,
        );
        _authRequestStateStreamController!.add(AuthRequestState.pending);
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Error:$e');
      throw AuthException(code: e.code, message: e.message);
    } catch (e) {
      debugPrint('Error:$e');
      throw AuthException(code: "unknown", message: e.toString());
    }
  }

  @override
  Future<void> initialize() async {}

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

  @override
  String? get authRequestNumber => _authRequestNumber;

  void _assertRequestStateStream() {
    if (_authRequestStateStreamController == null) {
      _authRequestStateStreamController = BehaviorSubject<AuthRequestState>();
      _authRequestStateStreamController!.add(AuthRequestState.entry);
    }
  }

  Future<void> _handleUserAuth(UserCredential credential) async {
    bool isNewUser = credential.additionalUserInfo?.isNewUser ?? false;
    await _assertUserProfile(credential.user!.uid);
    _currentUser = _userFromFirebase(credential.user, isNewUser: isNewUser);
    IdTokenResult idToken = await _firebaseAuth.currentUser!.getIdTokenResult();
    _currentUser!.updateFromIdToken(idToken);
    streamController?.add(_currentUser);
  }

  Future<void> _assertUserProfile(String uid) async {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection(Paths.users).doc(uid);
    DocumentSnapshot userDataSnapshot = await userRef.get();
    if (!userDataSnapshot.exists) {
      // create placeholder
      DateTime now = DateTime.now();
      await userRef.set(
          {"created_on": now, "name": "", "updated_on": now, "last_seen": now});
    }
  }

  @override
  void cancelPendingCode() {
    // no option to cancel pending code with firebase auth, just reset the
    // state of the system. If there was a reset for firebase auth it would
    // be triggered here
    _authRequestStateStreamController!.add(AuthRequestState.entry);
  }

  @override
  Future<void> deleteAccount() async {
    try {
      HttpsCallable deleteSelf =
          FirebaseFunctions.instance.httpsCallable("deleteSelf");
      final results = await deleteSelf();
      if (results.data == true) {
        return signOut();
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Unable to delete account: $e');
    }
  }
}
