import 'package:flutter/material.dart';
import 'package:totem/theme/app_theme_styles.dart';
import 'package:totem/components/widgets/index.dart';

class TotemActionButton extends StatelessWidget {
  const TotemActionButton(
      {Key? key,
      required this.image,
      required this.label,
      required this.message,
      this.toolTips = const [],
      this.showToolTips = false,
      this.vertical = false,
      this.onPressed})
      : super(key: key);
  final Widget image;
  final String label;
  final String message;
  final List<Widget> toolTips;
  final bool showToolTips;
  final bool vertical;
  final Function()? onPressed;

  static const double containerSize = 165;
  static const double containerSizeVertical = 110;
  static const double labelFontSize = 20;
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
          if (showToolTips)
            Container(
              height: !vertical ? containerSize : containerSizeVertical,
              width: !vertical ? 250 : null,
              padding: const EdgeInsets.only(left: 16, right: 16),
              decoration: BoxDecoration(
                  color: themeColors.controlButtonBackground,
                  borderRadius: const BorderRadius.all(Radius.circular(16))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: !vertical ? 30 : 5,
                  ),
                  Text(
                    message,
                    style: style.merge(const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: labelFontSize)),
                  ),
                  SizedBox(
                    height: !vertical ? 14 : 5,
                  ),
                  ...toolTips,
                  if (!vertical) Expanded(child: Container()),
                ],
              ),
            ),
          SizedBox(
            height: !vertical ? 14 : 5,
          ),
          ThemedRaisedButton(
            horzPadding: 0,
            width: !vertical ? 250 : 350,
            onPressed: () {
              if (onPressed != null) {
                onPressed!();
              }
            },
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                image,
                const SizedBox(
                  width: 8,
                ),
                Text(
                  label,
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
