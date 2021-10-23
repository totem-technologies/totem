import 'package:flutter/material.dart';

class AppTextStyles extends TextTheme {
  AppTextStyles({
    required TextStyle headline1,
    required TextStyle body,
  }) : super(
    bodyText1: body,
    headline1: headline1,
  );
  // custom styles go here
}