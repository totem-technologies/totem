import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/communication_provider.dart';
import 'package:totem/theme/index.dart';

class CircleLiveTotemParticipant extends ConsumerStatefulWidget {
  const CircleLiveTotemParticipant({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CircleLiveTotemParticipantState();
}

class _CircleLiveTotemParticipantState
    extends ConsumerState<CircleLiveTotemParticipant> {
  @override
  Widget build(BuildContext context) {
    final activeSession = ref.watch(activeSessionProvider);
    final commProvider = ref.watch(communicationsProvider);
    final totemParticipant = activeSession.totemParticipant;
    if (totemParticipant != null) {
      final t = AppLocalizations.of(context)!;
      final textStyles = Theme.of(context).textStyles;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Container()),
          Opacity(
            opacity: totemParticipant.me ? 1.0 : 0,
            child: !activeSession.totemReceived
                ? Text(t.yourTurn, style: textStyles.displaySmall)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(t.youAreSharing, style: textStyles.displaySmall),
                      const SizedBox(
                        width: 6,
                      ),
                      Icon(
                        Icons.settings_input_antenna,
                        size: 24,
                        color: Theme.of(context).themeColors.primaryText,
                      ),
                    ],
                  ), // FIXME - replace with design item
          ),
          const SizedBox(height: 32),
          participant(context, totemParticipant, commProvider),
          Expanded(child: Container()),
        ],
      );
    }
    return Container();
  }

  Widget participant(BuildContext context, SessionParticipant participant,
      CommunicationProvider commProvider) {
    final themeColors = Theme.of(context).themeColors;
    double size = 142;
    var profileImage = Center(
      child: ClipOval(
        child: SizedBox(
          width: size - 10,
          height: size - 10,
          child: participant.hasImage
              ? CachedNetworkImage(
                  imageUrl: participant.sessionImage!,
                  fit: BoxFit.cover,
                )
              : Container(),
        ),
      ),
    );
    return StreamBuilder<CommunicationAudioVolumeIndication>(
        stream: commProvider.audioIndicatorStream,
        builder: (context, snapshot) {
          double blur = 0;
          double spread = 0;
          var duration = const Duration(milliseconds: 500);
          if (snapshot.hasData) {
            var info = snapshot.data!
                .getSpeaker(participant.sessionUserId!, participant.me);
            if (info != null && info.volume > 0) {
              blur = info.volume.toDouble() / 2;
              spread = info.volume.toDouble() / 5;
            }
          }
          return AnimatedContainer(
              width: size,
              height: size,
              curve: Curves.easeOutSine,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x3EFFE892), Color(0x3EFFCC59)],
                ),
                boxShadow: [
                  BoxShadow(
                      color: themeColors.primary,
                      blurRadius: blur,
                      spreadRadius: spread),
                ],
              ),
              duration: duration,
              child: profileImage);
        });
  }
}
