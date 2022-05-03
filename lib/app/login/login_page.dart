import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/services/utils/device_type.dart';
import 'package:totem/theme/index.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_browser_detect/web_browser_detect.dart';

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final browser = Browser.detectOrNull();
    final isMobile = DeviceType.isMobile();
    final isSafari =
        kIsWeb && (browser?.browser.toLowerCase().contains('safari') ?? false);
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  t.welcome,
                  style: theme.textStyles.headline1,
                  textAlign: TextAlign.center,
                ),
                const Center(
                  child: ContentDivider(),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: !isMobile
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ThemedRaisedButton(
                        label: t.login,
                        width: 294,
                        onPressed: () {
                          Navigator.pushNamed(context, '/login/phone');
                        },
                      ),
                      if (isSafari)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            t.worksBestChrome,
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  )
                : _showGetMobileApp(context),
          ),
        ),
      ],
    );
  }

  Widget _showGetMobileApp(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return GestureDetector(
        onTap: () {
          //launchUrl(Uri.parse("https://play.google.com/store/apps/details?hl=en_US&id=<todo>"));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Image.asset('assets/android_download.png', height: 64),
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        // TODO - this should be modified to be App Store url when available
        launchUrl(Uri.parse("https://testflight.apple.com/join/p5k8gSEA"));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Image.asset('assets/ios_download.png', height: 64),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    return Scaffold(
      backgroundColor: themeColors.dialogBackground,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 4,
                child: Container(),
              ),
              Expanded(
                flex: 6,
                child: SvgPicture.asset(
                  'assets/background_shape.svg',
                  fit: BoxFit.fill,
                ),
              ),
            ],
          ),
          const _LoginPanel(),
        ],
      ),
    );
  }
}
