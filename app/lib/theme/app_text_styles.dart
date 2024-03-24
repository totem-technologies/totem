import 'package:flutter/material.dart';

class AppTextStyles extends TextTheme {
  const AppTextStyles({
    required TextStyle headline1,
    required TextStyle headline2,
    required TextStyle headline3,
    required TextStyle headline4,
    required TextStyle headline5,
    required TextStyle headline6,
    required TextStyle bodyLarge,
    required TextStyle bodyMedium,
    required TextStyle button,
    required this.pinInput,
    required this.inputLabel,
    required this.formErrorLabel,
    required this.textLinkButton,
    required this.dialogContent,
    required this.dialogTitle,
    required this.hintInputLabel,
    required this.nextTag,
  }) : super(
          bodyLarge: bodyLarge,
          bodyMedium: bodyMedium,
          displayLarge: headline1,
          displayMedium: headline2,
          displaySmall: headline3,
          headlineMedium: headline4,
          headlineSmall: headline5,
          titleLarge: headline6,
          labelLarge: button,
        );
  // custom styles go here
  final TextStyle pinInput;
  final TextStyle inputLabel;
  final TextStyle formErrorLabel;
  final TextStyle textLinkButton;
  final TextStyle dialogContent;
  final TextStyle dialogTitle;
  final TextStyle hintInputLabel;
  final TextStyle nextTag;
}
