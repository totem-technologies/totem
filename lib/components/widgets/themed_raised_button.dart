import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class ThemedRaisedButton extends StatelessWidget {
  const ThemedRaisedButton({
    Key? key,
    this.child,
    this.disabledColor,
    this.width,
    this.height = 60.0,
    this.borderRadius = 16.0,
    this.padding,
    this.busy = false,
    this.onPressed,
    this.label,
    this.elevation = 4,
    this.side,
    this.maxLines = 1,
    this.textAlign = TextAlign.center,
    this.horzPadding = 15,
    this.backgroundColor,
  }) : super(key: key);
  final Widget? child;
  final Color? disabledColor;
  final double height;
  final double? width;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool busy;
  final VoidCallback? onPressed;
  final double elevation;
  final String? label;
  final BorderSide? side;
  final int maxLines;
  final TextAlign textAlign;
  final double horzPadding;
  final Color? backgroundColor;

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

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    final btnStyle = ButtonStyle(
      shape:
          MaterialStateProperty.resolveWith((states) => RoundedRectangleBorder(
                side: side != null ? side! : BorderSide.none,
                borderRadius: BorderRadius.all(
                  Radius.circular(borderRadius),
                ),
              )),
      shadowColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) => themeColors.shadow,
      ),
      elevation: MaterialStateProperty.resolveWith<double>(
          (states) => states.contains(MaterialState.disabled) ? 0 : elevation),
      padding: MaterialStateProperty.resolveWith((states) => padding),
      foregroundColor: MaterialStateProperty.resolveWith<Color>(
        // text color
        (Set<MaterialState> states) => states.contains(MaterialState.disabled)
            ? themeColors.primaryText.withAlpha(102)
            : themeColors.primaryText,
      ),
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        // background color    this is color:
        (Set<MaterialState> states) => states.contains(MaterialState.disabled)
            ? (backgroundColor?.withAlpha(102) ??
                themeColors.primaryButtonBackground.withAlpha(102))
            : (backgroundColor ?? themeColors.primaryButtonBackground),
      ),
    );
    return SizedBox(
        height: height,
        width: width,
        child: ElevatedButton(
          style: btnStyle,
          onPressed: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horzPadding),
            child: busy
                ? SizedBox(width: 35, height: 35, child: _busySpinner(context))
                : child != null
                    ? child!
                    : AutoSizeText(
                        label ?? "",
                        maxLines: maxLines,
                        textAlign: textAlign,
                      ),
          ),
        ));
  }
}
