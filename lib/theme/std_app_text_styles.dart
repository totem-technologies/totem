import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class StdAppTextStyles extends AppTextStyles {
  StdAppTextStyles(AppThemeColors themeColors) : super(
    headline1: TextStyle(fontFamily: 'Raleway', fontSize: 32, fontWeight: FontWeight.bold, color: themeColors.primaryText),
    body: TextStyle(fontFamily: 'Raleway', fontSize: 16, fontWeight: FontWeight.normal, color: themeColors.primaryText),
    button: TextStyle(fontFamily: 'Raleway', fontSize: 14, fontWeight: FontWeight.w600, color: themeColors.primaryText),
    pinInput: TextStyle(fontFamily: 'Raleway', fontSize: 20, fontWeight: FontWeight.w600, color: themeColors.primaryText),
    headline2: TextStyle(fontFamily: 'Raleway', fontSize: 24, fontWeight: FontWeight.w600, color: themeColors.primaryText),
    headline3: TextStyle(fontFamily: 'Raleway', fontSize: 16, fontWeight: FontWeight.w600, color: themeColors.primaryText),
    headline4: TextStyle(fontFamily: 'Raleway', fontSize: 14, fontWeight: FontWeight.w500, color: themeColors.secondaryText),
  );
}
