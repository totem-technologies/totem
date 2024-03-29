import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/services/utils/index.dart';
import 'package:totem/theme/index.dart';
import 'package:web_browser_detect/web_browser_detect.dart';

class _LoginPanel extends StatelessWidget {
  const _LoginPanel();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final browser = Browser.detectOrNull();
    final isSafari = browser?.browserAgent == BrowserAgent.Safari;

    Widget loginButton = ThemedRaisedButton(
      cta: true,
      label: t.login,
      width: 220,
      onPressed: () {
        context.goNamed(AppRoutes.loginPhone);
      },
    );

    if (kIsWeb && DeviceType.isMobile()) {
      loginButton = Container();
    }

    return Column(
      children: [
        Expanded(
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      t.welcome,
                      style: theme.textStyles.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                    const Center(
                      child: ContentDivider(),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
              ),
              SvgPicture.asset(
                'assets/totem_icon.svg',
                colorFilter: ColorFilter.mode(
                    theme.themeColors.primaryText, BlendMode.srcIn),
                height: 200,
              ),
              Container(
                height: 50,
              ),
              _showGetMobileApp(context),
              Container(
                height: 10,
              ),
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
        Container(
          height: 50,
        )
      ],
    );
  }

  Widget _showGetMobileApp(BuildContext context) {
    if (!kIsWeb) {
      return Container();
    }
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
  const WelcomePage({super.key});

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
