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
    required this.trayBackground,
    required this.trayBorder,
    required this.shadow,
  });

  final Color screenBackground;
  final Color primaryText;
  final Color reversedText;
  final Color primary;
  final Color dialogBackground;
  final Color trayBackground;
  final Color trayBorder;
  final Color shadow;
  final List<Color> primaryGradient;
  final List<Color> secondaryGradient;
}