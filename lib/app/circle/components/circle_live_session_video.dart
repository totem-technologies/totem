import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/models/index.dart';

class CircleLiveSessionVideo extends ConsumerWidget {
  const CircleLiveSessionVideo({Key? key, required this.participant})
      : super(key: key);
  final SessionParticipant participant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commProvider = ref.watch(communicationsProvider);
    if (participant.me && !commProvider.videoMuted) {
      return Container(
          color: Colors.black, child: const rtc_local_view.SurfaceView());
    }
    if (!participant.me && !participant.videoMuted) {
      return Container(
        color: Colors.black,
        child: rtc_remote_view.SurfaceView(
          channelId: commProvider.channelId,
          uid: int.parse(participant.sessionUserId!),
        ),
      );
    }
    // This should be the muted state... to do
    return Container(color: Colors.black);
  }
}
