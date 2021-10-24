import 'package:flutter/material.dart';

class AppTextStyles extends TextTheme {
  const AppTextStyles({
    required TextStyle headline1,
    required TextStyle body,
    required TextStyle button,
    required this.pinInput,
  }) : super(
    bodyText1: body,
    headline1: headline1,
    button: button,
  );
  // custom styles go here
  final TextStyle pinInput;
}