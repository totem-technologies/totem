import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/index.dart';

import 'layouts.dart';

class CircleLiveSessionUsers extends ConsumerWidget {
  const CircleLiveSessionUsers(
      {super.key, this.speakerView = false, required this.isPhoneLayout});
  final bool speakerView;
  final bool isPhoneLayout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeSessionProvider);
    final totemId = activeSession.totemParticipant?.uid;
    final totemReceived = activeSession.totemReceived;
    final participants =
        (totemReceived || activeSession.totemParticipant?.me == true)
            ? activeSession.speakOrderParticipants
                .where((element) => element.uid != totemId)
                .toList()
            : activeSession.speakOrderParticipants;
    return CircleNetworkConnectivityLayer(
      child: (participants.isNotEmpty)
          ? (!speakerView
              ? ParticipantListLayout(
                  direction: isPhoneLayout ? Axis.horizontal : Axis.vertical,
                  maxAllowedDimension: 1,
                  maxChildSize: 180,
                  count: participants.length,
                  generate: (i, dimension) => CircleSessionParticipant(
                    dimension: dimension,
                    participant: participants[i],
                    hasTotem: activeSession.totemUser ==
                            participants[i].sessionUserId &&
                        totemReceived,
                    next: i == 0,
                  ),
                )
              : WaitingRoomListLayout(
                  generate: (i, dimension) => CircleSessionParticipant(
                    dimension: dimension,
                    participant: participants[i],
                    hasTotem: activeSession.totemUser ==
                            participants[i].sessionUserId &&
                        totemReceived,
                    next: i == 0,
                  ),
                  count: participants.length,
                ))
          : Container(),
    );
  }
}
