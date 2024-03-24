import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class ThemedInputDecoration extends InputDecoration {
  ThemedInputDecoration({
    required AppThemeColors themeColors,
    required AppTextStyles textStyles,
    super.labelText,
    super.hintText,
    TextStyle? hintStyle,
    TextStyle? labelStyle,
    Color? enabledBorderColor,
    Color? errorBorderColor,
    Color? focusedBorderColor,
    super.suffixIcon,
    super.suffix,
    super.contentPadding,
    bool super.isDense = false,
  }) : super(
          hintStyle: hintStyle ?? textStyles.hintInputLabel,
          counterText: '',
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
          focusedErrorBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: enabledBorderColor ?? themeColors.error),
          ),
        );
}
