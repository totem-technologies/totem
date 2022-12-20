import 'package:flutter/material.dart';
import 'package:totem/services/utils/device_type.dart';
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
  double get pageHorizontalPadding => 12.0;
  double get backgroundGradientRotation => -26.0;
  double get titleTopPadding => 40.0;
  double get standardButtonWidth => 294.0;
  double get maxRenderWidth => 500;
  double get portraitBreak => 1000;
  double get mobileBreak => 702;
  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreak || DeviceType.isPhone();
}
