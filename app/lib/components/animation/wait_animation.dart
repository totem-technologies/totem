import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'draw_arc.dart';

const double _kGapAngle = math.pi / 12;
const double _kMinAngle = math.pi / 36;

class WaitAnimation extends StatefulWidget {
  final double size;
  final Color color;
  final Color imageColor;
  const WaitAnimation({
    super.key,
    required this.color,
    required this.imageColor,
    required this.size,
  });

  @override
  State<WaitAnimation> createState() => WaitAnimationState();
}

class WaitAnimationState extends State<WaitAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final CurvedAnimation _firstRotationInterval;
  late final CurvedAnimation _firstArchInterval;
  late final CurvedAnimation _secondRotationInterval;
  late final CurvedAnimation _secondArchInterval;

  final List<Widget> animationWidgets = <Widget>[];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward(from: 0);

    _firstRotationInterval = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.0,
        0.5,
        curve: Curves.easeInOut,
      ),
    );

    _firstArchInterval = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.0,
        0.4,
        curve: Curves.easeInOut,
      ),
    );

    _secondRotationInterval = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.5,
        1.0,
        curve: Curves.easeInOut,
      ),
    );

    _secondArchInterval = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.5,
        0.9,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.forward(from: 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color color = widget.color;
    final double size = widget.size;
    final double ringWidth = size * 0.08;

    return Container(
      padding: EdgeInsets.all(size * 0.04),
      // color: Colors.green,
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (_, __) {
          return Stack(
            alignment: Alignment.center,
            children: [
              _animationController.value <= 0.5
                  ? Transform.rotate(
                      angle: Tween<double>(
                        begin: 0,
                        end: 4 * math.pi / 3,
                      ).animate(_firstRotationInterval).value,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Arc.draw(
                            color: color,
                            size: size,
                            strokeWidth: ringWidth,
                            startAngle: 7 * math.pi / 6,
                            endAngle: Tween<double>(
                              begin: 2 * math.pi / 3 - _kGapAngle,
                              end: _kMinAngle,
                            ).animate(_firstArchInterval).value,
                          ),
                          Arc.draw(
                            color: color,
                            size: size,
                            strokeWidth: ringWidth,
                            startAngle: math.pi / 2,
                            endAngle: Tween<double>(
                              begin: 2 * math.pi / 3 - _kGapAngle,
                              end: _kMinAngle,
                            ).animate(_firstArchInterval).value,
                          ),
                          Arc.draw(
                            color: color,
                            size: size,
                            strokeWidth: ringWidth,
                            startAngle: -math.pi / 6,
                            endAngle: Tween<double>(
                              begin: 2 * math.pi / 3 - _kGapAngle,
                              end: _kMinAngle,
                            ).animate(_firstArchInterval).value,
                          ),
                        ],
                      ),
                    )
                  : Transform.rotate(
                      angle: Tween<double>(
                        begin: 4 * math.pi / 3,
                        end: (4 * math.pi / 3) + (2 * math.pi / 3),
                      ).animate(_secondRotationInterval).value,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Arc.draw(
                            color: color,
                            size: size,
                            strokeWidth: ringWidth,
                            startAngle: 7 * math.pi / 6,
                            endAngle: Tween<double>(
                              begin: _kMinAngle,
                              end: 2 * math.pi / 3 - _kGapAngle,
                            ).animate(_secondArchInterval).value,
                          ),
                          Arc.draw(
                            color: color,
                            size: size,
                            strokeWidth: ringWidth,
                            startAngle: math.pi / 2,
                            endAngle: Tween<double>(
                              begin: _kMinAngle,
                              end: 2 * math.pi / 3 - _kGapAngle,
                            ).animate(_secondArchInterval).value,
                          ),
                          Arc.draw(
                            color: color,
                            size: size,
                            strokeWidth: ringWidth,
                            startAngle: -math.pi / 6,
                            endAngle: Tween<double>(
                              begin: _kMinAngle,
                              end: 2 * math.pi / 3 - _kGapAngle,
                            ).animate(_secondArchInterval).value,
                          ),
                        ],
                      ),
                    ),
              drawImageContainer(
                  widget.size - (widget.size * 0.16) - 5,
                  SvgPicture.asset(
                    'assets/totem_icon.svg',
                    colorFilter:
                        ColorFilter.mode(widget.imageColor, BlendMode.srcIn),
                  ))
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget drawImageContainer(double size, Widget child) {
    return SizedBox(
      width: size * 0.8,
      height: size * 0.8,
      child: child,
    );
  }
}
