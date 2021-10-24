import 'package:flutter/material.dart';

class AppThemeColors {
  AppThemeColors({
    required this.screenBackground,
    required this.primaryText,
    required this.reversedText,
    required this.primary,
    required this.primaryButtonBackground,
    required this.dialogBackground,
    required this.primaryGradient,
    required this.secondaryGradient,
    required this.trayBackground,
    required this.trayBorder,
    required this.shadow,
    required this.error,
  });

  final Color dialogBackground;
  final Color error;
  final Color primary;
  final Color primaryButtonBackground;
  final Color primaryText;
  final Color reversedText;
  final Color screenBackground;
  final Color shadow;
  final Color trayBackground;
  final Color trayBorder;
  final List<Color> primaryGradient;
  final List<Color> secondaryGradient;
}