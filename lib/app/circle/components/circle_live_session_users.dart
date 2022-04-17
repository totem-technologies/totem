import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/services/utils/device_type.dart';
import 'package:totem/theme/index.dart';

class CircleLiveSessionUsers extends ConsumerWidget {
  const CircleLiveSessionUsers({Key? key}) : super(key: key);
  static const double maxDimension = 380;
  static const double minDimension = 135;
  static const double spacing = 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeSessionProvider);
    final totemId = activeSession.totemParticipant?.uid;
    final participants = activeSession.speakOrderParticipants
        .where((element) => element.uid != totemId || !element.me)
        .toList();
    if (participants.isNotEmpty) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final minColumns = (width / (maxDimension)).floor();
          final maxColumns = (width / (minDimension)).floor();
          int minRows =
              (height / (maxDimension + (!DeviceType.isPhone() ? spacing : 0)))
                  .floor();
          int maxRows =
              (height / (minDimension + (!DeviceType.isPhone() ? spacing : 0)))
                  .floor();
          double dimension = maxDimension;
          if (minRows == 0 || maxRows == 0) {
            minRows = maxRows = 1;
            dimension = max(minDimension, min(height, maxDimension));
          }
          final maxedSizeCount = max(1, (minRows * minColumns));
          final minSizeCount = max(1, (maxRows * maxColumns));
          int participantCount = participants.length;
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
              dimension = min(dimension, (width - spacing * (cols - 1)) / cols);
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
              children: List.generate(participantCount, (index) {
                if (index < participants.length) {
                  return CircleSessionParticipant(
                    dimension: dimension,
                    sessionUserId: participants[index].sessionUserId!,
                    hasTotem: activeSession.totemUser ==
                        participants[index].sessionUserId,
                    annotate: false,
                  );
                }
                return Padding(
                  child: Container(
                    width: dimension - 4,
                    height: dimension - 4,
                    color: Colors.red,
                  ),
                  padding: const EdgeInsets.all(2),
                );
              }),
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
