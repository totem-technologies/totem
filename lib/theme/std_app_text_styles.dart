import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StdAppTextStyles extends AppTextStyles {
  StdAppTextStyles(AppThemeColors themeColors) : super(
    headline1: TextStyle(fontFamily: 'Raleway', fontSize: 32, fontWeight: FontWeight.bold, color: themeColors.primaryText),
    body: TextStyle(fontFamily: 'Raleway', fontSize: 16, fontWeight: FontWeight.normal, color: themeColors.primaryText),
  );
}
