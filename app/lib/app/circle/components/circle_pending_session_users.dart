import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/circle_session_page.dart';
import 'package:totem/app/circle/components/circle_session_participant.dart';

import 'circle_network_connectivity_layer.dart';
import 'layouts.dart';
import 'package:totem/theme/index.dart';

class CirclePendingSessionUsers extends ConsumerWidget {
  const CirclePendingSessionUsers({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final session = ref.watch(activeSessionProvider);
    final participants = session.activeParticipants;
    return CircleNetworkConnectivityLayer(
      child: Padding(
        padding: EdgeInsets.only(
            left: theme.pageHorizontalPadding,
            right: theme.pageHorizontalPadding),
        child: Center(
          child: WaitingRoomListLayout(
              count: participants.length,
              generate: (i, dimension) => CircleSessionParticipant(
                  dimension: dimension, participant: participants[i])),
        ),
      ),
    );
  }
}
