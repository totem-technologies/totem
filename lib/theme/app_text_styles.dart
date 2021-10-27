import 'package:flutter/material.dart';

class AppTextStyles extends TextTheme {
  const AppTextStyles({
    required TextStyle headline1,
    required TextStyle headline2,
    required TextStyle headline3,
    required TextStyle headline4,
    required TextStyle body,
    required TextStyle button,
    required this.pinInput,
  }) : super(
    bodyText1: body,
    headline1: headline1,
    headline2: headline2,
    headline3: headline3,
    headline4: headline4,
    button: button,
  );
  // custom styles go here
  final TextStyle pinInput;
}