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
          final maxSize = !DeviceType.isPhone()
              ? maxDimension
              : min(maxDimension, constraints.maxWidth);
          final minSize = !DeviceType.isPhone()
              ? minDimension
              : ((constraints.maxWidth - spacing) / 2).floorToDouble();
          final width = constraints.maxWidth;
          final height = !DeviceType.isPhone()
              ? constraints.maxHeight - 50
              : constraints.maxHeight;
          final minColumns = (width / (maxSize)).floor();
          final maxColumns = (width / (minSize)).floor();
          int minRows = (height / (maxSize + (kIsWeb ? spacing : 0))).floor();
          int maxRows = (height / (minSize + (kIsWeb ? spacing : 0))).floor();
          double dimension = maxSize;
          if (minRows == 0 || maxRows == 0) {
            minRows = maxRows = 1;
            dimension = max(minSize, min(height, maxSize));
          }
          final maxedSizeCount = max(1, (minRows * minColumns));
          //final maxedVisibleCount = maxRows * maxColumns;
          int participantCount = participants.length + 11;
          if (participantCount > maxedSizeCount &&
              participantCount < maxedSizeCount) {
            dimension =
                min(dimension, (height - spacing * (maxRows - 1)) / maxRows);
          } else {
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
