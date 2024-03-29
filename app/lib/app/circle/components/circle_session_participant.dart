import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as prov;
import 'package:rxdart/rxdart.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class CircleSessionParticipant extends ConsumerWidget {
  const CircleSessionParticipant(
      {super.key,
      required this.participant,
      required this.dimension,
      this.hasTotem = false,
      this.annotate = true,
      this.next = false});
  final SessionParticipant participant;
  final double dimension;
  final bool hasTotem;
  final bool annotate;
  final bool next;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commProvider = ref.watch(communicationsProvider);
    return GestureDetector(
      onTap: () {
        CircleSessionParticipantDialog.showParticipantDialog(
          context,
          participant: participant,
        );
      },
      child: prov.ChangeNotifierProvider<SessionParticipant>.value(
        value: participant,
        child: SizedBox(
          width: dimension,
          height: dimension,
          child: prov.Consumer<SessionParticipant>(
            builder: (_, participant, __) {
//              debugPrint("Participant update: ${participant.networkUnstable}");
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  StreamBuilder<CommunicationAudioVolumeIndication>(
                    stream: commProvider.audioIndicatorStream
                        .throttleTime(const Duration(milliseconds: 100)),
                    builder: (context, snapshot) {
                      var speaking = false;
                      if (snapshot.hasData) {
                        final audioIndicator = snapshot.data!;
                        var speaker = audioIndicator.getSpeaker(
                            participant.sessionUserId, participant.me);
                        if (speaker != null) {
                          speaking = speaker.speaking;
                        }
                      }
                      var color = Theme.of(context).themeColors.primary;
                      return AnimatedContainer(
                        decoration: BoxDecoration(
                          color: speaking ? color : color.withOpacity(0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        duration: speaking
                            ? const Duration(milliseconds: 0)
                            : const Duration(milliseconds: 500),
                        curve: Curves.easeInCubic,
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: CircleParticipantVideo(
                      participant: participant,
                      hasTotem: hasTotem,
                      annotate: annotate,
                      channelId: commProvider.channelId ?? "",
                      next: next,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
