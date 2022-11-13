import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class ThemedControlButton extends StatelessWidget {
  const ThemedControlButton({
    Key? key,
    required this.label,
    this.icon,
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
  final IconData? icon;
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
    final background = backgroundColor ?? themeColors.controlButtonBackground;
    final foreground = labelColor ?? themeColors.primaryText;
    final btnStyle = ButtonStyle(
      shape: MaterialStateProperty.resolveWith((states) => CircleBorder(
            side: BorderSide(color: background, width: 1),
          )),
      shadowColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) => themeColors.shadow,
      ),
      elevation: MaterialStateProperty.resolveWith<double>(
          (states) => states.contains(MaterialState.disabled) ? 0 : 2),
      //padding: MaterialStateProperty.resolveWith((states) => padding),
      foregroundColor: MaterialStateProperty.resolveWith<Color>(
        // text color
        (Set<MaterialState> states) => states.contains(MaterialState.disabled)
            ? foreground.withAlpha(102)
            : foreground,
      ),
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
          // background color    this is color:
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return background.withAlpha(102);
        }
        if (states.contains(MaterialState.hovered) &&
            !states.contains(MaterialState.pressed)) {
          return background.withAlpha(150);
        }
        return background;
      }),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          style: btnStyle,
          onPressed: onPressed,
          child: SizedBox(
            height: size,
            width: size,
            child: Center(
              child: Padding(
                padding: iconPadding,
                child: icon != null
                    ? Icon(icon, size: iconHeight, color: imageColor)
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
    );
  }
}
