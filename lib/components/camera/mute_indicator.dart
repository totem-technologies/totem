import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:totem/theme/index.dart';

class MuteIndicator extends StatelessWidget {
  const MuteIndicator({Key? key, this.size = 32}) : super(key: key);
  final double size;

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: SvgPicture.asset(
          'assets/microphone_mute.svg',
          color: themeColors.reversedText,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
