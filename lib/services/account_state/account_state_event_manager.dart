import 'package:flutter/material.dart';
import 'package:totem/models/account_state.dart';
import 'package:totem/services/account_state/account_state_dialog.dart';
import 'package:totem/services/account_state/account_state_event.dart';
import 'package:totem/services/account_state/pre_circle_events/onboarding_circle_event.dart';

class AccountStateEventManager {
  final List<AccountStateEvent> homeEvents = [];
  final List<AccountStateEvent> preCircleEvents = [OnboardingCircleEvent()];

  Future<void> handleHomeEvents(
      BuildContext context, AccountState accountState) async {
    await _handleEvents(context, accountState, homeEvents);
  }

  Future<void> handlePreCircleEvents(
      BuildContext context, AccountState accountState) async {
    await _handleEvents(context, accountState, preCircleEvents);
  }

  Future<void> _handleEvents(BuildContext context, AccountState accountState,
      List<AccountStateEvent> events) async {
    for (AccountStateEvent event in events) {
      if (event.shouldShowEvent(context, accountState)) {
        await AccountStateDialog.showEvent(context, event: event);
      }
    }
  }
}
