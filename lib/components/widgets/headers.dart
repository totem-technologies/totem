import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:totem/components/widgets/content_divider.dart';

class TotemHeader extends StatelessWidget {
  const TotemHeader({Key? key, required this.text}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: 40.h, left: 24.w),
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
