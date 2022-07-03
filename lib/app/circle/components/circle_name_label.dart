import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class CircleNameLabel extends StatelessWidget {
  const CircleNameLabel({Key? key, required this.name}) : super(key: key);
  final String name;

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    final textStyles = Theme.of(context).textStyles;
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: themeColors.videoOverlayBackground,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            name,
            style: textStyles.headline4!
                .merge(TextStyle(color: themeColors.reversedText)),
          ),
        ),
      ),
    );
  }
}
