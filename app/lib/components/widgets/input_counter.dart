import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:totem/theme/app_theme_styles.dart';

class InputCounter {
  static Widget counterWidget(BuildContext context,
      {required currentLength, maxLength, required isFocused}) {
    final t = AppLocalizations.of(context)!;
    final remaining = maxLength - currentLength;
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        t.characterCount(remaining),
        style: Theme.of(context).textStyles.hintInputLabel.merge(
              TextStyle(
                  color: remaining == 0
                      ? Theme.of(context).themeColors.error
                      : Theme.of(context).themeColors.secondaryText),
            ),
      ),
    );
  }
}
