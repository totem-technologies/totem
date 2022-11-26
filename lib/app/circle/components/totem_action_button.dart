import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/theme/app_theme_styles.dart';

class TotemActionButton extends StatefulWidget {
  const TotemActionButton(
      {Key? key,
      this.image,
      required this.label,
      required this.message,
      this.toolTips = const [],
      this.showToolTips = false,
      this.vertical = false,
      this.onPressed})
      : super(key: key);
  final Widget? image;
  final String label;
  final String message;
  final List<String> toolTips;
  final bool showToolTips;
  final bool vertical;
  final Function()? onPressed;

  @override
  State<StatefulWidget> createState() => TotemActionButtonState();
}

class TotemActionButtonState extends State<TotemActionButton> {
  static const double containerSize = 165;
  static const double containerSizeVertical = 110;
  static const double labelFontSize = 20;
  static const double standardFontSize = 15;
  bool _showToolTips = false;

  @override
  void initState() {
    _showToolTips = widget.showToolTips;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    final style =
        TextStyle(color: themeColors.primaryText, fontSize: standardFontSize);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 350),
      child: Column(
        children: [
          if (_showToolTips && widget.toolTips.isNotEmpty)
            Container(
              height: !widget.vertical ? containerSize : containerSizeVertical,
              width: !widget.vertical ? 250 : null,
              decoration: BoxDecoration(
                  color: themeColors.controlButtonBackground,
                  borderRadius: const BorderRadius.all(Radius.circular(16))),
              child: Stack(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: !widget.vertical ? 30 : 5,
                      ),
                      Text(
                        widget.message,
                        style: style.merge(const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: labelFontSize)),
                      ),
                      SizedBox(
                        height: !widget.vertical ? 14 : 5,
                      ),
                      ...widget.toolTips
                          .map((tip) => _lineItem(context, tip))
                          .toList(),
                      if (!widget.vertical) Expanded(child: Container()),
                    ],
                  ),
                ),
                Positioned(
                    right: 5,
                    top: 5,
                    child: IconButton(
                        icon: const Icon(
                          LucideIcons.x,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _showToolTips = false)))
              ]),
            ),
          SizedBox(
            height: !widget.vertical ? 14 : 5,
          ),
          ThemedRaisedButton(
            horzPadding: 0,
            width: !widget.vertical ? 250 : 350,
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

  Widget _lineItem(BuildContext context, String text) {
    final themeColors = Theme.of(context).themeColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(LucideIcons.circle,
                color: themeColors.primaryText, size: 12),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  color: themeColors.primaryText, fontSize: standardFontSize),
            ),
          ),
        ],
      ),
    );
  }
}
