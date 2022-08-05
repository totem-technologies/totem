import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/utils/device_type.dart';
import 'package:totem/theme/index.dart';

class TestSessionControls extends ConsumerStatefulWidget {
  const TestSessionControls(
      {Key? key,
      required this.sessionState,
      required this.role,
      this.circleName = "This is a sample circle"})
      : super(key: key);
  final SessionState sessionState;
  final Role role;
  final String circleName;

  @override
  TestSessionControlsState createState() => TestSessionControlsState();
}

class TestSessionControlsState extends ConsumerState<TestSessionControls> {
  bool _more = false;
  Timer? _timer;
  static const double _btnSpacing = 6;
  bool muted = false;
  bool videoMuted = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              backgroundColor: widget.sessionState == SessionState.live
                  ? Colors.black
                  : null,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: widget.sessionState == SessionState.waiting
                    ? waitingControls(
                        context,
                        ref,
                        widget.role,
                      )
                    : widget.sessionState == SessionState.live
                        ? liveControls(context, ref, widget.role, isPhoneLayout,
                            constraints.maxWidth)
                        : emptyControls(context),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                color: widget.sessionState == SessionState.live
                    ? Colors.black
                    : Theme.of(context).themeColors.trayBackground,
              ),
            ),
          ],
        );
      },
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

  Widget waitingControls(BuildContext context, WidgetRef ref, Role role) {
    final themeColors = Theme.of(context).themeColors;
    final t = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(),
        ),
        ThemedControlButton(
          label: muted ? t.unmute : t.mute,
          icon: muted ? Icons.mic_off : Icons.mic,
          onPressed: () {
            setState(() => muted = !muted);
          },
        ),
        const SizedBox(width: _btnSpacing),
        ThemedControlButton(
          label: videoMuted ? t.startVideo : t.stopVideo,
          icon: !videoMuted ? Icons.videocam : Icons.videocam_off,
          onPressed: () {
            setState(() => videoMuted = !videoMuted);
          },
        ),
        if (role == Role.keeper) ...[
          const SizedBox(width: _btnSpacing),
          ThemedControlButton(
            label: t.start,
            size: 48,
            iconHeight: 20,
            backgroundColor: themeColors.primary,
            iconPadding: const EdgeInsets.all(6),
            onPressed: () {},
            child: SizedBox(
              height: 24,
              width: 24,
              child: widget.sessionState == SessionState.waiting
                  ? SvgPicture.asset('assets/view_circle.svg')
                  : SvgPicture.asset('assets/view_circle.svg'),
            ),
          ),
        ],
        const SizedBox(width: _btnSpacing),
        ThemedControlButton(
          label: t.info,
          icon: Icons.info_outline,
          onPressed: () {
            debugPrint('info pressed');
          },
        ),
        Expanded(
          flex: 1,
          child: Container(),
        ),
      ],
    );
  }

  Widget liveControls(BuildContext context, WidgetRef ref, Role role,
      bool isPhoneLayout, double maxWidth) {
    final t = AppLocalizations.of(context)!;
    final themeColors = Theme.of(context).themeColors;
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
                  label: muted ? t.unmute : t.mute,
                  labelColor: themeColors.reversedText,
                  icon: muted ? Icons.mic_off : Icons.mic,
                  onPressed: () {
                    setState(() => muted = !muted);
                  },
                ),
                const SizedBox(
                  width: _btnSpacing,
                ),
                ThemedControlButton(
                  label: videoMuted ? t.startVideo : t.stopVideo,
                  labelColor: themeColors.reversedText,
                  icon: !videoMuted ? Icons.videocam : Icons.videocam_off,
                  onPressed: () {
                    setState(() => videoMuted = !videoMuted);
                  },
                ),
                if (role == Role.keeper) ...[
                  const SizedBox(
                    width: _btnSpacing,
                  ),
                  ThemedControlButton(
                    label: !_more ? t.more : t.less,
                    labelColor: themeColors.reversedText,
                    icon: !_more ? Icons.more_horiz : Icons.more_vert,
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
                    icon: Icons.exit_to_app,
                    onPressed: () {},
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
                    label: t.next,
                    labelColor: themeColors.reversedText,
                    icon: Icons.fast_forward,
                    onPressed: () {},
                  ),
                  const SizedBox(
                    width: _btnSpacing,
                  ),
                  ThemedControlButton(
                    label: t.endSession,
                    labelColor: themeColors.reversedText,
                    icon: Icons.exit_to_app,
                    onPressed: () {},
                  ),
                  const SizedBox(width: _btnSpacing),
                  ThemedControlButton(
                    label: t.info,
                    labelColor: themeColors.reversedText,
                    icon: Icons.info_outline,
                    onPressed: () {
                      debugPrint('info pressed');
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
          CircleLiveTrayTitle(title: widget.circleName, maxWidth: maxWidth)
      ],
    );
  }
}
