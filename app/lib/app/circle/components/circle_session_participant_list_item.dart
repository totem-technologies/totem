import 'package:flutter/material.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/components/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/providers.dart';
import 'package:totem/theme/index.dart';

class CircleSessionParticipantListItem extends ConsumerWidget {
  const CircleSessionParticipantListItem(
      {super.key,
      required this.participant,
      this.reorder = false,
      this.horizontalPadding,
      this.onRemove});
  final SessionParticipant participant;
  final bool reorder;
  final double? horizontalPadding;
  final Function(SessionParticipant)? onRemove;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal:
            horizontalPadding ?? Theme.of(context).pageHorizontalPadding,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: FutureBuilder<UserProfile?>(
              future: ref
                  .read(repositoryProvider)
                  .userProfileWithId(uid: participant.uid),
              builder:
                  (BuildContext context, AsyncSnapshot<UserProfile?> snapshot) {
                if (snapshot.connectionState != ConnectionState.waiting) {
                  return Stack(
                    children: [
                      ParticipantRoundedRectImage(
                        participant: participant,
                        userProfile: snapshot.data,
                      ),
                      if (participant.me) _renderLabel(context, true),
                      if (!participant.me && participant.role == Role.keeper)
                        _renderLabel(context, false),
                    ],
                  );
                }
                return const Center(
                    child: BusyIndicator(
                  size: 40,
                ));
              },
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Text(participant.name),
          ),
          if (onRemove != null && !participant.me)
            IconButton(
                onPressed: () {
                  onRemove!(participant);
                },
                icon: Icon(LucideIcons.x,
                    size: 24,
                    color: Theme.of(context).themeColors.secondaryText)),
          if (reorder)
            ReorderableListener(
              child: Container(
                padding: const EdgeInsets.only(right: 18.0, left: 18.0),
                child: Center(
                  child: Icon(
                    LucideIcons.gripHorizontal,
                    size: 24,
                    color: Theme.of(context).themeColors.secondaryText,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _renderLabel(BuildContext context, bool me) {
    final themeColors = Theme.of(context).themeColors;
    return PositionedDirectional(
      top: 0,
      start: 0,
      end: 0,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: me ? themeColors.primary : themeColors.primaryText,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
            ),
            child: SizedBox(
              width: 20,
              height: 20,
              child: !me
                  ? Center(
                      child: Icon(
                        LucideIcons.star,
                        color: themeColors.primary,
                        size: 12,
                      ),
                    )
                  : null,
            ),
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}
