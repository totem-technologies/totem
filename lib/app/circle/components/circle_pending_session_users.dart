import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/circle_session_page.dart';
import 'package:totem/app/circle/components/circle_session_participant.dart';
import 'package:totem/theme/index.dart';
import 'circle_network_connectivity_layer.dart';
import 'layouts.dart';

class CirclePendingSessionUsers extends ConsumerWidget {
  const CirclePendingSessionUsers({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeSessionProvider);
    final participants = session.activeParticipants;
    if (participants.isNotEmpty) {
      return CircleNetworkConnectivityLayer(
        child: Center(
          child: ParticipantListLayout(
              count: participants.length,
              generate: (i, dimension) => CircleSessionParticipant(
                  dimension: dimension, participant: participants[i])),
        ),
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
