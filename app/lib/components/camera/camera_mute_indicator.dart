import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/theme/index.dart';

class CameraMuteIndicator extends StatelessWidget {
  const CameraMuteIndicator(
      {Key? key, this.size = 32, this.color, this.shadow = true})
      : super(key: key);
  final double size;
  final Color? color;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    return shadow
        ? DecoratedIcon(
            LucideIcons.videoOff,
            size: size,
            color: color ?? themeColors.reversedText,
            shadows: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 5,
                spreadRadius: 0,
                offset: Offset.zero,
              ),
            ],
          )
        : Icon(
            LucideIcons.videoOff,
            size: size,
            color: color ?? themeColors.reversedText,
          );
  }
}
