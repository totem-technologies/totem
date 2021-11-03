import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class ListItemContainer extends StatelessWidget {
  const ListItemContainer({Key? key, this.child}) : super(key: key);
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
      decoration: BoxDecoration(
        color: themeColors.itemBackground,
        boxShadow: [
          BoxShadow(
              color: themeColors.shadow,
              offset: const Offset(0, -8),
              blurRadius: 24),
        ],
        border: Border.all(color: themeColors.itemBorder, width: 1.0),
        borderRadius: const BorderRadius.all(
          Radius.circular(16),
        ),
      ),
      child: child,
    );
  }
}
