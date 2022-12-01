import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/services/utils/device_type.dart';
import 'package:totem/theme/index.dart';
import 'package:web_browser_detect/web_browser_detect.dart';

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final browser = Browser.detectOrNull();
    final isMobile = DeviceType.isMobile();
    final isSafari = browser?.browserAgent == BrowserAgent.Safari;

    final loginButton = ThemedRaisedButton(
      label: t.login,
      width: 294,
      onPressed: () {
        context.goNamed(AppRoutes.loginPhone);
      },
    );

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
        SvgPicture.asset(
          'assets/totem_icon.svg',
          color: theme.themeColors.primaryText,
          height: 200,
        ),
        Expanded(
          child: Center(
              child: isMobile && kIsWeb
                  ? _showGetMobileApp(context)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        loginButton,
                        if (isSafari)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              t.worksBestChrome,
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    )),
        ),
      ],
    );
  }

  Widget _showGetMobileApp(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            DataUrls.launch(DataUrls.appleStore);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Image.asset('assets/ios_download.png', height: 64),
          ),
        ),
        GestureDetector(
          onTap: () {
            DataUrls.launch(DataUrls.androidStore);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Image.asset('assets/android_download.png', height: 64),
          ),
        )
      ],
    );
  }
}

class WelcomePage extends ConsumerWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColors = Theme.of(context).themeColors;
    final authState = ref.watch(authStateChangesProvider);
    return Scaffold(
      backgroundColor: themeColors.altBackground,
      body: Stack(
        children: [
          // MetaballsBackground(
          //   color: themeColors.primary,
          // ),
          Positioned.fill(
              child: authState.when(loading: () {
            return const Center(
              child: BusyIndicator(),
            );
          }, error: (Object error, StackTrace? stackTrace) {
            return const Center(child: Text('error'));
          }, data: (AuthUser? data) {
            if (data == null) {
              return const _LoginPanel();
            }
            return Container();
          })),
        ],
      ),
    );
  }
}

// class MetaballsBackground extends StatelessWidget {
//   const MetaballsBackground({super.key, required this.color});
//   final Color color;

//   @override
//   Widget build(BuildContext context) {
//     return ImageFiltered(
//       imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//       child: Metaballs(
//           color: color,
//           metaballs: 5,
//           animationDuration: const Duration(milliseconds: 200),
//           speedMultiplier: 1,
//           bounceStiffness: 3,
//           minBallRadius: 70,
//           maxBallRadius: 200,
//           glowRadius: 0.7,
//           glowIntensity: 0.6),
//     );
//   }
// }
