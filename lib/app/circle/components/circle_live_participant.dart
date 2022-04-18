import 'package:flutter/material.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

import 'circle_live_session_video.dart';

class CircleLiveParticipant extends StatelessWidget {
  const CircleLiveParticipant({
    Key? key,
    required this.participant,
    this.hasTotem = false,
    this.totemReceived = false,
  }) : super(key: key);
  final SessionParticipant participant;
  final bool hasTotem;
  final bool totemReceived;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final themeColors = themeData.themeColors;
    return Column(
      children: [
        if (!hasTotem) const SizedBox(height: 8),
        Opacity(
          opacity: hasTotem || !totemReceived ? 1.0 : 0.6,
          child: SizedBox(
            height: hasTotem ? 72 : 64,
            width: hasTotem ? 72 : 64,
            child: Container(
              decoration: BoxDecoration(
                color: themeColors.trayBackground,
                boxShadow: [
                  BoxShadow(
                      color: themeColors.shadow,
                      offset: Offset(0, hasTotem ? 4 : 2),
                      blurRadius: 4),
                ],
                border: Border.all(
                  color: hasTotem
                      ? themeColors.primary
                      : themeColors.participantBorder,
                  width: hasTotem ? 2.0 : 1,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: CircleLiveSessionVideo(
                  participant: participant,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
