import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/theme/index.dart';

class CircleLiveSessionParticipant extends ConsumerWidget {
  const CircleLiveSessionParticipant(
      {Key? key, required this.participantId, this.hasTotem = false})
      : super(key: key);
  final String participantId;
  final bool hasTotem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participant = ref.watch(participantProvider(participantId));
    return Stack(
      children: [
        CircleLiveParticipant(
          participant: participant,
          hasTotem: hasTotem,
        ),
        if (participant.me && !hasTotem) _renderMe(context, hasTotem),
      ],
    );
  }

  Widget _renderMe(BuildContext context, bool hasTotem) {
    final textStyles = Theme.of(context).textTheme;
    final themeColors = Theme.of(context).themeColors;
    final t = AppLocalizations.of(context)!;
    return PositionedDirectional(
      top: 9,
      start: 1,
      end: 0,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: themeColors.profileBackground,
              borderRadius:
                  const BorderRadius.only(bottomRight: Radius.circular(16)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Text(
                    t.me,
                    style: textStyles.headline5!.merge(
                      TextStyle(
                        color: themeColors.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}
