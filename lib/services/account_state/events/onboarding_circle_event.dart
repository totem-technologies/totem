import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:totem/services/account_state/account_state_event.dart';
import 'package:totem/services/providers.dart';
import 'package:totem/services/utils/device_type.dart';
import 'package:totem/theme/index.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
            title: t.introScreenTitle1,
            body: t.introScreenMessage1,
            image: "onboarding_totem_icon",
            isPhone: isPhone),
        _pageWith(
            title: t.introScreenTitle2,
            body: t.introScreenMessage2,
            image: "onboarding_play_button",
            isPhone: isPhone),
        _pageWith(
            title: t.introScreenTitle3,
            body: t.introScreenMessage3,
            image: "onboarding_talking_person",
            isPhone: isPhone),
        _pageWith(
            title: t.introScreenTitle4,
            body: t.introScreenMessage4,
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
    var style = MarkdownStyleSheet(
        textAlign: WrapAlignment.center,
        h1Align: WrapAlignment.center,
        p: const TextStyle(
          fontSize: 16,
          height: 1.7,
        ));
    return PageViewModel(
      title: title,
      bodyWidget: MarkdownBody(
        data: body,
        styleSheet: style,
      ),
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
        bodyTextStyle: const TextStyle(fontSize: 16, height: 1.7),
        imageFlex: (isPhone ? 1 : 2),
        bodyFlex: 3,
      ),
    );
  }
}
