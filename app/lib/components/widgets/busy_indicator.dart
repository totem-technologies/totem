import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class BusyIndicator extends StatelessWidget {
  const BusyIndicator({super.key, this.size = 50, this.color});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        color: color ?? themeColors.busyIndicator,
      )
    );
  }
}