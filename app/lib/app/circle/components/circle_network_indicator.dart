import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class CircleNetworkUnstable extends StatelessWidget {
  const CircleNetworkUnstable(
      {Key? key,
      this.participant,
      this.size = 32,
      this.color,
      this.shadow = true})
      : super(key: key);
  final SessionParticipant? participant;
  final double size;
  final Color? color;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    if (participant == null) {
      return shadow
          ? DecoratedIcon(
              Icons.signal_wifi_statusbar_connected_no_internet_4,
              size: size,
              color: color ?? themeColors.reversedText,
              shadows: const [
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 6,
                  spreadRadius: 0,
                  offset: Offset.zero,
                ),
              ],
            )
          : Icon(
              Icons.signal_wifi_statusbar_connected_no_internet_4,
              size: size,
              color: color ?? themeColors.reversedText,
            );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
      decoration: BoxDecoration(
        color: themeColors.alertBackground,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.signal_wifi_statusbar_connected_no_internet_4,
            size: size,
            color: themeColors.reversedText,
          ),
          const SizedBox(width: 4),
          if (participant != null)
            Text(
              networkText(context),
              style: TextStyle(
                color: themeColors.reversedText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  String networkText(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (participant == null) {
      return t.unstableNetwork;
    } else if (participant!.me) {
      return t.unstableNetworkYou;
    } else {
      return t.unstableNetworkUser(participant!.name);
    }
  }
}
