import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:totem/services/utils/device_type.dart';
import 'package:totem/theme/index.dart';

class ParticipantListLayout extends StatelessWidget {
  const ParticipantListLayout({
    Key? key,
    required this.generate,
    required this.count,
    this.maxAllowedDimension = 2,
    this.maxDimension = 150,
  }) : super(key: key);
  final double maxDimension;
  final int maxAllowedDimension;
  static const double minDimension = 100;
  static const double spacing = 0;
  final int count;
  final Widget Function(int, double) generate;

  @override
  Widget build(BuildContext context) {
    if (count != 0) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          bool horizontal = constraints.maxWidth >= constraints.maxHeight;
          double width = horizontal
              ? (maxAllowedDimension * minDimension)
              : constraints.maxWidth;
          double height = horizontal
              ? constraints.maxHeight
              : (maxAllowedDimension * minDimension);
          int maxColumns = 1;
          int maxRows = 1;
          int columns = 1;
          int rows = 1;
          double dimension = minDimension;
          if (horizontal) {
            // calculate the number based on the height
            maxRows = (height /
                    (minDimension + (!DeviceType.isPhone() ? spacing : 0)))
                .floor();
            maxColumns = maxAllowedDimension;
            int scaledTotal = maxColumns * maxRows;
            if (count <= scaledTotal) {
              dimension = min(
                  height / (count / maxAllowedDimension).ceilToDouble(),
                  maxDimension);
              columns = (count / (height / dimension)).ceil();
            } else {
              columns = maxAllowedDimension;
            }
            width = (columns * dimension).ceilToDouble();
          } else {
            // calculate the number base on the width
            // calculate the number based on the height
            maxColumns =
                (width / (minDimension + (!DeviceType.isPhone() ? spacing : 0)))
                    .floor();
            maxRows = maxAllowedDimension;
            int scaledTotal = maxColumns * maxRows;
            if (count <= scaledTotal) {
              dimension = min(
                  width / (count / maxAllowedDimension).ceilToDouble(),
                  maxDimension);
              rows = (count / (width / dimension)).ceil();
            } else {
              rows = maxAllowedDimension;
            }
            height = (rows * dimension).ceilToDouble();
          }
          return SizedBox(
            height: height,
            width: width,
            child: SingleChildScrollView(
              child: Wrap(
                runSpacing: spacing,
                spacing: spacing,
                alignment: WrapAlignment.start,
                children: List<Widget>.generate(
                  count,
                  (index) => generate(index, dimension),
                ),
              ),
            ),
          );
        },
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
