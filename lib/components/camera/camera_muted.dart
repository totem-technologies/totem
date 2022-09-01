import 'dart:math';

import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class CameraMuted extends StatelessWidget {
  const CameraMuted({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final double sizeOfIcon = max((constraints.maxWidth * 0.3), 32);
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: themeColors.cameraBorder, width: 1),
          color: Colors.black54,
        ),
        child: Align(
          alignment: Alignment.center,
          child: Icon(Icons.videocam_off,
              size: sizeOfIcon, color: themeColors.reversedText),
        ),
      );
    });
  }
}
