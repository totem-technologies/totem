import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/app/circle/components/circle_network_indicator.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/providers.dart';
import 'package:totem/services/utils/device_type.dart';
import 'package:totem/theme/index.dart';
import 'package:universal_html/html.dart' show document;

class CircleSessionControls extends ConsumerStatefulWidget {
  const CircleSessionControls({Key? key}) : super(key: key);

  @override
  CircleSessionControlsState createState() => CircleSessionControlsState();
}

class CircleSessionControlsState extends ConsumerState<CircleSessionControls> {
  var _more = false;
  var _fullscreen = false;
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
    final me = activeSession.me();
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      debugPrint(
          'Live Controls width: ${constraints.maxWidth} <= ${Theme.of(context).portraitBreak}');
      bool isPhoneLayout = DeviceType.isPhone() ||
          constraints.maxWidth <= Theme.of(context).portraitBreak;
      return Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          BottomTrayContainer(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            backgroundColor: activeSession.live ? Colors.black : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: activeSession.state == SessionState.waiting
                  ? waitingControls(
                      context, ref, activeSession, role, authUser.uid)
                  : activeSession.live
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
              color: activeSession.live
                  ? Colors.black
                  : Theme.of(context).themeColors.trayBackground,
            ),
          ),
          if (me != null && me.networkUnstable)
            Positioned(
              top: -35,
              child: Center(
                child: CircleNetworkUnstable(
                  participant: activeSession.me(),
                ),
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
          icon: communications.muted ? LucideIcons.micOff : LucideIcons.mic,
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
          icon: !communications.videoMuted
              ? LucideIcons.video
              : LucideIcons.videoOff,
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
            iconHeight: 20,
            backgroundColor: themeColors.primary,
            iconPadding: const EdgeInsets.all(6),
            onPressed: () {
              _startSession(context, ref);
            },
            child: SizedBox(
              height: 24,
              width: 24,
              child: activeSession.state == SessionState.waiting
                  ? SvgPicture.asset('assets/view_circle.svg')
                  : SvgPicture.asset('assets/view_circle.svg'),
            ),
          ),
        ],
        const SizedBox(width: _btnSpacing),
        ThemedControlButton(
          label: t.info,
          icon: LucideIcons.info,
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
    if (isPhoneLayout) {
      return Column(
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
                icon:
                    communications.muted ? LucideIcons.micOff : LucideIcons.mic,
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
                icon: !communications.videoMuted
                    ? LucideIcons.video
                    : LucideIcons.videoOff,
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
                  label: t.reverse,
                  labelColor: themeColors.reversedText,
                  icon: LucideIcons.rotateCw,
                  onPressed: () {
                    debugPrint('info pressed');
                    _reverseOrder(context, ref);
                  },
                ),
                const SizedBox(
                  width: _btnSpacing,
                ),
                ThemedControlButton(
                  label: !_more ? t.more : t.less,
                  labelColor: themeColors.reversedText,
                  icon: !_more
                      ? LucideIcons.moreHorizontal
                      : LucideIcons.moreVertical,
                  onPressed: () {
                    setState(() => _more = !_more);
                  },
                ),
              ],
              if (role != Role.keeper) ...[
                if (kIsWeb) ...[
                  const SizedBox(width: _btnSpacing),
                  ThemedControlButton(
                    label: _fullscreen ? t.exit_fullscreen : t.fullscreen,
                    labelColor: themeColors.reversedText,
                    icon: _fullscreen
                        ? LucideIcons.minimize
                        : LucideIcons.maximize,
                    onPressed: _toggleFullscreen,
                  ),
                ],
                const SizedBox(width: _btnSpacing),
                ThemedControlButton(
                  label: t.leaveSession,
                  labelColor: themeColors.reversedText,
                  icon: LucideIcons.logOut,
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
                ThemedControlButton(
                  label: t.muteAll,
                  labelColor: themeColors.reversedText,
                  child: Icon(LucideIcons.users,
                      size: 20, color: themeColors.primaryText),
                  onPressed: () {
                    _muteAllExceptTotem(context, ref);
                  },
                ),
                const SizedBox(width: _btnSpacing),
                ThemedControlButton(
                  label: t.next,
                  labelColor: themeColors.reversedText,
                  icon: LucideIcons.fastForward,
                  onPressed: () {
                    _nextUser(context, ref);
                  },
                ),
                const SizedBox(width: _btnSpacing),
                ThemedControlButton(
                  label: t.info,
                  labelColor: themeColors.reversedText,
                  icon: LucideIcons.info,
                  onPressed: () {
                    debugPrint('info pressed');
                    _showCircleInfo(context);
                  },
                ),
                if (kIsWeb) ...[
                  const SizedBox(width: _btnSpacing),
                  ThemedControlButton(
                    label: _fullscreen ? t.exit_fullscreen : t.fullscreen,
                    labelColor: themeColors.reversedText,
                    icon: _fullscreen
                        ? LucideIcons.minimize
                        : LucideIcons.maximize,
                    onPressed: _toggleFullscreen,
                  ),
                ],
                const SizedBox(
                  width: _btnSpacing,
                ),
                ThemedControlButton(
                  label: t.endSession,
                  labelColor: themeColors.reversedText,
                  backgroundColor: themeColors.error,
                  imageColor: themeColors.reversedText,
                  icon: LucideIcons.x,
                  onPressed: () {
                    _endSessionPrompt(context, ref, role);
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
                if (role == Role.keeper) ...[
                  ThemedControlButton(
                    label: t.muteAll,
                    labelColor: themeColors.reversedText,
                    child: Icon(LucideIcons.users,
                        size: 20, color: themeColors.primaryText),
                    onPressed: () {
                      _muteAllExceptTotem(context, ref);
                    },
                  ),
                  const SizedBox(
                    width: _btnSpacing,
                  ),
                ],
                ThemedControlButton(
                  label: communications.muted ? t.unmute : t.mute,
                  labelColor: themeColors.reversedText,
                  icon: communications.muted
                      ? LucideIcons.micOff
                      : LucideIcons.mic,
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
                  icon: !communications.videoMuted
                      ? LucideIcons.video
                      : LucideIcons.videoOff,
                  onPressed: () {
                    triggerPress(() {
                      communications
                          .muteVideo(communications.videoMuted ? false : true);
                      debugPrint('video pressed');
                    });
                  },
                ),
                if (role != Role.keeper) ...[
                  if (kIsWeb) ...[
                    const SizedBox(width: _btnSpacing),
                    ThemedControlButton(
                      label: _fullscreen ? t.exit_fullscreen : t.fullscreen,
                      labelColor: themeColors.reversedText,
                      icon: _fullscreen
                          ? LucideIcons.minimize
                          : LucideIcons.maximize,
                      onPressed: _toggleFullscreen,
                    ),
                  ],
                  const SizedBox(width: _btnSpacing),
                  ThemedControlButton(
                    label: t.leaveSession,
                    labelColor: themeColors.reversedText,
                    icon: LucideIcons.logOut,
                    onPressed: () {
                      _endSessionPrompt(context, ref, role);
                    },
                  ),
                ],
                if (role == Role.keeper) ...[
                  const SizedBox(
                    width: _btnSpacing,
                  ),
                  ThemedControlButton(
                    label: t.next,
                    labelColor: themeColors.reversedText,
                    icon: LucideIcons.fastForward,
                    onPressed: () {
                      _nextUser(context, ref);
                    },
                  ),
                  const SizedBox(width: _btnSpacing),
                  ThemedControlButton(
                    label: t.reverse,
                    labelColor: themeColors.reversedText,
                    icon: LucideIcons.rotateCw,
                    onPressed: () {
                      debugPrint('info pressed');
                      _reverseOrder(context, ref);
                    },
                  ),
                  const SizedBox(width: _btnSpacing),
                  ThemedControlButton(
                    label: t.info,
                    labelColor: themeColors.reversedText,
                    icon: LucideIcons.info,
                    onPressed: () {
                      debugPrint('info pressed');
                      _showCircleInfo(context);
                    },
                  ),
                  if (kIsWeb) ...[
                    const SizedBox(width: _btnSpacing),
                    ThemedControlButton(
                      label: _fullscreen ? t.exit_fullscreen : t.fullscreen,
                      labelColor: themeColors.reversedText,
                      icon: _fullscreen
                          ? LucideIcons.minimize
                          : LucideIcons.maximize,
                      onPressed: _toggleFullscreen,
                    ),
                  ],
                  const SizedBox(width: _btnSpacing),
                  ThemedControlButton(
                    backgroundColor: themeColors.error,
                    imageColor: themeColors.reversedText,
                    label: t.endSession,
                    labelColor: themeColors.reversedText,
                    icon: LucideIcons.x,
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
          ],
        ),
      ],
    );
  }

  void _toggleFullscreen() {
    var fullscreen = document.fullscreenElement != null;
    setState(() {
      _fullscreen = !fullscreen;
    });
    if (!fullscreen) {
      document.documentElement?.requestFullscreen();
    } else {
      document.exitFullscreen();
    }
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

  Future<void> _reverseOrder(BuildContext context, WidgetRef ref) async {
    FocusScope.of(context).unfocus();
    final repo = ref.read(repositoryProvider);
    final activeSession = ref.read(activeSessionProvider);
    if (activeSession.speakOrderParticipants.length == 1) {
      return;
    }
    List<SessionParticipant> participants =
        List<SessionParticipant>.from(activeSession.speakOrderParticipants)
            .sublist(1);
    if (participants.length > 1) {
      participants = [
        activeSession.speakOrderParticipants.first,
        ...participants.reversed.toList(growable: false)
      ];
      await repo.updateActiveSession(repo.activeSession!.reorderParticipants(
          participants
              .map((element) => element.sessionUserId!)
              .toList(growable: false)));
    }
  }

  Future<void> _muteAllExceptTotem(BuildContext context, WidgetRef ref) async {
    final commProvider = ref.read(communicationsProvider);
    await commProvider.muteAllExceptTotem();
  }
}
