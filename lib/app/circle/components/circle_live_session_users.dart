import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/index.dart';

import 'layouts.dart';

class CircleLiveSessionUsers extends ConsumerWidget {
  const CircleLiveSessionUsers({Key? key, this.speakerView = false})
      : super(key: key);
  final bool speakerView;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeSessionProvider);
    final totemId = activeSession.totemParticipant?.uid;
    final participants = activeSession.speakOrderParticipants
        .where((element) => element.uid != totemId)
        .toList();
    return CircleNetworkConnectivityLayer(
      child: (participants.isNotEmpty)
          ? (!speakerView
              ? ParticipantListLayout(
                  maxAllowedDimension: 1,
                  maxChildSize: 180,
                  count: participants.length,
                  generate: (i, dimension) => CircleSessionParticipant(
                    dimension: dimension,
                    participant: participants[i],
                    hasTotem: activeSession.totemUser ==
                        participants[i].sessionUserId,
                    annotate: false,
                    next: i == 0,
                  ),
                )
              : WaitingRoomListLayout(
                  generate: (i, dimension) => CircleSessionParticipant(
                    dimension: dimension,
                    participant: participants[i],
                    hasTotem: activeSession.totemUser ==
                        participants[i].sessionUserId,
                    annotate: false,
                    next: i == 0,
                  ),
                  count: participants.length,
                ))
          : Container(),
    );
  }
}
