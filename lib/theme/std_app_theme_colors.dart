import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class StdThemePalette {
  static const yellow = Color(0xffffcc59);
  static const baseBlack = Color(0xff16182a);
  static const baseWhite = Color(0xffffffff);
  static const offWhite = Color(0xffefefef);
  static const dirtyWhite = Color.fromRGBO(255,255,255,0.8);
  static const welcomeGradient = [Color(0xfffff9ec), Color(0xffffd472)];
  static const mainGradient = [Color(0xfffffdf9), Color(0xfffeeecc)];
  static const homeGradient = [Color(0xfffffdf9), Color(0xfffef7e8)];
  static const red = Color(0xffdf0000);
  static const grey = Color(0xff696b76);
}

class StdAppThemeColors extends AppThemeColors {
  StdAppThemeColors() : super(
    primary: StdThemePalette.yellow,
    primaryButtonBackground: StdThemePalette.yellow,
    primaryText: StdThemePalette.baseBlack,
    secondaryText: StdThemePalette.grey,
    reversedText: StdThemePalette.baseWhite,
    dialogBackground: StdThemePalette.baseWhite,
    screenBackground: StdThemePalette.offWhite,
    primaryGradient: StdThemePalette.mainGradient,
    secondaryGradient: StdThemePalette.homeGradient,
    trayBackground: StdThemePalette.dirtyWhite,
    trayBorder: const Color.fromRGBO(201, 201, 201, 0.72),
    itemBackground: StdThemePalette.dirtyWhite,
    itemBorder: StdThemePalette.baseWhite,
    shadow: const Color.fromRGBO(115, 115, 115, 0.16),
    error: StdThemePalette.red,
    welcomeGradient: StdThemePalette.welcomeGradient,
  );
}