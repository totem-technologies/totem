import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/account_state/account_state_event.dart';

class ProfileCompleteEvent extends AccountStateEvent {
  ProfileCompleteEvent()
      : super(stateKey: 'profileComplete', dialogHosted: false);
  UserProfile? _userProfile;
  @override
  Widget eventContent(BuildContext context, WidgetRef ref) {
    return OnboardingProfilePage(
      profile: _userProfile,
      onProfileUpdated: (userProfile) {},
    );
  }

  @override
  Future<void> updateAccountState(BuildContext context, WidgetRef ref) async {
    // This doesn't actually update the account state.
  }

  @override
  bool shouldShowEvent(UserAuthAccountState state) {
    _userProfile = state.userProfile;
    if (_userProfile != null) {
      if (_userProfile!.name.isEmpty ||
          _userProfile!.email == null ||
          _userProfile!.email!.isEmpty) {
        return true;
      }
      return false;
    }
    return false;
  }
}
