import 'dart:ui';

import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class CircleParticipantVideo extends ConsumerWidget {
  const CircleParticipantVideo({
    Key? key,
    required this.sessionUserId,
    this.hasTotem = false,
    this.annotate = true,
  }) : super(key: key);
  final String sessionUserId;
  final bool hasTotem;
  final bool annotate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = Theme.of(context);
    final textStyles = themeData.textTheme;
    final commProvider = ref.watch(communicationsProvider);
    final participant = ref.watch(participantProvider(sessionUserId));
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
            if (!hasTotem && participant.me && !commProvider.videoMuted)
              const rtc_local_view.SurfaceView(),
            if (!hasTotem && !participant.me && !participant.videoMuted)
              rtc_remote_view.SurfaceView(
                channelId: commProvider.channelId,
                uid: int.parse(participant.sessionUserId!),
              ),
            if (hasTotem ||
                (participant.me && commProvider.videoMuted) ||
                (!participant.me && participant.videoMuted))
              _renderUserImage(context, participant),
            if (annotate)
              PositionedDirectional(
                child: Stack(
                  children: [
                    _gradientLayer(context),
                    PositionedDirectional(
                      bottom: 0,
                      start: 0,
                      end: 0,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 12, right: 12, bottom: 8),
                        child: Text(
                          participant.name,
                          style: textStyles.headline5,
                        ),
                      ),
                    ),
                  ],
                ),
                bottom: 0,
                start: 0,
                end: 0,
              ),
            if (participant.me) renderMe(context),
            if (annotate && participant.role == Role.keeper && !participant.me)
              renderKeeperLabel(context)
          ],
        ),
      ),
    );
/*        }),
      );
    }
    return Container(); */
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

  Widget _renderUserImage(
      BuildContext context, SessionParticipant participant) {
    return Stack(
      children: [
        Container(
          color: Colors.black,
        ),
        Positioned.fill(
          child: (participant.sessionImage!.toLowerCase().contains("assets/"))
              ? Image.asset(
                  participant.sessionImage!,
                  fit: BoxFit.cover,
                )
              : CachedNetworkImage(
                  imageUrl: participant.sessionImage!,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) {
                    return _genericUserImage(context);
                  },
                ),
        ),
        if (!hasTotem || participant.videoMuted)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
              child: Container(
                color: Colors.white10,
              ),
            ),
          ),
        if (!hasTotem || participant.videoMuted)
          Align(
            alignment: Alignment.center,
            child: SvgPicture.asset('assets/cam.svg'),
          ),
      ],
    );
  }

  Widget _genericUserImage(BuildContext context) {
    return Center(
        child: Icon(
      Icons.account_circle_rounded,
      size: 80,
      color: Theme.of(context).themeColors.primaryText,
    ));
  }

  Widget _gradientLayer(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    return Container(
      height: 45,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: themeColors.profileGradient,
        ),
      ),
    );
  }
}
