import 'dart:math';

import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class ListenerUserLayout extends StatelessWidget {
  const ListenerUserLayout({
    super.key,
    required this.speaker,
    required this.userList,
    required this.isPhoneLayout,
    this.minUserImageSize = 135,
    this.constrainSpeaker = true,
  });

  static const double verticalDivider = 34;
  static const double horizontalDivider = 66;
  final Widget speaker;
  final Widget userList;
  final double minUserImageSize;
  final bool isPhoneLayout;
  final bool constrainSpeaker;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (!isPhoneLayout) {
          return Row(
            children: [
              Expanded(
                child: (constrainSpeaker)
                    ? LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
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
                      )
                    : speaker,
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
              child: (constrainSpeaker)
                  ? LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
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
                    )
                  : speaker,
            ),
            _divider(context, false, constraints.maxHeight),
            userList,
          ],
        );
      },
    );
  }

  Widget _divider(BuildContext context, bool horizontal, double height) {
    final theme = Theme.of(context);
    final themeColors = Theme.of(context).themeColors;
    if (horizontal) {
      return Padding(
          padding:
              EdgeInsets.symmetric(horizontal: theme.pageHorizontalPadding),
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
