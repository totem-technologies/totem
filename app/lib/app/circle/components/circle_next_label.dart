import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:totem/theme/index.dart';

class CircleNextLabel extends StatelessWidget {
  const CircleNextLabel({super.key, this.fontSize = 13, this.reversed = false});
  final double fontSize;
  final bool reversed;

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    final textStyles = Theme.of(context).textStyles;
    final t = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: !reversed
                    ? themeColors.videoOverlayBackground
                    : themeColors.reversedVideoOverlayBackground,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      t.next,
                      maxLines: 1,
                      style: textStyles.headlineMedium!.merge(TextStyle(
                          color: !reversed
                              ? themeColors.reversedText
                              : themeColors.primaryText,
                          fontSize: fontSize)),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
