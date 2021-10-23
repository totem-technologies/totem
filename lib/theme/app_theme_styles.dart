import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

extension AppThemeStyles on ThemeData {
  static AppThemeColors? _themeColors;
  static void setStyles({required AppThemeColors colors}) {
    _themeColors = colors;
  }
  AppThemeColors get themeColors => _themeColors!;
}