import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:totem/theme/index.dart';

class NoCircles extends StatelessWidget {
  const NoCircles({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: themeData.pageHorizontalPadding,
        right: themeData.pageHorizontalPadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            t.ooh,
            style: themeData.textStyles.headline2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 16,
          ),
          SvgPicture.asset('assets/face.svg'),
          const SizedBox(
            height: 16,
          ),
          Text(
            t.noSnapCirclesMessage,
            style: TextStyle(
                color: themeData.themeColors.secondaryText, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
