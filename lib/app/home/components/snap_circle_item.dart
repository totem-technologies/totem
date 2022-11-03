import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class SnapCircleItem extends StatelessWidget {
  static const double maxFullInfoWidth = 250;
  const SnapCircleItem({
    Key? key,
    required this.circle,
    required this.onPressed,
  }) : super(key: key);
  final Circle circle;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final themeData = Theme.of(context);
    final themeColor = Theme.of(context).themeColors;
    final textStyles = themeData.textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 8.0, horizontal: themeData.pageHorizontalPadding),
      child: InkWell(
        hoverColor: Colors.transparent,
        onTap: () {
          onPressed(circle);
        },
        child: ListItemContainer(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: circle.description != null &&
                              circle.description!.isNotEmpty
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: CircleImage(
                            circle: circle,
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 2),
                              Text(
                                circle.name,
                                style: textStyles.headline3,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              if (circle.description != null &&
                                  circle.description!.isNotEmpty) ...[
                                Text(
                                  circle.description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                              ],
                              if (circle.createdBy != null) ...[
                                Text(
                                  t.createdBy(circle.createdBy!.name),
                                  style: TextStyle(
                                      color: themeColor.primaryText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _sessionInfo(context),
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Icon(LucideIcons.arrowRight,
                  size: 24, color: themeData.themeColors.iconNext),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sessionInfo(BuildContext context) {
    //final timeFormat = DateFormat.Hm();
    final t = AppLocalizations.of(context)!;
    String status = "";
    switch (circle.state) {
      case SessionState.live:
        status = t.sessionInProgress;
        break;
      case SessionState.waiting:
        status = t.sessionWaiting;
        break;
      default:
        break;
    }
    final themeColor = Theme.of(context).themeColors;
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(
            height: 5,
            thickness: 1,
            color: themeColor.divider,
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Text(
                t.participantCount(circle.participantCount),
              ),
              Expanded(
                child: constraints.maxWidth > maxFullInfoWidth
                    ? Text(
                        status,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                        textAlign: TextAlign.end,
                      )
                    : Container(),
              ),
            ],
          ),
        ],
      );
    });
  }
}
