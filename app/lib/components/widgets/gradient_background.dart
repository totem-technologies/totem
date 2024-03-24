import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';
import 'dart:math' as math;

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, this.gradient, this.child, this.rotation});
  final List<Color>? gradient;
  final Widget? child;
  final double? rotation;

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradient ?? themeColors.primaryGradient,
            transform: rotation != null
                ? GradientRotation(rotation! * math.pi / 180)
                : null,
          ),
        ),
        child: child);
  }
}
