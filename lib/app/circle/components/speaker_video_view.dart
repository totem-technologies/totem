import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as prov;
import 'package:totem/app/circle/components/circle_network_indicator.dart';
import 'package:totem/app/index.dart';
import 'package:totem/components/index.dart';
import 'package:totem/models/index.dart';

class SpeakerVideoView extends ConsumerStatefulWidget {
  const SpeakerVideoView(
      {Key? key,
      required this.onReceive,
      required this.onPass,
      required this.onSettings})
      : super(key: key);
  final void Function() onPass;
  final void Function() onReceive;
  final void Function() onSettings;

  @override
  SpeakerVideoViewState createState() => SpeakerVideoViewState();
}

class SpeakerVideoViewState extends ConsumerState<SpeakerVideoView> {
  @override
  Widget build(BuildContext context) {
    final activeSession = ref.watch(activeSessionProvider);
    ref.watch(communicationsProvider);
    final totemParticipant = activeSession.totemParticipant;
    final bool totemReceived = activeSession.totemReceived;
    if (totemParticipant != null) {
      if (totemReceived) {
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
                    return ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: Stack(
                        children: [
                          CircleLiveSessionVideo(participant: participant),
                          if (participant.videoMuted)
                            const Positioned.fill(
                              child: CameraMuted(),
                            ),
                          if (!participant.me && participant.networkUnstable)
                            const Positioned(
                              top: 10,
                              left: 10,
                              child: CircleNetworkUnstable(),
                            ),
                          if (participant.muted)
                            const PositionedDirectional(
                              top: 5,
                              end: 5,
                              child: MuteIndicator(),
                            ),
                        ],
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
          userVideo: Stack(children: [
            CircleLiveSessionVideo(participant: totemParticipant),
            if (totemParticipant.videoMuted)
              const Positioned.fill(
                child: CameraMuted(),
              ),
            if (totemParticipant.muted)
              const PositionedDirectional(
                top: 5,
                end: 5,
                child: MuteIndicator(),
              ),
          ]),
          onPass: widget.onPass,
          onReceive: widget.onReceive,
          onSettings: widget.onSettings,
        );
      }
      return const WaitingForTotemUser();
    }

    return Container();
  }
}
