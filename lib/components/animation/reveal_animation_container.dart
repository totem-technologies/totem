import 'package:flutter/material.dart';
import 'package:totem/components/animation/rounded_rect_reveal_clipper.dart';

class RevealAnimationContainer extends StatefulWidget {
  const RevealAnimationContainer({
    super.key,
    required this.child,
    this.cornerRadius = 8,
    this.revealAnimationStart = 0.0,
    this.revealInset = 0.0,
    this.fadeAnimationStart = 0.0,
    this.forward = true,
    this.onComplete,
    this.overlay,
    this.duration = 1000,
  });
  final Widget child;
  final double cornerRadius;
  final int duration;
  final double revealAnimationStart;
  final double fadeAnimationStart;
  final bool forward;
  final Function()? onComplete;
  final Widget? overlay;

  // Start Offset of the reveal as a percent of the size of the container
  final double revealInset;
  @override
  State<StatefulWidget> createState() => RevealAnimationContainerState();
}

class RevealAnimationContainerState extends State<RevealAnimationContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rectCornerRadiusAnimation;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: widget.duration))
      ..forward(from: 0);
    _fadeAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(
        parent: _controller,
        curve:
            Interval(widget.fadeAnimationStart, 1.0, curve: Curves.easeOut)));
    _controller.addStatusListener((status) {
      if ((widget.forward && status == AnimationStatus.completed) ||
          (!widget.forward && status == AnimationStatus.dismissed)) {
        debugPrint('animation complete');
        widget.onComplete?.call();
      }
    });
    _rectCornerRadiusAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(widget.revealAnimationStart, 1.0, curve: Curves.easeOut),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double radius = constraints.maxWidth / 2;
      return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ClipPath(
              clipper: RoundedRectRevealClipper(
                minRadius: radius * (1.0 - widget.revealInset),
                maxRadius: radius,
                fraction: _rectCornerRadiusAnimation.value,
                startCornerRadius: radius,
                endCornerRadius: 8,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  widget.child,
                  // Animation Asset layer on top of the child
                  if (widget.overlay != null)
                    Opacity(
                      opacity: _fadeAnimation.value,
                      child: widget.overlay!,
                    ),
                ],
              ),
            );
          });
    });
  }
}
