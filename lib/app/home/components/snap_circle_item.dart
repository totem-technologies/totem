import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:totem/theme/index.dart';

class SnapCircleItem extends StatelessWidget {
  const SnapCircleItem({
    Key? key,
    required this.circle,
    required this.onPressed,
  }) : super(key: key);
  final SnapCircle circle;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final textStyles = themeData.textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 8.0, horizontal: themeData.pageHorizontalPadding),
      child: InkWell(
        onTap: () {
          onPressed(circle);
        },
        child: ListItemContainer(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 24,
                      /*child: SvgPicture.asset(
                            'assets/alert.svg')*/ // FIXME - this is some indicator icon
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(circle.name, style: textStyles.headline3),
                          const SizedBox(height: 8),
                          _sessionInfo(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              SvgPicture.asset('assets/arrow_next.svg'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sessionInfo(BuildContext context) {
    final timeFormat = DateFormat.Hm();
    final t = AppLocalizations.of(context)!;
    String status = "";
    switch (circle.status) {
      case SessionState.live:
        status = t.sessionInProgress;
        break;
      case SessionState.waiting:
        status = t.sessionWaiting;
        break;
      default:
        break;
    }
    return Column(
      children: [
        Text(
          status,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          t.started + " : " + timeFormat.format(circle.createdOn),
        )
      ],
    );
  }
}
