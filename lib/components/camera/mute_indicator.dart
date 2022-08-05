import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class MuteIndicator extends StatelessWidget {
  const MuteIndicator({Key? key, this.size = 32}) : super(key: key);
  final double size;

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    return Icon(
      Icons.mic_off,
      size: size,
      color: themeColors.reversedText,
    );
  }
}
