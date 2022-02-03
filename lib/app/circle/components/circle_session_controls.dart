import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/circle_session_info_page.dart';
import 'package:totem/app/circle/circle_session_page.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/providers.dart';
import 'package:totem/theme/index.dart';

class CircleSessionControls extends ConsumerStatefulWidget {
  const CircleSessionControls({Key? key, required this.session})
      : super(key: key);
  final Session session;

  @override
  _CircleSessionControlsState createState() => _CircleSessionControlsState();
}

class _CircleSessionControlsState extends ConsumerState<CircleSessionControls> {
  bool _more = false;

  @override
  Widget build(BuildContext context) {
    final authUser = ref.read(authServiceProvider).currentUser()!;
    final activeSession = ref.watch(activeSessionProvider);
    final role = activeSession.participantRole(authUser.uid);
    return BottomTrayContainer(
      child: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          child: activeSession.state == SessionState.waiting
              ? waitingControls(context, ref, activeSession, role, authUser.uid)
              : activeSession.state == SessionState.live
                  ? liveControls(context, ref, activeSession, role)
                  : emptyControls(context),
        ),
      ),
    );
  }

  Widget emptyControls(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: SizedBox(height: 40),
        ),
      ],
    );
  }

  Widget waitingControls(BuildContext context, WidgetRef ref,
      ActiveSession activeSession, Role role, String userId) {
    final themeColors = Theme.of(context).themeColors;
    final t = AppLocalizations.of(context)!;
    final communications = ref.watch(communicationsProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ThemedControlButton(
          label: communications.muted ? t.unmute : t.mute,
          svgImage: communications.muted
              ? 'assets/microphone_mute.svg'
              : 'assets/microphone.svg',
          onPressed: () {
            communications.muteAudio(communications.muted ? false : true);
            debugPrint('mute pressed');
          },
        ),
        ThemedControlButton(
          label: communications.videoMuted ? t.startVideo : t.stopVideo,
          svgImage: !communications.videoMuted
              ? 'assets/video.svg'
              : 'assets/video_stop.svg',
          onPressed: () {
            communications.muteVideo(communications.videoMuted ? false : true);
            debugPrint('video pressed');
          },
        ),
        if (role == Role.keeper)
          ThemedControlButton(
            label: t.start,
            svgImage: activeSession.state == SessionState.waiting
                ? 'assets/view_circle.svg'
                : 'assets/view_circle.svg',
            backgroundColor: themeColors.primary,
            iconPadding: const EdgeInsets.all(6),
            onPressed: () {
              _startSession(context, ref);
            },
          ),
        ThemedControlButton(
          label: t.info,
          svgImage: 'assets/info.svg',
          onPressed: () {
            debugPrint('info pressed');
            _showCircleInfo(context);
          },
        ),
      ],
    );
  }

  Widget liveControls(BuildContext context, WidgetRef ref,
      ActiveSession activeSession, Role role) {
    final t = AppLocalizations.of(context)!;
    final communications = ref.watch(communicationsProvider);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ThemedControlButton(
              label: communications.muted ? t.forceUnMute : t.mute,
              svgImage: communications.muted
                  ? 'assets/microphone_force.svg'
                  : 'assets/microphone.svg',
              onPressed: () {
                communications.muteAudio(communications.muted ? false : true);
                debugPrint('mute pressed');
              },
            ),
            if (role == Role.member)
              ThemedControlButton(
                label: t.info,
                svgImage: 'assets/info.svg',
                onPressed: () {
                  debugPrint('info pressed');
                },
              ),
            if (role == Role.keeper)
              ThemedControlButton(
                label: !_more ? t.more : t.less,
                svgImage: !_more ? 'assets/more.svg' : 'assets/less.svg',
                onPressed: () {
                  setState(() => _more = !_more);
                },
              ),
          ],
        ),
        if (role == Role.keeper && _more) ...[
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ThemedControlButton(
                label: t.info,
                svgImage: 'assets/info.svg',
                onPressed: () {
                  debugPrint('info pressed');
                },
              ),
              ThemedControlButton(
                label: t.openFloor,
                svgImage: 'assets/unlock.svg',
                onPressed: () {
                  debugPrint('lock pressed');
                },
              ),
              ThemedControlButton(
                label: t.skip,
                svgImage: 'assets/fast_forward.svg',
                onPressed: () {
                  debugPrint('mute pressed');
                },
              ),
              ThemedControlButton(
                label: t.endSession,
                svgImage: 'assets/leave.svg',
                onPressed: () {
                  _endSessionPrompt(context, ref);
                },
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _startSession(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(repositoryProvider);

    await repo.startActiveSession();
  }

  Future<void> _showCircleInfo(BuildContext context) async {
    await CircleSessionInfoPage.showDialog(context, session: widget.session);
  }

  Future<void> _endSessionPrompt(BuildContext context, WidgetRef ref) async {
    FocusScope.of(context).unfocus();
    final t = AppLocalizations.of(context)!;
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(t.endSessionPrompt),
      content: Text(t.endSessionPromptMessage),
      actions: [
        TextButton(
          child: Text(t.endSession),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
        TextButton(
          child: Text(t.cancel),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ],
    );
    // show the dialog
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
    if (result) {
      final commProvider = ref.read(communicationsProvider);
      await commProvider.endSession();
//       Navigator.of(context).pop();
    }
  }
}
