import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:totem/services/utils/device_type.dart';
import 'package:totem/theme/index.dart';

class ParticipantListLayout extends StatelessWidget {
  const ParticipantListLayout(
      {Key? key, required this.generate, required this.count})
      : super(key: key);
  static const double maxDimension = 600;
  static const double minDimension = 135;
  static const double spacing = 0;
  final int count;
  final Widget Function(int, double) generate;

  @override
  Widget build(BuildContext context) {
    if (count != 0) {
      return Center(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            final minColumns = (width / (maxDimension)).floor();
            final maxColumns = (width / (minDimension)).floor();
            int minRows = (height /
                    (maxDimension + (!DeviceType.isPhone() ? spacing : 0)))
                .floor();
            int maxRows = (height /
                    (minDimension + (!DeviceType.isPhone() ? spacing : 0)))
                .floor();
            double dimension = min(min(height, width), maxDimension);
            if (minRows == 0 || maxRows == 0) {
              minRows = maxRows = 1;
              dimension = max(minDimension, min(height, maxDimension));
            }
            final maxedSizeCount = max(1, (minRows * minColumns));
            final minSizeCount = max(1, (maxRows * maxColumns));
            int participantCount = count;
            if (participantCount > maxedSizeCount &&
                participantCount < minSizeCount) {
              int h0 = (sqrt((width * height) / participantCount)).ceil();
              int value = (width / h0).floor() * (height / h0).floor();
              while (participantCount > value) {
                h0--;
                value = (width / h0).floor() * (height / h0).floor();
              }
              if ((width / h0).floor() == 1) {
                // use min of 2
                int cols = min(participantCount, maxColumns);
                dimension =
                    min(dimension, (width - spacing * (cols - 1)) / cols);
              } else {
                dimension = min(dimension, h0.toDouble());
              }
            } else if (participantCount >= minSizeCount) {
              dimension = min(
                  dimension, (width - spacing * (maxColumns - 1)) / maxColumns);
            }
            return SingleChildScrollView(
              child: Wrap(
                runSpacing: spacing,
                spacing: spacing,
                alignment: WrapAlignment.start,
                children: List<Widget>.generate(
                  participantCount,
                  (index) => generate(index, dimension),
                ),
              ),
            );
          },
        ),
      );
    }
    final t = AppLocalizations.of(context)!;
    final themeData = Theme.of(context);
    final textStyles = themeData.textTheme;
    return Center(
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: themeData.pageHorizontalPadding),
        child: Text(
          t.noParticipantsActiveSession,
          style: textStyles.headline3,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
