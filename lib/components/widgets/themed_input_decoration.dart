import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class ThemedInputDecoration extends InputDecoration {
  ThemedInputDecoration({
    required AppThemeColors themeColors,
    required AppTextStyles textStyles,
    String? labelText,
    String? hintText,
    TextStyle? hintStyle,
    TextStyle? labelStyle,
    Color? enabledBorderColor,
    Color? errorBorderColor,
    Color? focusedBorderColor,
    Widget? suffixIcon,
    Widget? suffix,
    EdgeInsetsGeometry? contentPadding,
    bool isDense = false,
  }) : super(
          isDense: isDense,
          contentPadding: contentPadding,
          hintText: hintText,
          hintStyle: hintStyle ?? textStyles.hintInputLabel,
          counterText: '',
          labelText: labelText,
          labelStyle: labelStyle ?? textStyles.inputLabel,
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: enabledBorderColor ?? themeColors.divider),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: enabledBorderColor ?? themeColors.error),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: focusedBorderColor ?? themeColors.divider),
          ),
          suffixIcon: suffixIcon,
          suffix: suffix,
        );
}
