import 'package:flutter/material.dart';

class AppThemeColors {
  AppThemeColors({
    required this.screenBackground,
    required this.primaryText,
    required this.secondaryText,
    required this.reversedText,
    required this.primary,
    required this.primaryButtonBackground,
    required this.dialogBackground,
    required this.trayBackground,
    required this.trayBorder,
    required this.shadow,
    required this.error,
    required this.primaryGradient,
    required this.secondaryGradient,
    required this.welcomeGradient,
    required this.itemBackground,
    required this.itemBorder,
  });

  final Color dialogBackground;
  final Color error;
  final Color itemBackground;
  final Color itemBorder;
  final Color primary;
  final Color primaryButtonBackground;
  final Color primaryText;
  final Color secondaryText;
  final Color reversedText;
  final Color screenBackground;
  final Color shadow;
  final Color trayBackground;
  final Color trayBorder;
  final List<Color> primaryGradient;
  final List<Color> secondaryGradient;
  final List<Color> welcomeGradient;
}