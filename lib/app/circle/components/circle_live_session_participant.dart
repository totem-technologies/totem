import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/components/circle_live_participant.dart';

import '../circle_session_page.dart';

class CircleLiveSessionParticipant extends ConsumerWidget {
  const CircleLiveSessionParticipant({Key? key, required this.participantId})
      : super(key: key);
  final String participantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participant = ref.watch(participantProvider(participantId));
    return Stack(
      children: [
        CircleLiveParticipant(participant: participant),
      ],
    );
  }
}
