import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

extension AppThemeStyles on ThemeData {
  static AppThemeColors? _themeColors;
  static AppTextStyles? _textStyles;
  static void setStyles(
      {required AppThemeColors colors, required AppTextStyles textStyles}) {
    _themeColors = colors;
    _textStyles = textStyles;
  }

  AppThemeColors get themeColors => _themeColors!;
  AppTextStyles get textStyles => _textStyles!;
  double get pageHorizontalPadding => 24.0;
  double get backgroundGradientRotation => -26.0;
  double get titleTopPadding => 40.0;
  double get standardButtonWidth => 294.0;
  double get maxRenderWidth => 400;
  double get portraitBreak => 1000;
}
