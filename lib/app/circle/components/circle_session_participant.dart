import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as prov;
import 'package:rxdart/rxdart.dart';
import 'package:totem/app/circle/components/circle_network_indicator.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/components/camera/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class CircleSessionParticipant extends ConsumerWidget {
  const CircleSessionParticipant(
      {Key? key,
      required this.participant,
      required this.dimension,
      this.hasTotem = false,
      this.annotate = true,
      this.next = false})
      : super(key: key);
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
        CircleSessionParticipantDialog.showDialog(
          context,
          participant: participant,
        );
      },
      child: prov.ChangeNotifierProvider<SessionParticipant>.value(
        value: participant,
        child: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: SizedBox(
            width: dimension,
            height: dimension,
            child: prov.Consumer<SessionParticipant>(
              builder: (_, participant, __) {
                debugPrint(
                    "Participant update: ${participant.networkUnstable}");
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (next)
                      Positioned(
                        top: -20,
                        left: 5,
                        child: _nextTag(context),
                      ),
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
                      ),
                    ),
                    if (!participant.me && participant.networkUnstable)
                      const Positioned(
                        top: 10,
                        left: 10,
                        child: CircleNetworkUnstable(),
                      ),
                    PositionedDirectional(
                      top: 5,
                      end: 5,
                      child: _muteIndicator(context, participant),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _muteIndicator(BuildContext context, SessionParticipant participant) {
    final bool muted = participant.muted;
    if (muted) {
      return const MuteIndicator();
    }
    return Container();
  }

  Widget _nextTag(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final textStyles = Theme.of(context).textStyles;
    return Container(
      padding: const EdgeInsets.only(left: 16, top: 4, right: 24, bottom: 8),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8), topRight: Radius.circular(20)),
        color: Theme.of(context).themeColors.controlButtonBackground,
      ),
      child: Text(
        t.next,
        style: textStyles.nextTag,
      ),
    );
  }
}
