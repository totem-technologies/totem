import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:totem/theme/index.dart';

class PinCodeWidget extends StatelessWidget {
  final Function(String value) onChanged;
  final Function(String value) onComplete;

  const PinCodeWidget(
      {required this.onChanged, required this.onComplete, super.key});

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    final textStyles = Theme.of(context).textStyles;
    return PinCodeTextField(
      enablePinAutofill: false,
      autoFocus: true,
      appContext: context,
      autoDismissKeyboard: true,
      showCursor: true,
      length: 6,
      animationType: AnimationType.none,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.underline,
        selectedColor: themeColors.primaryText,
        inactiveColor: themeColors.primaryText,
        errorBorderColor: themeColors.primaryText,
        activeColor: themeColors.primaryText,
        fieldWidth: 40,
      ),
      cursorColor: themeColors.primaryText,
      keyboardType: TextInputType.number,
      textStyle: textStyles.pinInput,
      onCompleted: onComplete,
      onChanged: onChanged,
    );
  }
}
