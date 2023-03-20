import 'package:flutter/material.dart';
import 'dart:math' as math;

const double _radiansPerDegree = math.pi / 180;
const double _startAngle = -90.0 * _radiansPerDegree;

class CircularLayoutDelegate extends MultiChildLayoutDelegate {
  CircularLayoutDelegate({
    required this.itemCount,
    required this.radius,
    this.layoutKey = 'item',
  });
  late Offset center;
  final int itemCount;
  final double radius;
  final String layoutKey;

  @override
  void performLayout(Size size) {
    center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < itemCount; i++) {
      final String actionButtonId = '$layoutKey$i';

      if (hasChild(actionButtonId)) {
        final Size itemSize =
            layoutChild(actionButtonId, BoxConstraints.loose(size));
        final double itemAngle = _calculateItemAngle(i);

        positionChild(
          actionButtonId,
          Offset(
            (center.dx - itemSize.width / 2) + (radius) * math.cos(itemAngle),
            (center.dy - itemSize.height / 2) + (radius) * math.sin(itemAngle),
          ),
        );
      }
    }
  }

  @override
  bool shouldRelayout(CircularLayoutDelegate oldDelegate) =>
      itemCount != oldDelegate.itemCount || radius != oldDelegate.radius;

  double _calculateItemAngle(int index) {
    double itemSpacing = 360.0 / 5.0;
    return _startAngle + index * itemSpacing * _radiansPerDegree;
  }
}
