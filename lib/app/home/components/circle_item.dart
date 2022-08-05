import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class CircleItem extends StatelessWidget {
  const CircleItem({Key? key, required this.circle, required this.onPressed})
      : super(key: key);
  final ScheduledCircle circle;
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
                    Icon(
                      Icons.error_outline,
                      size: 24,
                      color: themeData.themeColors.error,
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
              Icon(Icons.arrow_forward,
                  size: 24, color: themeData.themeColors.iconNext),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sessionInfo(BuildContext context) {
    final timeFormat = DateFormat(" @ h:mm a");
    final t = AppLocalizations.of(context)!;
    ScheduledSession? session = circle.nextSession;
    switch (circle.state) {
      case SessionState.live:
        return Text(
          t.sessionInProgress,
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      case SessionState.waiting:
        return Text(
          t.sessionWaiting,
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      case SessionState.idle:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (session != null) ...[
              Text(
                  DateFormat.yMMMd().format(session.scheduledDate) +
                      timeFormat.format(session.scheduledDate),
                  style: const TextStyle(fontSize: 14)),
              const SizedBox(
                height: 4,
              ),
              Text(t.nextSession, style: const TextStyle(fontSize: 12)),
            ],
            if (session == null)
              Text(
                t.noUpcomingSessions,
                style: const TextStyle(fontSize: 12),
              ),
          ],
        );
      case SessionState.complete:
      default:
        return Text(t.sessionsCompleted);
    }
  }
}
