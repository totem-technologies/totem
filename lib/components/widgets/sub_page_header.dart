import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class SubPageHeader extends StatelessWidget {
  const SubPageHeader({Key? key, required this.title, this.onClose})
      : super(key: key);
  final String title;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final textStyles = themeData.textTheme;
    final themeColors = themeData.themeColors;
    return Row(
      children: [
        SizedBox(width: themeData.pageHorizontalPadding),
        Expanded(
          child: Text(title, style: textStyles.headline2),
        ),
        IconButton(
          onPressed: () {
            if (onClose == null) {
              Navigator.of(context).pop();
            }
            onClose!();
          },
          icon: Icon(
            Icons.close,
            color: themeColors.primaryText,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
