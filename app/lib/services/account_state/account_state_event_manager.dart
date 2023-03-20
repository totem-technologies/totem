import 'package:flutter/material.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/account_state/index.dart';

enum AccountStateEventType {
  // Events shown before any other screen is shown
  startup,
  // Shown on the home screen the first time the user opens the app.
  home,
  // Events shown before the circle is allowed to be shown
  preCircle
}

@immutable
class AccountStateEventManager {
  final UserAuthAccountState? authAccountState;
  AccountStateEventManager({this.authAccountState});

  final Map<AccountStateEventType, List<AccountStateEvent>> _events = {
    AccountStateEventType.startup: [ProfileCompleteEvent()],
    AccountStateEventType.home: [],
    AccountStateEventType.preCircle: [OnboardingCircleEvent()],
  };

  Future<void> handleEvents(
    BuildContext context, {
    required AccountStateEventType type,
    Future<void> Function(AccountStateEvent)? onShowEvent,
  }) async {
    if (authAccountState == null) {
      return;
    }
    List<AccountStateEvent> events = _events[type]!;
    for (AccountStateEvent event in events) {
      if (event.shouldShowEvent(authAccountState!)) {
        if (event.dialogHosted) {
          await AccountStateDialog.showEvent(context, event: event);
        } else if (onShowEvent != null) {
          await onShowEvent(event);
        }
      }
    }
  }

  bool shouldShowEvents(AccountStateEventType type) {
    if (authAccountState == null) {
      return false;
    }
    List<AccountStateEvent> events = _events[type]!;
    for (AccountStateEvent event in events) {
      if (event.shouldShowEvent(authAccountState!)) {
        return true;
      }
    }
    return false;
  }
}
