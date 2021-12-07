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
    final theme = Theme.of(context);
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
