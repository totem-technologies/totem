import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/providers.dart';
import 'package:totem/theme/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:totem/app/circle/circle_session_page.dart';

class CircleSessionControls extends ConsumerStatefulWidget {
  const CircleSessionControls({Key? key}) : super(key: key);

  @override
  _CircleSessionControlsState createState() => _CircleSessionControlsState();
}

class _CircleSessionControlsState extends ConsumerState<CircleSessionControls> {
  bool _more = false;

  @override
  Widget build(BuildContext context) {
    // final textStyles = themeData.textStyles;
//    final themeColors = Theme.of(context).themeColors;
    final authUser = ref.read(authServiceProvider).currentUser()!;
    final activeSession = ref.watch(activeSessionProvider);
    final role = activeSession.participantRole(authUser.uid);
    return BottomTrayContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: activeSession.state == SessionState.waiting
            ? waitingControls(context, ref, activeSession, role, authUser.uid)
            : liveControls(context, ref, activeSession, role),
      ),
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
        if (role == Roles.keeper)
          ThemedControlButton(
            label: t.start,
            svgImage: activeSession.state == SessionState.waiting
                ? 'assets/view_circle.svg'
                : 'assets/view_circle.svg',
            backgroundColor: themeColors.primary,
            onPressed: () {
              _startSession(context, ref);
            },
          ),
        ThemedControlButton(
          label: t.info,
          svgImage: 'assets/info.svg',
          onPressed: () {
            debugPrint('start pressed');
          },
        ),
      ],
    );
  }

  Widget liveControls(BuildContext context, WidgetRef ref,
      ActiveSession activeSession, Role role) {
    final themeColors = Theme.of(context).themeColors;
    final t = AppLocalizations.of(context)!;
    final communications = ref.watch(communicationsProvider);
    return Column(
      children: [
        Row(
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
              label: t.receive,
              svgImage: 'assets/check.svg',
              backgroundColor: themeColors.primary,
              onPressed: null, //() {},
            ),
            ThemedControlButton(
              label: t.pass,
              svgImage: 'assets/close.svg',
              backgroundColor: themeColors.primary,
              onPressed: null, //() {},
            ),
            if (role == Roles.member)
              ThemedControlButton(
                label: t.info,
                svgImage: 'assets/info.svg',
                onPressed: () {
                  debugPrint('info pressed');
                },
              ),
            if (role == Roles.keeper)
              ThemedControlButton(
                label: !_more ? t.more : t.less,
                svgImage: !_more ? 'assets/more.svg' : 'assets/less.svg',
                onPressed: () {
                  setState(() => _more = !_more);
                },
              ),
          ],
        ),
        if (role == Roles.keeper && _more) ...[
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
