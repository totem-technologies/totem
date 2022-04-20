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
  const CircleSessionControls({Key? key}) : super(key: key);

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
    return Stack(
      children: [
        BottomTrayContainer(
          backgroundColor:
              activeSession.state == SessionState.live ? Colors.black : null,
          child: SafeArea(
            top: false,
            bottom: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: activeSession.state == SessionState.waiting
                  ? waitingControls(
                      context, ref, activeSession, role, authUser.uid)
                  : activeSession.state == SessionState.live
                      ? liveControls(context, ref, activeSession, role)
                      : emptyControls(context),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 1,
            color: activeSession.state == SessionState.live
                ? Colors.black
                : Theme.of(context).themeColors.trayBackground,
          ),
        ),
      ],
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: Container(),
        ),
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
        if (role == Role.keeper) ...[
          ThemedControlButton(
            label: t.start,
            size: 48,
            iconHeight: 20,
            svgImage: activeSession.state == SessionState.waiting
                ? 'assets/view_circle.svg'
                : 'assets/view_circle.svg',
            backgroundColor: themeColors.primary,
            iconPadding: const EdgeInsets.all(6),
            onPressed: () {
              _startSession(context, ref);
            },
          ),
        ],
        ThemedControlButton(
          label: t.info,
          svgImage: 'assets/info.svg',
          onPressed: () {
            debugPrint('info pressed');
            _showCircleInfo(context);
          },
        ),
        Expanded(
          flex: 1,
          child: Container(),
        ),
      ],
    );
  }

  Widget liveControls(BuildContext context, WidgetRef ref,
      ActiveSession activeSession, Role role) {
    final t = AppLocalizations.of(context)!;
    final themeColors = Theme.of(context).themeColors;
    final communications = ref.watch(communicationsProvider);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 1,
              child: Container(),
            ),
            ThemedControlButton(
              label: communications.muted ? t.unmute : t.mute,
              labelColor: themeColors.reversedText,
              svgImage: communications.muted
                  ? 'assets/microphone_mute.svg'
                  : 'assets/microphone.svg',
              onPressed: () {
                if (communications.muted) {
                  communications.muteAudio(false);
                } else {
                  communications.muteAudio(true);
                }
                debugPrint('mute pressed');
              },
            ),
            const SizedBox(
              width: 20,
            ),
            ThemedControlButton(
              label: communications.videoMuted ? t.startVideo : t.stopVideo,
              labelColor: themeColors.reversedText,
              svgImage: !communications.videoMuted
                  ? 'assets/video.svg'
                  : 'assets/video_stop.svg',
              onPressed: () {
                communications
                    .muteVideo(communications.videoMuted ? false : true);
                debugPrint('video pressed');
              },
            ),
            if (role == Role.keeper) ...[
              const SizedBox(
                width: 20,
              ),
              ThemedControlButton(
                label: !_more ? t.more : t.less,
                labelColor: themeColors.reversedText,
                svgImage: !_more ? 'assets/more.svg' : 'assets/less.svg',
                onPressed: () {
                  setState(() => _more = !_more);
                },
              ),
            ],
            Expanded(
              flex: 1,
              child: Container(),
            ),
          ],
        ),
        if (role == Role.keeper && _more) ...[
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: Container(),
              ),
              /* ThemedControlButton(
                label: t.openFloor,
                labelColor: themeColors.reversedText,
                svgImage: 'assets/unlock.svg',
                onPressed: () {
                  debugPrint('lock pressed');
                },
              ),
              const SizedBox(
                width: 20,
              ),*/
              ThemedControlButton(
                label: t.next,
                labelColor: themeColors.reversedText,
                svgImage: 'assets/fast_forward.svg',
                onPressed: () {
                  _nextUser(context, ref);
                },
              ),
              const SizedBox(
                width: 20,
              ),
              ThemedControlButton(
                label: t.endSession,
                labelColor: themeColors.reversedText,
                svgImage: 'assets/leave.svg',
                onPressed: () {
                  _endSessionPrompt(context, ref);
                },
              ),
              Expanded(
                flex: 1,
                child: Container(),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _nextUser(BuildContext context, WidgetRef ref) async {
    final commProvider = ref.read(communicationsProvider);
    await commProvider.forceNextActiveSessionTotem();
  }

  void _startSession(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(repositoryProvider);

    await repo.startActiveSession();
  }

  Future<void> _showCircleInfo(BuildContext context) async {
    await CircleSessionInfoPage.showDialog(context);
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
