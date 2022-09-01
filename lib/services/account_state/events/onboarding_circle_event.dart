import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:totem/services/account_state/account_state_event.dart';
import 'package:totem/services/providers.dart';
import 'package:totem/services/utils/device_type.dart';
import 'package:totem/theme/index.dart';

class OnboardingCircleEvent extends AccountStateEvent {
  OnboardingCircleEvent({bool testOnly = false})
      : super(testOnly: testOnly, stateKey: 'onboarded');

  @override
  Widget eventContent(BuildContext context, WidgetRef ref) {
    bool isPhone = DeviceType.isPhone();
    if (isPhone) {
      return Material(
        color: Theme.of(context).themeColors.screenBackground,
        child: SafeArea(
          top: true,
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: _introScreen(context, isPhone),
          ),
        ),
      );
    }
    return SizedBox(
      height: 450,
      child: _introScreen(context, isPhone),
    );
  }

  Widget _introScreen(BuildContext context, bool isPhone) {
    final t = AppLocalizations.of(context)!;
    return IntroductionScreen(
      showSkipButton: true,
      dotsFlex: 2,
      globalBackgroundColor: Colors.transparent,
      done: Text(t.done),
      next: Text(t.next),
      skip: Text(t.skip),
      pages: [
        _pageWith(
            title: "Welcome to Totem",
            body: """This is not a meeting. 
This is a confidential space for us to share and grow.
The Keeper, a discussion facilitator, will be your guide.""",
            image: "onboarding_totem_icon",
            isPhone: isPhone),
        _pageWith(
            title: "Listening",
            body: """You’ll start by listening.
The person with the totem, or talking piece, is the speaker.
Once the speaker is done, they will pass the totem to the next person in the circle.
""",
            image: "onboarding_play_button",
            isPhone: isPhone),
        _pageWith(
            title: "Sharing",
            body:
                """Press “Receive” to accept the totem when it’s your turn to share.
You can respond to the prompt, share a story, or react to a share.
Always speak from your own experience, do not offer advice.
It’s always OK to not say anything at all.
Press “Pass” to hand the totem to the next person.
""",
            image: "onboarding_talking_person",
            isPhone: isPhone),
        _pageWith(
            title: "Let’s Begin!",
            body:
                """Make sure you are in a quiet place where you are unlikely to be distracted.
Disable all notifications, put everything on silent.
Enjoy this rare opportunity to be heard without interruption.
""",
            image: "onboarding_finish_flag",
            isPhone: isPhone),
      ],
      onDone: () {
        Navigator.of(context).pop();
      },
      onSkip: () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Future<void> updateAccountState(BuildContext context, WidgetRef ref) async {
    await ref.read(repositoryProvider).updateAccountStateValue(stateKey, true);
  }

  PageViewModel _pageWith(
      {required String title,
      required String body,
      required String image,
      required bool isPhone}) {
    return PageViewModel(
      title: title,
      body: body,
      image: Image(
        image: ResizeImage(
            AssetImage(
              'assets/$image.png',
            ),
            height: 250),
      ),
      decoration: PageDecoration(
        titleTextStyle:
            const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        bodyTextStyle: const TextStyle(fontSize: 16, height: 2),
        imageFlex: (isPhone ? 1 : 2),
        bodyFlex: 3,
      ),
    );
  }
}
