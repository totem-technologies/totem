import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/app/circle/circle_session_page.dart';
import 'package:totem/app/circle/components/index.dart';
import 'package:totem/theme/app_theme_styles.dart';

class PendingTotemUser extends ConsumerStatefulWidget {
  const PendingTotemUser({
    Key? key,
    this.userVideo,
    this.onReceive,
    this.onSettings,
  }) : super(key: key);
  final Widget? userVideo;
  final Function()? onReceive;
  final Function()? onSettings;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      PendingTotemUserState();
}

class PendingTotemUserState extends ConsumerState<PendingTotemUser> {
  static const double buttonSize = 330;
  static const double buttonSizeVertical = 220;
  static const double labelFontSize = 20;
  static const double standardFontSize = 15;
  static const double iconSize = 30;
  late final bool _showToolTips;

  @override
  void initState() {
    try {
      _showToolTips = ref.read(activeSessionProvider).showTooltips;
    } catch (ex) {
      _showToolTips = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 500) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _receiveTotem(context, vertical: true),
                const SizedBox(
                  height: 15,
                ),
                _settingsVideo(context, vertical: true),
              ],
            ),
          );
        }
        final themeColors = Theme.of(context).themeColors;
        return Stack(children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final sizeOfVideo =
                    min(constraints.maxWidth, constraints.maxHeight);
                return Center(
                  child: SizedBox(
                    width: sizeOfVideo,
                    height: sizeOfVideo,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            width: 1,
                            color: themeColors.controlButtonBackground),
                      ),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16)),
                        child: widget.userVideo,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Row(
              children: [
                Expanded(child: Container()),
                _receiveTotem(context),
                Expanded(child: Container()),
                /*const SizedBox(
                width: 15,
              ),
              Expanded(child: _settingsVideo(context)), */
              ],
            ),
          ),
        ]);
      },
    );
  }

  Widget _receiveTotem(BuildContext context, {bool vertical = false}) {
    final t = AppLocalizations.of(context)!;
    return TotemActionButton(
      image: Icon(LucideIcons.wand2,
          size: iconSize, color: Theme.of(context).themeColors.primaryText),
      label: t.receive,
      message: t.circleTotemReceive,
      toolTips: [t.circleTotemReceiveLine1, t.circleTotemReceiveLine2],
      showToolTips: _showToolTips,
      vertical: vertical,
      onPressed: widget.onReceive,
    );
  }

  Widget _settingsVideo(BuildContext context, {bool vertical = false}) {
    final t = AppLocalizations.of(context)!;
    final themeColors = Theme.of(context).themeColors;
    final style =
        TextStyle(color: themeColors.reversedText, fontSize: standardFontSize);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double size = min(constraints.maxWidth, 360);
        return SizedBox(
          height: !vertical ? buttonSize : buttonSizeVertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      width: 1, color: themeColors.controlButtonBackground),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  child: Container(
                      width: vertical ? 110 : size,
                      height: vertical ? 110 : size,
                      color: Colors.black,
                      child: widget.userVideo),
                ),
              ),
              Text(
                t.preview,
                style: style.merge(const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: labelFontSize)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
