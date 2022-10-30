import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'repeat_options.dart';

class CircleRecurringOption {
  final RecurringType type;
  CircleRecurringOption({required this.type});

  String getName(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    switch (type) {
      case RecurringType.none:
        return t.instantSession;
      case RecurringType.repeating:
        return t.repeatingSession;
      case RecurringType.instances:
        return t.scheduledSessions;
      default:
        return '';
    }
  }
}
