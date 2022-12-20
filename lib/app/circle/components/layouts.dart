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
    this.maxChildSize = 150,
    this.minChildSize = 100,
    this.direction = Axis.vertical,
  }) : super(key: key);
  final double maxChildSize;
  final double minChildSize;
  final int maxAllowedDimension;
  static const double spacing = 0;
  final int count;
  final Widget Function(int, double) generate;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    if (count != 0) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          bool horizontal = constraints.maxWidth >= constraints.maxHeight;
          double width = horizontal
              ? (maxAllowedDimension * minChildSize)
              : constraints.maxWidth;
          double height = horizontal
              ? constraints.maxHeight
              : (maxAllowedDimension * minChildSize);
          int maxColumns = 1;
          int maxRows = 1;
          int columns = 1;
          int rows = 1;
          double dimension = minChildSize;
          if (horizontal) {
            // calculate the number based on the height
            maxRows = (height /
                    (minChildSize + (!DeviceType.isPhone() ? spacing : 0)))
                .floor();
            maxColumns = maxAllowedDimension;
            int scaledTotal = maxColumns * maxRows;
            if (count <= scaledTotal) {
              dimension = min(
                  height / (count / maxAllowedDimension).ceilToDouble(),
                  maxChildSize);
              columns = (count / (height / dimension)).ceil();
            } else {
              columns = maxAllowedDimension;
            }
            width = (columns * dimension).ceilToDouble();
          } else {
            // calculate the number base on the width
            // calculate the number based on the height
            maxColumns =
                (width / (minChildSize + (!DeviceType.isPhone() ? spacing : 0)))
                    .floor();
            maxRows = maxAllowedDimension;
            int scaledTotal = maxColumns * maxRows;
            if (count <= scaledTotal) {
              dimension = min(
                  width / (count / maxAllowedDimension).ceilToDouble(),
                  maxChildSize);
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
              scrollDirection: direction,
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

class WaitingRoomListLayout extends StatelessWidget {
  const WaitingRoomListLayout({
    Key? key,
    required this.generate,
    required this.count,
    this.minChildSize = 100,
    this.live = false,
  }) : super(key: key);
  final double maxChildSize = 600;
  final double minChildSize;
  final bool live;
  static const double spacing = 0;
  final int count;
  final Widget Function(int, double) generate;

  @override
  Widget build(BuildContext context) {
    if (count != 0) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double x = constraints.maxWidth;
          double y = constraints.maxHeight;
          int n = count;

          // Taken from https://math.stackexchange.com/a/2570649
          double ratio = x / y;
          double ncols = sqrt(n * ratio);
          double nrows = n / ncols;

          // Find best option filling the whole height
          int nrows1 = (nrows).ceil();
          int ncols1 = (n / nrows1).ceil();
          while (nrows1 * ratio < ncols1) {
            nrows1++;
            ncols1 = (n / nrows1).ceil();
          }
          double size1 = y / nrows1;

          // Find best option filling the whole width
          int ncols2 = (ncols).ceil();
          int nrows2 = (n / ncols2).ceil();
          while (ncols2 < nrows2 * ratio) {
            ncols2++;
            nrows2 = (n / ncols2).ceil();
          }
          double size2 = x / ncols2;

          double size =
              max(min(maxChildSize, max(size1, size2)), minChildSize) -
                  2 * spacing;
          return SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            child: SingleChildScrollView(
              child: Wrap(
                runSpacing: spacing,
                spacing: spacing,
                alignment: WrapAlignment.center,
                children: List<Widget>.generate(
                  count,
                  (index) => generate(index, size),
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
          style: !live
              ? textStyles.headline3
              : textStyles.headline3!
                  .merge(TextStyle(color: themeData.themeColors.reversedText)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
