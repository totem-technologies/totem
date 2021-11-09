import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class ThemedInputDecoration extends InputDecoration {
  ThemedInputDecoration({
    required AppThemeColors themeColors,
    required AppTextStyles textStyles,
    String? labelText,
    TextStyle? labelStyle,
    Color? enabledBorderColor,
    Color? errorBorderColor,
    Color? focusedBorderColor,
    Widget? suffixIcon,
  }) : super(
    labelText: labelText,
    labelStyle: labelStyle ?? textStyles.inputLabel,
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(
          color: enabledBorderColor ?? themeColors.primaryText),
    ),
    errorBorder: UnderlineInputBorder(
      borderSide: BorderSide(
          color: enabledBorderColor ?? themeColors.error),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(
          color: focusedBorderColor ?? themeColors.primaryText),
    ),
    suffixIcon: suffixIcon
  );
}