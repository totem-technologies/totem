import 'package:flutter/widgets.dart';
import 'package:totem/models/index.dart';

@immutable
class UserAuthAccountState {
  final AccountState? accountState;
  final UserProfile? userProfile;

  const UserAuthAccountState({
    this.accountState,
    this.userProfile,
  });
  bool get isLoggedIn => accountState != null && userProfile != null;

  UserAuthAccountState copyWith({
    AccountState? accountState,
    UserProfile? userProfile,
  }) {
    return UserAuthAccountState(
      accountState: accountState ?? this.accountState,
      userProfile: userProfile ?? this.userProfile,
    );
  }
}
