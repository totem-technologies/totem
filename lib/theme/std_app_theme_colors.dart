import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class StdThemePalette {
  static const yellow = Color(0xffffcc59);
  static const lightYellow = Color(0xfffde4a4);
  static const lightYellow2 = Color(0xfffdedc9);
  static const baseBlack = Color(0xff16182a);
  static const baseWhite = Color(0xffffffff);
  static const offWhite = Color(0xffefefef);
  static const offWhite2 = Color(0xfffffdf9);
  static const offWhite3 = Color(0xfffef7e8);
  static const dirtyWhite = Color.fromRGBO(255, 255, 255, 0.8);
  static const mainGradient = [newcreme, Color(0xfffeeecc)];
  static const homeGradient = [offWhite2, offWhite3];
  static const red = Color(0xffdf0000);
  static const red2 = Color(0xffCB0E14);
  static const grey = Color(0xff696b76);
  static const mediumGrey = Color(0xffa5a6ac);
  static const lightGrey = Color(0xffc9c9cd);
  static const lighterGrey = Color(0xffd8d8d8);
  static const transparentGrey = Color(0x99444654);
  static const transparentYellow = Color(0xbbffcc59);
  static const newyellow = Color(0xffF4DC92);
  static const newcreme = Color(0xffF3F1E9);
  static const newmauve = Color(0xff987AA5);
  static const newslate = Color(0xff262F37);
  static const deepgrey = Color(0xff514F4D);
  static const blue = Color(0xff9BC0DD);
  static const bluetint = Color(0xff55778F);
  static const pink = Color(0xffD999AA);
  static const pinktint = Color(0xff8B5363);
  static const profileGradient = [
    Color.fromRGBO(49, 53, 84, 0),
    Color.fromRGBO(28, 30, 51, 0.78),
    Color(0xff16182a)
  ];
  static final blackGradient = [
    baseBlack,
    baseBlack.withAlpha(50),
    Colors.transparent,
  ];
  static final List<Color> circleColors = [
    mediumGrey,
    newyellow,
    grey,
    red2,
    lightGrey,
    newcreme,
    newmauve,
    newslate,
    deepgrey,
    blue,
    bluetint,
    pink,
    pinktint,
    Colors.deepPurple,
  ];
}

class StdAppThemeColors extends AppThemeColors {
  StdAppThemeColors()
      : super(
          alternateButtonBackground: StdThemePalette.baseWhite,
          busyIndicator: StdThemePalette.newslate,
          primary: StdThemePalette.newyellow,
          primaryButtonBackground: StdThemePalette.newyellow,
          primaryText: StdThemePalette.newslate,
          profileBackground: StdThemePalette.baseWhite,
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
          linkText: StdThemePalette.newmauve,
          divider: StdThemePalette.lightGrey,
          profileGradient: StdThemePalette.profileGradient,
          controlButtonBackground: StdThemePalette.lightGrey,
          blurBackground: StdThemePalette.baseBlack.withAlpha(40),
          participantBorder: StdThemePalette.lighterGrey,
          sliderBackground: StdThemePalette.offWhite3,
          altBackground: StdThemePalette.newcreme,
          containerBackground: StdThemePalette.offWhite2,
          titleBarGradient: StdThemePalette.blackGradient,
          cameraBorder: StdThemePalette.grey,
          contentDivider: StdThemePalette.grey,
          alertBackground: StdThemePalette.red2,
          videoOverlayBackground: StdThemePalette.transparentGrey,
          reversedVideoOverlayBackground: StdThemePalette.transparentYellow,
          secondaryButtonBackground: StdThemePalette.lightYellow,
          iconNext: StdThemePalette.mediumGrey,
          circleColors: StdThemePalette.circleColors,
        );
}
