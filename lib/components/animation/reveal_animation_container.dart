import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:totem/components/animation/rounded_rect_reveal_clipper.dart';

class RevealAnimationContainer extends StatefulWidget {
  const RevealAnimationContainer({
    super.key,
    required this.child,
    required this.animationAsset,
    this.cornerRadius = 8,
    this.revealAnimationStart = 0.0,
    this.revealInset = 0.0,
    this.fadeAnimationStart = 0.0,
    this.forward = true,
    this.onComplete,
    this.overlay,
  });
  final Widget child;
  final String animationAsset;
  final double cornerRadius;
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
    _controller = AnimationController(vsync: this);
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
                  // fade layer on between the child and the
                  // lottie animation provides some option for not
                  // seeing any of the child through the lottie animation
                  // until the right moment
                  Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius:
                            BorderRadius.circular(widget.cornerRadius),
                      ),
                    ),
                  ),
                  // Animation Asset layer on top of the child
                  Lottie.asset(
                    widget.animationAsset,
                    fit: BoxFit.cover,
                    repeat: true,
                    controller: _controller,
                    onLoaded: (composition) {
                      // setup the animation duration based on the
                      // lottie animation duration
                      _controller.duration = composition.duration;
                      (widget.forward)
                          ? _controller.forward()
                          : _controller.reverse(from: 1.0);
                    },
                  ),
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
