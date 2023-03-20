import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/models/index.dart';

abstract class AccountStateEvent {
  UserAuthAccountState? accountState;
  late final String stateKey;
  late final bool testOnly;
  final double maxWidth = 600;
  final bool fullScreenPhone = true;
  final bool dialogHosted;

  AccountStateEvent(
      {this.testOnly = false,
      required this.stateKey,
      this.dialogHosted = true});

  // content to render in the dialog
  Widget eventContent(BuildContext context, WidgetRef ref);

  // whether or not to show the event based on some data evaluation,
  // the basic implementation is the attribute is a bool value, but
  // it can be overridden to do more complex evaluations
  bool shouldShowEvent(UserAuthAccountState state) {
    accountState = state;
    return !(accountState?.accountState?.boolAttribute(stateKey) ?? true);
  }

  // update the account state with the event value, most of the time
  // just updating the account state table should be sufficient
  Future<void> updateAccountState(BuildContext context, WidgetRef ref);
}
