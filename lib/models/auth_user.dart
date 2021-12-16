import 'package:flutter/material.dart';

class AuthUser with ChangeNotifier {
  AuthUser({
    required this.uid,
    this.email,
    this.photoUrl,
    this.displayName = "",
    this.isNewUser = false,
    this.isAnonymous = false,
    this.phoneNumber = "",
  });

  final String uid;
  final String? email;
  String? photoUrl;
  String phoneNumber;
  String displayName;
  bool isNewUser;
  bool isAnonymous;

  void updateNewUser(bool newUser) {
    isNewUser = newUser;
    notifyListeners();
  }
}
