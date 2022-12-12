import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class ThemedRaisedButton extends StatelessWidget {
  const ThemedRaisedButton(
      {Key? key,
      this.child,
      this.disabledColor,
      this.width,
      this.height = 60.0,
      this.borderRadius = 16.0,
      this.padding,
      this.busy = false,
      this.onPressed,
      this.label,
      this.maxLines = 1,
      this.textAlign = TextAlign.center,
      this.horzPadding = 15,
      this.backgroundColor,
      this.cta = false})
      : super(key: key);
  final Widget? child;
  final Color? disabledColor;
  final double height;
  final double? width;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool busy;
  final VoidCallback? onPressed;
  final String? label;
  final int maxLines;
  final TextAlign textAlign;
  final double horzPadding;
  final Color? backgroundColor;
  final bool cta;

  Widget _busySpinner(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    return SizedBox(
      width: 28,
      height: 28,
      child: CircularProgressIndicator(
        strokeWidth: 3.0,
        color: themeColors.primaryText,
      ),
    );
  }

  Decoration _buttonStyles(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    if (cta) {
      return BoxDecoration(
          gradient: LinearGradient(colors: themeColors.ctaGradient),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [BoxShadow(color: themeColors.shadow)]);
    }
    return BoxDecoration(
        color: themeColors.primaryButtonBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [BoxShadow(color: themeColors.shadow)]);
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;

    return SizedBox(
        height: height,
        width: width,
        child: DecoratedBox(
          decoration: _buttonStyles(context),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: padding,
                backgroundColor: Colors.transparent,
                foregroundColor: themeColors.primaryText,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius))),
            onPressed: onPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horzPadding),
              child: busy
                  ? SizedBox(
                      width: 35, height: 35, child: _busySpinner(context))
                  : child != null
                      ? child!
                      : AutoSizeText(
                          label ?? "",
                          maxLines: maxLines,
                          textAlign: textAlign,
                        ),
            ),
          ),
        ));
  }
}
