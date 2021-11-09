import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({Key? key, this.gradient, this.child}) : super(key: key);
  final List<Color>? gradient;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradient ?? themeColors.primaryGradient,
        ),
      ),
      child: child
    );

  }

}