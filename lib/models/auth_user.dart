import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:totem/models/roles.dart';

class AuthUser with ChangeNotifier {
  AuthUser({
    required this.uid,
    this.email,
    this.photoUrl,
    this.displayName = "",
    this.isNewUser = false,
    this.isAnonymous = false,
    this.phoneNumber = "",
    this.roles = const [],
  });

  final String uid;
  final String? email;
  String? photoUrl;
  String phoneNumber;
  String displayName;
  bool isNewUser;
  bool isAnonymous;
  List<String> roles;

  void updateNewUser(bool newUser) {
    isNewUser = newUser;
    notifyListeners();
  }

  void updateFromIdToken(IdTokenResult idToken) {
    // If the idToken has roles in the custom claims then update the user roles
    if (idToken.claims != null && idToken.claims!['roles'] != null) {
      try {
        roles = List<String>.from(idToken.claims!['roles']);
        notifyListeners();
      } catch (e) {
        debugPrint('Error updating user roles: $e');
      }
    }
  }

  bool hasRole(Role role) {
    return roles.contains(role.name);
  }

  String roleName(AppLocalizations t) {
    if (hasRole(Role.admin)) {
      return t.admin;
    } else if (hasRole(Role.keeper)) {
      return t.keeper;
    } else {
      return t.member;
    }
  }
}
