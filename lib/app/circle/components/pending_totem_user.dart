import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/theme/app_theme_styles.dart';

class PendingTotemUser extends StatelessWidget {
  const PendingTotemUser(
      {Key? key, this.userVideo, this.onPass, this.onReceive, this.onSettings})
      : super(key: key);
  final Widget? userVideo;
  final Function()? onReceive;
  final Function()? onPass;
  final Function()? onSettings;

  static const double titleSpacing = 14;
  static const double buttonSize = 330;
  static const double buttonSizeVertical = 220;
  static const double labelFontSize = 20;
  static const double standardFontSize = 15;
  static const double iconSize = 100;
  static const double iconSizeVertical = 80;

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
                _passTotem(context, vertical: true),
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
                          width: 1, color: themeColors.controlButtonBackground),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      child: userVideo,
                    ),
                  ),
                ),
              );
            }),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Row(
              children: [
                Expanded(child: Container()),
                _receiveTotem(context),
                const SizedBox(
                  width: 15,
                ),
                _passTotem(context),
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
    return buttonContainer(
      context,
      FaIcon(FontAwesomeIcons.handshake,
          size: !vertical ? iconSize : iconSizeVertical,
          color: Theme.of(context).themeColors.primaryText),
      t.receive,
      t.circleTotemReceive,
      [
        _lineItem(context, t.circleTotemReceiveLine1),
        _lineItem(context, t.circleTotemReceiveLine2),
      ],
      vertical: vertical,
      onPressed: onReceive,
    );
  }

  Widget _passTotem(BuildContext context, {bool vertical = false}) {
    final t = AppLocalizations.of(context)!;
    return buttonContainer(
      context,
      FaIcon(FontAwesomeIcons.hand,
          size: !vertical ? iconSize : iconSizeVertical,
          color: Theme.of(context).themeColors.primaryText),
      t.pass,
      t.circleTotemPass,
      [
        _lineItem(context, t.circleTotemPassLine1),
        _lineItem(context, t.circleTotemPassLine2),
        _lineItem(context, t.circleTotemPassLine3),
      ],
      vertical: vertical,
      onPressed: onPass,
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
                      child: userVideo),
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

  Widget _lineItem(BuildContext context, String text) {
    final themeColors = Theme.of(context).themeColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(Icons.circle, color: themeColors.primaryText, size: 12),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  color: themeColors.primaryText, fontSize: standardFontSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget buttonContainer(BuildContext context, Widget image, String label,
      String message, List<Widget> items,
      {bool vertical = false, Function()? onPressed}) {
    final themeColors = Theme.of(context).themeColors;
    final style =
        TextStyle(color: themeColors.primaryText, fontSize: standardFontSize);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 350),
      child: ThemedRaisedButton(
        backgroundColor: themeColors.controlButtonBackground,
        horzPadding: 0,
        height: !vertical ? buttonSize : buttonSizeVertical,
        width: !vertical ? 250 : null,
        onPressed: () {
          if (onPressed != null) {
            onPressed();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: !vertical ? 30 : 0,
            ),
            Center(
              child: image,
            ),
            Text(
              label,
              style: style.merge(const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: labelFontSize)),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: !vertical ? 30 : 5,
            ),
            Text(
              message,
              style: style,
            ),
            SizedBox(
              height: !vertical ? 14 : 5,
            ),
            ...items,
            if (!vertical) Expanded(child: Container()),
          ],
        ),
      ),
    );
  }
}
