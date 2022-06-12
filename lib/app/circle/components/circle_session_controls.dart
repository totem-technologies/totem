import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/providers.dart';
import 'package:totem/services/utils/device_type.dart';
import 'package:totem/theme/index.dart';

class CircleSessionControls extends ConsumerStatefulWidget {
  const CircleSessionControls({Key? key}) : super(key: key);

  @override
  CircleSessionControlsState createState() => CircleSessionControlsState();
}

class CircleSessionControlsState extends ConsumerState<CircleSessionControls> {
  bool _more = false;
  Timer? _timer;
  static const double _btnSpacing = 6;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.read(authServiceProvider).currentUser()!;
    final activeSession = ref.watch(activeSessionProvider);
    final role = activeSession.participantRole(authUser.uid);
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      debugPrint(
          'Live Controls width: ${constraints.maxWidth} <= ${Theme.of(context).portraitBreak}');
      bool isPhoneLayout = DeviceType.isPhone() ||
          constraints.maxWidth <= Theme.of(context).portraitBreak;
      return Stack(
        children: [
          BottomTrayContainer(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            backgroundColor:
                activeSession.state == SessionState.live ? Colors.black : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: activeSession.state == SessionState.waiting
                  ? waitingControls(
                      context, ref, activeSession, role, authUser.uid)
                  : activeSession.state == SessionState.live
                      ? liveControls(context, ref, activeSession, role,
                          isPhoneLayout, constraints.maxWidth)
                      : emptyControls(context),
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
    });
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
            triggerPress(() {
              communications.muteAudio(communications.muted ? false : true);
              debugPrint('mute pressed');
            });
          },
        ),
        const SizedBox(width: _btnSpacing),
        ThemedControlButton(
          label: communications.videoMuted ? t.startVideo : t.stopVideo,
          svgImage: !communications.videoMuted
              ? 'assets/video.svg'
              : 'assets/video_stop.svg',
          onPressed: () {
            triggerPress(() {
              communications
                  .muteVideo(communications.videoMuted ? false : true);
              debugPrint('video pressed');
            });
          },
        ),
        if (role == Role.keeper) ...[
          const SizedBox(width: _btnSpacing),
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
        const SizedBox(width: _btnSpacing),
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

  Widget liveControls(
      BuildContext context,
      WidgetRef ref,
      ActiveSession activeSession,
      Role role,
      bool isPhoneLayout,
      double maxWidth) {
    final t = AppLocalizations.of(context)!;
    final themeColors = Theme.of(context).themeColors;
    final communications = ref.watch(communicationsProvider);
    return Stack(
      children: [
        Column(
          children: [
            Row(
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
                    triggerPress(() {
                      if (communications.muted) {
                        communications.muteAudio(false);
                      } else {
                        communications.muteAudio(true);
                      }
                      debugPrint('mute pressed');
                    });
                  },
                ),
                const SizedBox(
                  width: _btnSpacing,
                ),
                ThemedControlButton(
                  label: communications.videoMuted ? t.startVideo : t.stopVideo,
                  labelColor: themeColors.reversedText,
                  svgImage: !communications.videoMuted
                      ? 'assets/video.svg'
                      : 'assets/video_stop.svg',
                  onPressed: () {
                    triggerPress(() {
                      communications
                          .muteVideo(communications.videoMuted ? false : true);
                      debugPrint('video pressed');
                    });
                  },
                ),
                if (role == Role.keeper) ...[
                  const SizedBox(
                    width: _btnSpacing,
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
                if (role != Role.keeper) ...[
                  const SizedBox(width: _btnSpacing),
                  ThemedControlButton(
                    label: t.leaveSession,
                    labelColor: themeColors.reversedText,
                    svgImage: 'assets/leave.svg',
                    onPressed: () {
                      _endSessionPrompt(context, ref, role);
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
                width: _btnSpacing,
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
                    width: _btnSpacing,
                  ),
                  ThemedControlButton(
                    label: t.endSession,
                    labelColor: themeColors.reversedText,
                    svgImage: 'assets/leave.svg',
                    onPressed: () {
                      _endSessionPrompt(context, ref, role);
                    },
                  ),
                  const SizedBox(width: _btnSpacing),
                  ThemedControlButton(
                    label: t.info,
                    labelColor: themeColors.reversedText,
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
              ),
            ],
          ],
        ),
        if (!isPhoneLayout)
          CircleLiveTrayTitle(
              title: activeSession.circle.name, maxWidth: maxWidth)
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

  Future<void> _endSessionPrompt(
      BuildContext context, WidgetRef ref, Role role) async {
    FocusScope.of(context).unfocus();
    final t = AppLocalizations.of(context)!;
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title:
          Text(role == Role.keeper ? t.endSessionPrompt : t.leaveSessionPrompt),
      content: Text(role == Role.keeper
          ? t.endSessionPromptMessage
          : t.leaveSessionPromptMessage),
      actions: [
        TextButton(
          child: Text(role == Role.keeper ? t.endSession : t.leaveSession),
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
      if (role == Role.keeper) {
        await commProvider.endSession();
      } else {
        await commProvider.leaveSession();
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    }
  }

  void triggerPress(Function func) {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 350), () {
      func();
    });
  }
}
