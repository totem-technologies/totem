import 'dart:math';

import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:totem/app/circle/components/circle_network_indicator.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/components/camera/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class CircleParticipantVideo extends StatelessWidget {
  const CircleParticipantVideo({
    Key? key,
    required this.participant,
    this.hasTotem = false,
    this.annotate = true,
    this.next = false,
    required this.channelId,
  }) : super(key: key);
  final SessionParticipant participant;
  final bool hasTotem;
  final bool annotate;
  final String channelId;
  final bool next;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double iconSize =
            min(max(14, (constraints.maxWidth / 6).roundToDouble()), 32.0);
        final double videoIconSize =
            min(max(14, (constraints.maxHeight / 3).roundToDouble()), 160.0);
        final double fontSize =
            min(max(10, (constraints.maxHeight / 12).roundToDouble()), 13.0);
        bool noVideoImage = (participant.videoMuted &&
            (participant.sessionImage == null ||
                participant.sessionImage!.isEmpty));
        final overlayColor = noVideoImage
            ? Theme.of(context).themeColors.primaryText
            : Theme.of(context).themeColors.reversedText;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: hasTotem
                    ? Theme.of(context).themeColors.primary
                    : Colors.transparent,
                width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(
                  color: Colors.black,
                ),
                if (!hasTotem &&
                    participant.me &&
                    participant.sessionUserId != null)
                  rtc_local_view.SurfaceView(
                      key: ValueKey(participant.sessionUserId)),
                if (!hasTotem &&
                    !participant.me &&
                    participant.sessionUserId != null)
                  rtc_remote_view.SurfaceView(
                    key: ValueKey(participant.sessionUserId),
                    channelId: channelId,
                    uid: int.parse(participant.sessionUserId!),
                  ),
                if (participant.videoMuted)
                  Positioned.fill(
                    child: CameraMuted(
                      userImage: participant.sessionImage,
                      imageSize: videoIconSize,
                    ),
                  ),
                if (annotate)
                  PositionedDirectional(
                    bottom: 4,
                    start: 4,
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: constraints.maxWidth - 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (next)
                            Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: CircleNextLabel(
                                  fontSize: fontSize,
                                  reversed: !noVideoImage,
                                )),
                          CircleNameLabel(
                            name: participant.name,
                            fontSize: fontSize,
                            role: participant.role,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!participant.me && participant.networkUnstable)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: CircleNetworkUnstable(
                        size: iconSize,
                        color: overlayColor,
                        shadow: !noVideoImage,
                      ),
                    ),
                  ),
                if (participant.muted)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: MuteIndicator(
                      size: iconSize,
                      color: overlayColor,
                      shadow: !noVideoImage,
                    ),
                  ),
                if (participant.videoMuted)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: CameraMuteIndicator(
                      size: iconSize,
                      color: overlayColor,
                      shadow: !noVideoImage,
                    ),
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget renderMe(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final themeColors = Theme.of(context).themeColors;
    final t = AppLocalizations.of(context)!;
    return PositionedDirectional(
      top: 0,
      start: 0,
      end: 0,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: themeColors.primary,
              borderRadius:
                  const BorderRadius.only(bottomRight: Radius.circular(16)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Text(
                    t.me,
                    style: textStyles.headline5!.merge(
                      TextStyle(
                        color: themeColors.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }

  Widget renderKeeperLabel(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final themeColors = Theme.of(context).themeColors;
    final t = AppLocalizations.of(context)!;
    return PositionedDirectional(
      top: 0,
      start: 0,
      end: 0,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: themeColors.primaryText,
              borderRadius:
                  const BorderRadius.only(bottomRight: Radius.circular(16)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.star, color: themeColors.primary, size: 24),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(t.keeper, style: textStyles.headline5),
                ],
              ),
            ),
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}
