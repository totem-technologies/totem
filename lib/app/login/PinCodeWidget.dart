import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinCodeWidget extends StatelessWidget {
  final Function(String value) onChanged;
  final Function(String value) onComplete;

  PinCodeWidget({required this.onChanged, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      length: 6,
      animationType: AnimationType.none,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.underline,
        selectedColor: Colors.white,
        inactiveColor: Colors.grey,
        errorBorderColor: Colors.white,
        activeColor: Colors.white,
      ),
      cursorColor: Colors.white,
      keyboardType: TextInputType.number,
      onCompleted: onComplete,
      onChanged: onChanged,
    );
  }
}
