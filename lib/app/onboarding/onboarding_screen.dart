import 'dart:async';
import 'dart:ui';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/providers.dart';
import 'package:totem/services/utils/device_type.dart';
import 'package:totem/theme/index.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen(
      {Key? key,
      this.pendingSession,
      required this.onComplete,
      this.updateState = true})
      : super(key: key);
  final Session? pendingSession;
  final Function(bool) onComplete;
  final bool updateState;

  static Future<bool?> showOnboarding(BuildContext context,
      {Session? pendingSession,
      required Function(bool) onComplete,
      bool updateState = true}) async {
    return DeviceType.isPhone()
        ? showModalBottomSheet<bool?>(
            enableDrag: false,
            isScrollControlled: true,
            isDismissible: false,
            context: context,
            backgroundColor: Colors.transparent,
            barrierColor: Theme.of(context).themeColors.blurBackground,
            builder: (_) => OnboardingScreen(
              pendingSession: pendingSession,
              onComplete: onComplete,
              updateState: updateState,
            ),
          )
        : showDialog(
            context: context,
            barrierColor: Theme.of(context).themeColors.blurBackground,
            barrierDismissible: false,
            builder: (BuildContext context) => OnboardingScreen(
              onComplete: onComplete,
              pendingSession: pendingSession,
              updateState: updateState,
            ),
          );
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      OnboardingScreenState();
}

class OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with AfterLayoutMixin {
  @override
  Widget build(BuildContext context) {
    return (DeviceType.isPhone())
        ? _introScreen(context)
        : BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: DialogContainer(
                  padding: const EdgeInsets.only(
                      top: 40, bottom: 20, left: 20, right: 20),
                  child: SizedBox(
                    height: 450,
                    child: _introScreen(context),
                  ),
                ),
              ),
            ),
          );
  }

  Widget _introScreen(BuildContext context) {
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
            title: t.introScreenTitle1,
            body: t.introScreenMessage1,
            image: "onboarding_totem_icon"),
        _pageWith(
            title: t.introScreenTitle2,
            body: t.introScreenMessage2,
            image: "onboarding_play_button"),
        _pageWith(
            title: t.introScreenTitle3,
            body: t.introScreenMessage3,
            image: "onboarding_talking_person"),
        _pageWith(
            title: t.introScreenTitle4,
            body: t.introScreenMessage4,
            image: "onboarding_pass_baton"),
        _pageWith(
            title: t.introScreenTitle5,
            body: t.introScreenMessage5,
            image: "onboarding_help_book"),
        _pageWith(
            title: t.introScreenTitle6,
            body: t.introScreenMessage6,
            image: "onboarding_finish_flag"),
      ],
      onDone: () {
        widget.onComplete(true);
      },
      onSkip: () {
        widget.onComplete(false);
      },
    );
  }

  Future<void> updateOnboardingState() async {
    await ref
        .read(repositoryProvider)
        .updateAccountStateValue(AccountState.onboarded, true);
  }

  PageViewModel _pageWith(
      {required String title, required String body, required String image}) {
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
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        bodyTextStyle: TextStyle(fontSize: 16, height: 1.7),
        imageFlex: 2,
        bodyFlex: 3,
      ),
    );
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    // onboarding has been shown, update the user account state
    if (widget.updateState) {
      updateOnboardingState();
    }
  }
}
