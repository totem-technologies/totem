import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class CircleNameLabel extends StatelessWidget {
  const CircleNameLabel(
      {Key? key, required this.name, this.fontSize = 13, required this.role})
      : super(key: key);
  final String name;
  final double fontSize;
  final Role role;

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    return LayoutBuilder(
      builder: (context, constraints) {
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
              child: role == Role.member
                  ? userName(context)
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth - 30),
                            child: userName(context),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(LucideIcons.star,
                            color: themeColors.reversedText, size: 16),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget userName(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    final textStyles = Theme.of(context).textStyles;
    return Text(
      name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textStyles.headlineMedium!.merge(
          TextStyle(color: themeColors.reversedText, fontSize: fontSize)),
    );
  }
}
