import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class StdThemePalette {
  static const yellow = Color(0xffffcc59);
  static const baseBlack = Color(0xff16182a);
  static const baseWhite = Color(0xffffffff);
  static const offWhite = Color(0xffefefef);
  static const dirtyWhite = Color.fromRGBO(255,255,255,0.8);
  static const altGradient = [Color(0xfffff9ec), Color(0xffffd472)];
  static const baseGradient = [Color(0xfffffdf9), Color(0xfffeeecc)];
  static const red = Color(0xffdf0000);
}

class StdAppThemeColors extends AppThemeColors {
  StdAppThemeColors() : super(
    primary: StdThemePalette.yellow,
    primaryButtonBackground: StdThemePalette.yellow,
    primaryText: StdThemePalette.baseBlack,
    reversedText: StdThemePalette.baseWhite,
    dialogBackground: StdThemePalette.baseWhite,
    screenBackground: StdThemePalette.offWhite,
    primaryGradient: StdThemePalette.baseGradient,
    secondaryGradient: StdThemePalette.altGradient,
    trayBackground: StdThemePalette.dirtyWhite,
    trayBorder: const Color.fromRGBO(201, 201, 201, 0.72),
    shadow: const Color.fromRGBO(115, 115, 115, 0.16),
    error: StdThemePalette.red,
  );
}