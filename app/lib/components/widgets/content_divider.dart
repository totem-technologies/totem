import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class ContentDivider extends StatelessWidget {
  const ContentDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        width: 80,
        height: 4,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(2)),
          color: themeColors.primary,
        ),
      ),
    );
  }
}
