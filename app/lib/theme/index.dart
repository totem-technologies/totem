import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:flutter/material.dart';

import 'app_text_styles.dart';
import 'app_theme_colors.dart';
import 'app_theme_styles.dart';
import 'std_app_text_styles.dart';
import 'std_app_theme_colors.dart';

export 'app_text_styles.dart';
export 'app_theme_colors.dart';
export 'app_theme_styles.dart';

ThemeData totemTheme() {
  AppThemeColors themeColors = StdAppThemeColors();
  AppTextStyles textStyles = StdAppTextStyles(themeColors);
  AppThemeStyles.setStyles(colors: themeColors, textStyles: textStyles);
  return ThemeData(
    appBarTheme: AppBarTheme(
      centerTitle: true,
      iconTheme: IconThemeData(color: themeColors.primaryText),
    ),
    colorScheme: ColorScheme.fromSwatch(
      accentColor: themeColors.primary, // Overscroll color on Android
    ),
    primaryColor: themeColors.primary,
    scaffoldBackgroundColor: themeColors.screenBackground,
    fontFamily: 'Montserrat',
    dialogTheme: DialogTheme(
      backgroundColor: themeColors.dialogBackground,
      contentTextStyle: textStyles.dialogContent,
    ),
    textTheme: textStyles,
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
          foregroundColor: themeColors.linkText,
          textStyle: textStyles.textLinkButton),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: textStyles.inputLabel,
      hintStyle: textStyles.hintInputLabel,
      errorStyle: textStyles.bodyLarge!
          .copyWith(color: themeColors.error, fontSize: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: themeColors.divider,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: themeColors.divider,
          width: 1.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: themeColors.error,
          width: 1.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: themeColors.divider,
          width: 1.0,
        ),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoWillPopScopePageTransionsBuilder(),
      },
    ),
  );
}
