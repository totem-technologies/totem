import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class ErrorInfoBlock extends StatelessWidget {
  const ErrorInfoBlock({Key? key, required this.errorContent})
      : super(key: key);
  final Widget errorContent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
          color: Theme.of(context).themeColors.error.withAlpha(60)),
      child: errorContent,
    );
  }
}
