import 'package:flutter/material.dart';

class AppThemeColors {
  AppThemeColors({
    required this.screenBackground,
    required this.primaryText,
    required this.reversedText,
    required this.primary,
    required this.dialogBackground,
    required this.primaryGradient,
    required this.secondaryGradient,
  });

  final Color screenBackground;
  final Color primaryText;
  final Color reversedText;
  final Color primary;
  final Color dialogBackground;
  final List<Color> primaryGradient;
  final List<Color> secondaryGradient;
}