import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class CircleLiveTrayTitle extends StatelessWidget {
  const CircleLiveTrayTitle({
    Key? key,
    required this.title,
    required this.maxWidth,
  }) : super(key: key);
  final String title;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    final themeColors = Theme.of(context).themeColors;
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, top: 8),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: (maxWidth / 2) - 160),
          child: AutoSizeText(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyles.headline2!.merge(
              TextStyle(
                  fontWeight: FontWeight.w600, color: themeColors.reversedText),
            ),
          ),
        ),
      ),
    );
  }
}
