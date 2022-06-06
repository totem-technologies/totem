import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/index.dart';

import 'layouts.dart';

class CircleLiveSessionUsers extends ConsumerWidget {
  const CircleLiveSessionUsers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeSessionProvider);
    final totemId = activeSession.totemParticipant?.uid;
    final participants = activeSession.speakOrderParticipants
        .where((element) => element.uid != totemId)
        .toList();
    return CircleNetworkConnectivityLayer(
        child: ParticipantListLayout(
            maxDimension: 300,
            count: participants.length,
            generate: (i, dimenstion) => CircleSessionParticipant(
                  dimension: dimenstion,
                  participant: participants[i],
                  hasTotem:
                      activeSession.totemUser == participants[i].sessionUserId,
                  annotate: false,
                  next: i == 0,
                )));
  }
}
