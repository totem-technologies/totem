import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/circle_session_page.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class CircleLiveTotemParticipant extends ConsumerStatefulWidget {
  const CircleLiveTotemParticipant({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CircleLiveTotemParticipantState();
}

class _CircleLiveTotemParticipantState
    extends ConsumerState<CircleLiveTotemParticipant> {
  @override
  Widget build(BuildContext context) {
    final activeSession = ref.watch(activeSessionProvider);
    final totemParticipant = activeSession.totemParticipant;
    if (totemParticipant != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Container()),
          Opacity(
            opacity: totemParticipant.me ? 1.0 : 0,
            child: const Text("Your Turn"), // FIXME - replace with design item
          ),
          const SizedBox(height: 16),
          participant(context, totemParticipant),
          Expanded(child: Container()),
        ],
      );
    }
    return Container();
  }

  Widget participant(BuildContext context, SessionParticipant participant) {
    final themeColors = Theme.of(context).themeColors;
    return Container(
      width: 142,
      height: 142,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x3EFFE892), Color(0x3EFFCC59)],
        ),
        boxShadow: [
          BoxShadow(
              color: Color(0x99FCB71B), offset: Offset(0, 0), blurRadius: 80),
        ],
      ),
      child: Center(
        child: ClipOval(
          child: SizedBox(
            width: 126,
            height: 126,
            child: participant.hasImage
                ? CachedNetworkImage(
                    imageUrl: participant.sessionImage!, fit: BoxFit.cover)
                : Container(),
          ),
        ),
      ),
    );
  }
}
