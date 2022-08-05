import 'package:flutter/widgets.dart';

import 'account_state.dart';

@immutable
class UserAuthAccountState {
  final bool isLoggedIn;
  final AccountState? accountState;

  const UserAuthAccountState({
    this.isLoggedIn = false,
    this.accountState,
  });
}
