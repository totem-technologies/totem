import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:totem/theme/app_theme_styles.dart';

class WaitingForTotemUser extends StatelessWidget {
  const WaitingForTotemUser({Key? key}) : super(key: key);
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
            const Icon(Icons.hourglass_top, size: 100, color: Colors.white),
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
