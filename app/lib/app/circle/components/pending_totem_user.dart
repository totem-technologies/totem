import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/components/index.dart';
import 'package:totem/theme/app_theme_styles.dart';

class PendingTotemUser extends ConsumerStatefulWidget {
  const PendingTotemUser({
    super.key,
    this.userVideo,
    this.onReceive,
    this.onSettings,
  });
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
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
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

  Widget _receiveTotem(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return TotemActionButton(
      label: t.receive,
      busy: busy,
      cta: true,
      onPressed: () {
        setState(() {
          busy = true;
        });
        Future.delayed(const Duration(seconds: 10), () {
          if (mounted) {
            setState(() {
              busy = false;
            });
          }
        });
        widget.onReceive!();
      },
    );
  }
}
