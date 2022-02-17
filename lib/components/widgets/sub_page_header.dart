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
    return Padding(
      padding: EdgeInsets.only(top: themeData.titleTopPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: themeData.pageHorizontalPadding),
          Expanded(
            child: Text(
              title,
              style: textStyles.headline2,
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
              Icons.close,
              color: themeColors.primaryText,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
