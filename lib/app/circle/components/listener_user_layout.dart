import 'dart:math';

import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class ListenerUserLayout extends StatelessWidget {
  const ListenerUserLayout(
      {Key? key,
      required this.speaker,
      required this.userList,
      this.minUserImageSize = 135})
      : super(key: key);

  static const double verticalDivider = 34;
  static const double horizontalDivider = 66;
  final Widget speaker;
  final Widget userList;
  final double minUserImageSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final horizontal = constraints.maxWidth >= constraints.maxHeight;
        if (horizontal) {
          return Row(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final sizeOfVideo =
                        min(constraints.maxHeight, constraints.maxWidth);
                    return Center(
                      child: SizedBox(
                        width: sizeOfVideo,
                        height: sizeOfVideo,
                        child: speaker,
                      ),
                    );
                  },
                ),
              ),
              _divider(context, true, constraints.maxHeight),
              userList,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final sizeOfVideo =
                      min(constraints.maxHeight, constraints.maxWidth);
                  return Center(
                    child: SizedBox(
                      width: sizeOfVideo,
                      height: sizeOfVideo,
                      child: speaker,
                    ),
                  );
                },
              ),
            ),
            _divider(context, false, constraints.maxHeight),
            userList,
          ],
        );
      },
    );
  }

  Widget _divider(BuildContext context, bool horizontal, double height) {
    final themeColors = Theme.of(context).themeColors;
    if (horizontal) {
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            height: height,
            width: 2,
            color: themeColors.contentDivider,
          ));
    }
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Container(
          height: 2,
          color: themeColors.contentDivider,
        ));
  }
}
