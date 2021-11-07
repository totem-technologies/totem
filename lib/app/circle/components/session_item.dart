import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/app_theme_styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SessionItem extends StatelessWidget {
  const SessionItem(
      {Key? key,
      required this.session,
      required this.role,
      this.startSession,
      this.nextSession = false})
      : super(key: key);
  final Session session;
  final Role role;
  final bool nextSession;
  final Function? startSession;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();
    final timeFormat = DateFormat("h:mm a");
    final textStyles = Theme.of(context).textStyles;
    final t = AppLocalizations.of(context)!;
    return ListItemContainer(
      child: Row(
        children: [
          Expanded(
            child: Text(
              dateFormat.format(session.scheduledDate) +
                  " @ " +
                  timeFormat.format(session.scheduledDate),
              style: textStyles.headline4,
            ),
          ),
          // This is temporary for testing !
          // allow the keeper to start a session -
          // eventually this should be automated by the backend
          if (role == Roles.keeper && nextSession)
            TextButton(
              onPressed: () {
                if (startSession != null) {
                  startSession!(session);
                }
              },
              child: Text(t.startSession),
            )
        ],
      ),
    );
  }
}
