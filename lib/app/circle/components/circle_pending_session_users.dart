import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/circle_session_page.dart';
import 'package:totem/app/circle/components/circle_session_participant.dart';
import 'package:totem/services/utils/index.dart';
import 'package:totem/theme/index.dart';

class CirclePendingSessionUsers extends ConsumerWidget {
  const CirclePendingSessionUsers({Key? key}) : super(key: key);
  static const double maxDimension = 380;
  static const double minDimension = 200;
  static const double spacing = 8;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeSessionProvider);
    final participants = session.activeParticipants;
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
              dimension = min(
                  dimension, (width - spacing * (maxColumns - 1)) / maxColumns);
            } else {
              dimension = min(dimension, h0.toDouble());
            }
          } else if (participantCount >= minSizeCount) {
            dimension = min(
                dimension, (width - spacing * (maxColumns - 1)) / maxColumns);
          }
          return SingleChildScrollView(
            child: Wrap(
              runSpacing: 8,
              spacing: 8,
              alignment: WrapAlignment.center,
              children: List.generate(participantCount, (index) {
                if (index < participants.length) {
                  return CircleSessionParticipant(
                      dimension: dimension,
                      participantId: participants[index].uid);
                }
                return Container(
                  width: dimension,
                  height: dimension,
                  color: Colors.red,
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
