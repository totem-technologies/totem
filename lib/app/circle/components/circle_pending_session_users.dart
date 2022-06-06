import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/circle_session_page.dart';
import 'package:totem/app/circle/components/circle_session_participant.dart';
import 'circle_network_connectivity_layer.dart';
import 'layouts.dart';

class CirclePendingSessionUsers extends ConsumerWidget {
  const CirclePendingSessionUsers({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeSessionProvider);
    final participants = session.activeParticipants;
    return CircleNetworkConnectivityLayer(
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: ParticipantListLayout(
            maxDimension: 300,
            count: participants.length,
            generate: (i, dimension) => CircleSessionParticipant(
                dimension: dimension, participant: participants[i])),
      ),
    );
  }
}
