import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

extension AppThemeStyles on ThemeData {
  static AppThemeColors? _themeColors;
  static AppTextStyles? _textStyles;
  static void setStyles({required AppThemeColors colors, required AppTextStyles textStyles}) {
    _themeColors = colors;
    _textStyles = textStyles;
  }
  AppThemeColors get themeColors => _themeColors!;
  AppTextStyles get textStyles => _textStyles!;
  double get pageHorizontalPadding => 24.0;
}