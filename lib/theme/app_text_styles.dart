import 'package:flutter/material.dart';

class AppTextStyles extends TextTheme {
  const AppTextStyles({
    required TextStyle headline1,
    required TextStyle headline2,
    required TextStyle headline3,
    required TextStyle headline4,
    required TextStyle headline5,
    required TextStyle headline6,
    required TextStyle body,
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
          bodyText1: body,
          headline1: headline1,
          headline2: headline2,
          headline3: headline3,
          headline4: headline4,
          headline5: headline5,
          headline6: headline6,
          button: button,
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
