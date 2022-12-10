import 'package:flutter/material.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/theme/app_theme_styles.dart';

class TotemActionButton extends StatefulWidget {
  const TotemActionButton(
      {Key? key,
      this.image,
      required this.label,
      this.busy = false,
      this.onPressed})
      : super(key: key);
  final Widget? image;
  final String label;
  final bool busy;
  final Function()? onPressed;

  @override
  State<StatefulWidget> createState() => TotemActionButtonState();
}

class TotemActionButtonState extends State<TotemActionButton> {
  static const double standardFontSize = 15;

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    final style =
        TextStyle(color: themeColors.primaryText, fontSize: standardFontSize);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 350),
      child: Column(
        children: [
          const SizedBox(
            height: 14,
          ),
          ThemedRaisedButton(
            busy: widget.busy,
            horzPadding: 0,
            width: 250,
            onPressed: () {
              if (widget.onPressed != null) {
                widget.onPressed!();
              }
            },
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (widget.image != null) ...[
                  widget.image!,
                  const SizedBox(
                    width: 8,
                  ),
                ],
                Text(
                  widget.label,
                  style: style,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
