import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CircleRepeatEndOption {
  final String value;
  CircleRepeatEndOption({required this.value});

  String getName(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    switch (value) {
      case 'endDate':
        return t.endDate;
      case 'numberOfSessions':
        return t.numberOfSessions;
      default:
        return value;
    }
  }
}
