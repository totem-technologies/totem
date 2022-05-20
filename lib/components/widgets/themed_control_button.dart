import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:totem/theme/index.dart';

class ThemedControlButton extends StatelessWidget {
  const ThemedControlButton({
    Key? key,
    required this.label,
    this.svgImage,
    this.child,
    this.onPressed,
    this.enabled = true,
    this.imageColor,
    this.backgroundColor,
    this.labelColor,
    this.size = 40,
    this.iconPadding = const EdgeInsets.all(0),
    this.iconHeight,
  }) : super(key: key);
  final String label;
  final String? svgImage;
  final Widget? child;
  final bool enabled;
  final double size;
  final double? iconHeight;
  final Color? imageColor;
  final Color? backgroundColor;
  final Color? labelColor;
  final VoidCallback? onPressed;
  final EdgeInsets iconPadding;

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    return InkWell(
      onTap: onPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Opacity(
            opacity: onPressed != null ? 1.0 : 0.2,
            child: Container(
              width: size,
              height: size,
              decoration: ShapeDecoration(
                color: backgroundColor ?? themeColors.controlButtonBackground,
                shape: const CircleBorder(),
              ),
              child: Center(
                child: Padding(
                  padding: iconPadding,
                  child: svgImage != null
                      ? SvgPicture.asset(
                          svgImage!,
                          color: imageColor,
                          fit: BoxFit.contain,
                          height: iconHeight,
                        )
                      : child,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            constraints: const BoxConstraints(
              minWidth: 80,
            ),
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 12, color: labelColor ?? themeColors.primaryText),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
