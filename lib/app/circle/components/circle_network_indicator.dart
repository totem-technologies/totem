import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class CircleNetworkUnstable extends StatelessWidget {
  const CircleNetworkUnstable({Key? key, this.participant}) : super(key: key);
  final SessionParticipant? participant;

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    if (participant == null) {
      return Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: themeColors.alertBackground,
        ),
        child: SvgPicture.asset(
          "assets/wifi.svg",
        ),
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
          SvgPicture.asset(
            "assets/wifi.svg",
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
