import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:totem/theme/index.dart';

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Center(
                  child: ContentDivider(),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: ThemedRaisedButton(
              label: t.login,
              width: 294,
              onPressed: () {
                Navigator.pushNamed(context, '/login/phone');
              },
            ),
          ),
        ),
      ],
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    return GradientBackground(
      gradient: themeColors.welcomeGradient,
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: Container()),
                  SvgPicture.asset(
                    'assets/background_shape_2.svg',
                    fit: BoxFit.fill,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: Container()),
                  SvgPicture.asset(
                    'assets/background_shape.svg',
                    fit: BoxFit.fill,
                  )
                ],
              ),
              const _LoginPanel(),
            ],
          )),
    );
  }
}
