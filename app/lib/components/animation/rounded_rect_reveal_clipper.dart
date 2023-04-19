import 'dart:math' show sqrt, max;

import 'package:flutter/material.dart';

@immutable
class RoundedRectRevealClipper extends CustomClipper<Path> {
  final double fraction;
  final Alignment? centerAlignment;
  final Offset? centerOffset;
  final double? minRadius;
  final double? maxRadius;
  final double startCornerRadius;
  final double endCornerRadius;
  const RoundedRectRevealClipper({
    required this.fraction,
    this.centerAlignment,
    this.centerOffset,
    this.minRadius,
    this.maxRadius,
    required this.startCornerRadius,
    required this.endCornerRadius,
  });

  @override
  Path getClip(Size size) {
    final Offset center = centerAlignment?.alongSize(size) ??
        centerOffset ??
        Offset(size.width / 2, size.height / 2);
    final minRadius = this.minRadius ?? 0;
    final maxRadius = this.maxRadius ?? calcMaxRadius(size, center);

    Rect rect = Rect.fromCircle(
        center: center, radius: lerpDouble(minRadius, maxRadius, fraction));
    double cornerRadius =
        lerpDouble(startCornerRadius, endCornerRadius, fraction);
    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          rect,
          Radius.circular(cornerRadius),
        ),
      );
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;

  static double calcMaxRadius(Size size, Offset center) {
    final w = max(center.dx, size.width - center.dx);
    final h = max(center.dy, size.height - center.dy);
    return sqrt(w * w + h * h);
  }

  static double lerpDouble(double a, double b, double t) {
    return a * (1.0 - t) + b * t;
  }
}
