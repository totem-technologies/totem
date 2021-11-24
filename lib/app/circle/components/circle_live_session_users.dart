import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/circle_session_page.dart';
import 'package:totem/app/circle/components/circle_session_participant.dart';
import 'package:totem/theme/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:math' as math;

const double _radiansPerDegree = math.pi / 180;
const double _startAngle = -90.0 * _radiansPerDegree;

class CircleLiveSessionUsers extends ConsumerWidget {
  const CircleLiveSessionUsers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participants = ref.watch(activeSessionProvider).activeParticipants;
    if (participants.isNotEmpty) {
      final List<Widget> userItems = <Widget>[];
      for (int i = 0; i < participants.length; i++) {
        userItems.add(CircleSessionParticipant(
            participantId: participants[i].userProfile.uid));
      }

      return CustomMultiChildLayout(
        delegate: _CircularLayoutDelegate(
          itemCount: participants.length,
          radius: 120,
        ),
        children: userItems,
      );
/*      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          return CircleSessionParticipant(
              participantId: participants[index].userProfile.uid);
        },
        itemCount: participants.length,
      ); */
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

class _CircularLayoutDelegate extends MultiChildLayoutDelegate {
  static const String actionButton = 'BUTTON';
  late Offset center;
  final int itemCount;
  final double radius;

  _CircularLayoutDelegate({
    required this.itemCount,
    required this.radius,
  });

  @override
  void performLayout(Size size) {
    center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < itemCount; i++) {
      final String actionButtonId = '$actionButton$i';

      if (hasChild(actionButtonId)) {
        final Size buttonSize =
            layoutChild(actionButtonId, BoxConstraints.loose(size));
        final double itemAngle = _calculateItemAngle(i);

        positionChild(
          actionButtonId,
          Offset(
            (center.dx - buttonSize.width / 2) + (radius) * math.cos(itemAngle),
            (center.dy - buttonSize.height / 2) +
                (radius) * math.sin(itemAngle),
          ),
        );
      }
    }
  }

  @override
  bool shouldRelayout(_CircularLayoutDelegate oldDelegate) =>
      itemCount != oldDelegate.itemCount || radius != oldDelegate.radius;

  double _calculateItemAngle(int index) {
    double _itemSpacing = 360.0 / 5.0;
    return _startAngle + index * _itemSpacing * _radiansPerDegree;
  }
}
