import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class SubPageHeader extends StatelessWidget {
  const SubPageHeader({Key? key, required this.title}) : super(key: key);
  final String title;

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
          onPressed: (){
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.close, color: themeColors.primaryText,),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

}