import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/components/camera/camera_muted.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class CircleLiveSessionVideo extends ConsumerWidget {
  const CircleLiveSessionVideo({Key? key, required this.participant})
      : super(key: key);
  final SessionParticipant participant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commProvider = ref.watch(communicationsProvider);
    if (participant.me) {
      return Container(
          color: Colors.black, child: const rtc_local_view.SurfaceView());
    }
    if (!participant.me) {
      return Container(
        color: Colors.black,
        child: rtc_remote_view.SurfaceView(
          channelId: commProvider.channelId,
          uid: int.parse(participant.sessionUserId!),
        ),
      );
    }
    // This should be the muted state... to do
    return _renderUserImage(context, participant);
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
        const Positioned.fill(child: CameraMuted())
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
}
