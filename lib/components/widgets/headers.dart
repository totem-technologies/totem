import 'package:flutter/material.dart';
import 'package:totem/components/widgets/content_divider.dart';

class TotemHeader extends StatelessWidget {
  const TotemHeader({Key? key, required this.text}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 40, left: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: textStyles.headline1,
          ),
          const ContentDivider(),
        ],
      ),
    );
  }
}
