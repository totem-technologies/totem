import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class BottomTrayContainer extends StatelessWidget {
  const BottomTrayContainer(
      {Key? key,
      required this.child,
      this.padding,
      this.fullScreen = false,
      this.backgroundColor})
      : super(key: key);
  final Widget child;
  final double borderRadius = 30;
  final EdgeInsets? padding;
  final bool fullScreen;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    if (fullScreen) {
      return contents(context, child);
    }
    return Wrap(
      children: [contents(context, child)],
    );
  }

  Widget contents(BuildContext context, Widget child) {
    final themeColors = Theme.of(context).themeColors;
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: themeColors.shadow,
              offset: const Offset(0, -8),
              blurRadius: 24),
        ],
        border: Border.all(
            color: themeColors.trayBorder.withAlpha(120), width: 1.0),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderRadius),
            topRight: Radius.circular(borderRadius)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            padding: padding ??
                const EdgeInsets.only(top: 24, bottom: 18, left: 10, right: 10),
            color: backgroundColor ?? themeColors.trayBackground,
            child: child,
          ),
        ),
      ),
    );
  }
}
