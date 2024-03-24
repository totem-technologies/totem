import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:totem/components/index.dart';
import 'package:totem/theme/app_theme_styles.dart';

class WaitingForTotemUser extends StatelessWidget {
  const WaitingForTotemUser({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final themeData = Theme.of(context);
    final themeColors = themeData.themeColors;

    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WaitAnimation(
                color: themeColors.primary,
                imageColor: themeColors.reversedText,
                size: 200),
            const SizedBox(
              height: 20,
            ),
            Text(
              t.circleWaitForUser,
              style: TextStyle(color: themeColors.reversedText, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
