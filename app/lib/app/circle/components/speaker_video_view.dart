import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as prov;
import 'package:totem/app/index.dart';
import 'package:totem/components/animation/index.dart';
import 'package:totem/models/index.dart';

class SpeakerVideoView extends ConsumerStatefulWidget {
  const SpeakerVideoView(
      {super.key, required this.onReceive, required this.onSettings});
  final void Function() onReceive;
  final void Function() onSettings;

  @override
  SpeakerVideoViewState createState() => SpeakerVideoViewState();
}

class SpeakerVideoViewState extends ConsumerState<SpeakerVideoView> {
  @override
  Widget build(BuildContext context) {
    final activeSession = ref.watch(activeSessionProvider);
    final commProvider = ref.watch(communicationsProvider);
    final totemParticipant = activeSession.totemParticipant;
    final bool totemReceived = activeSession.totemReceived;
    if (totemParticipant != null) {
      if (totemReceived && !totemParticipant.me) {
        return prov.ChangeNotifierProvider<SessionParticipant>.value(
          value: activeSession.totemParticipant!,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final sizeOfVideo =
                  min(constraints.maxWidth, constraints.maxHeight);
              return SizedBox(
                width: sizeOfVideo,
                height: sizeOfVideo,
                child: prov.Consumer<SessionParticipant>(
                  builder: (_, participant, __) {
                    return RevealAnimationContainer(
                      revealAnimationStart: 0,
                      revealInset: 0.9,
                      child: CircleParticipantVideo(
                        participant: participant,
                        channelId: commProvider.channelId ?? "",
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      }
      // if totem recipient is me, show the pending totem view
      if (totemParticipant.me) {
        return PendingTotemUser(
          userVideo: CircleParticipantVideo(
            participant: totemParticipant,
            channelId: commProvider.channelId ?? "",
            annotate: false,
          ),
          onReceive: widget.onReceive,
          onSettings: widget.onSettings,
        );
      }
      return const WaitingForTotemUser();
    }

    return Container();
  }
}
