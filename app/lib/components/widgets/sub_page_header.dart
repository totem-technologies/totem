import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/theme/index.dart';

class SubPageHeader extends StatelessWidget {
  const SubPageHeader(
      {Key? key, required this.title, this.onClose, this.leading})
      : super(key: key);
  final String title;
  final VoidCallback? onClose;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final textStyles = themeData.textTheme;
    final themeColors = themeData.themeColors;
    return Padding(
      padding: EdgeInsets.only(top: themeData.titleTopPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: themeData.pageHorizontalPadding),
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Text(
              title,
              style: textStyles.displayMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () {
              if (onClose == null) {
                Navigator.of(context).pop();
              } else {
                onClose!();
              }
            },
            icon: Icon(
              LucideIcons.x,
              color: themeColors.primaryText,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
