import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                child: hasTotem
                    ? ((!participant.hasImage)
                        ? Container(
                            color: participant.me
                                ? themeColors.primary.withAlpha(80)
                                : themeColors.profileBackground,
                            child: _genericUserImage(context),
                          )
                        : _renderUserImage(context))
                    : CircleLiveSessionVideo(
                        participant: participant,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderUserImage(BuildContext context) {
    if (participant.sessionImage!.toLowerCase().contains("assets/")) {
      return Image.asset(
        participant.sessionImage!,
        fit: BoxFit.cover,
      );
    }
    return CachedNetworkImage(
      imageUrl: participant.sessionImage!,
      errorWidget: (context, url, error) => _genericUserImage(context),
    );
  }

  Widget _genericUserImage(BuildContext context) {
    return Center(
      child: SvgPicture.asset('assets/profile.svg'),
    );
  }
}
