import 'package:flutter/material.dart';
import 'package:totem/components/widgets/content_divider.dart';
import 'package:totem/theme/index.dart';

class TotemHeader extends StatelessWidget {
  const TotemHeader({Key? key, required this.text, this.padding, this.trailing})
      : super(key: key);
  final String text;
  final EdgeInsets? padding;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    return Padding(
      padding: padding ??
          EdgeInsets.symmetric(
              horizontal: Theme.of(context).pageHorizontalPadding),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: textStyles.displayLarge,
                ),
                const ContentDivider(),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
