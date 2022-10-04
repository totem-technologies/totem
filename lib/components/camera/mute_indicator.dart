import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class MuteIndicator extends StatelessWidget {
  const MuteIndicator(
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
            Icons.mic_off,
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
            Icons.mic_off,
            size: size,
            color: color ?? themeColors.reversedText,
          );
  }
}
