import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import 'date_name_ext.dart';

enum RecurringType {
  none,
  instances,
  repeating,
}

enum RepeatUnit {
  hours,
  days,
  weeks,
  months,
}

class RepeatOptions {
  late final DateTime start;
  late final int every;
  late final RepeatUnit unit;
  DateTime? until;
  int? count;

  RepeatOptions(
      {required this.start,
      required this.every,
      required this.unit,
      this.until,
      this.count});

  RepeatOptions.fromJson(Map<String, dynamic> json) {
    start = DateTimeEx.fromMapValue(json['start']) ?? DateTime.now();
    every = json['every'] ?? 1;
    unit = RepeatUnit.values.byName(json['unit']);
    until = DateTimeEx.fromMapValue(json['until']);
    count = json['count'];
  }

  String toLocalizedString(final AppLocalizations t) {
    String repeatSingleUnit = "";
    String repeatPluralUnit = "";
    switch (unit) {
      case RepeatUnit.hours:
        repeatSingleUnit = t.hour;
        repeatPluralUnit = t.hours;
        break;
      case RepeatUnit.weeks:
        repeatSingleUnit = t.week;
        repeatPluralUnit = t.weeks;
        break;
      case RepeatUnit.months:
        repeatSingleUnit = t.month;
        repeatPluralUnit = t.months;
        break;
      case RepeatUnit.days:
        repeatSingleUnit = t.day;
        repeatPluralUnit = t.days;
        break;
    }
    if ((count ?? 0) > 0) {
      return t.repeatsEveryFor(
          t.repeatEveryClause(every, repeatSingleUnit.toLowerCase(),
              repeatPluralUnit.toLowerCase()),
          t.repeatEveryForClause(count!));
    } else if (until != null) {
      return t.repeatsEveryFor(
          t.repeatEveryClause(every, repeatSingleUnit.toLowerCase(),
              repeatPluralUnit.toLowerCase()),
          t.repeatsUntilDateClause(DateFormat.yMMMMEEEEd().format(until!)));
    } else {
      return t.repeatEveryClause(every, repeatSingleUnit.toLowerCase(),
          repeatPluralUnit.toLowerCase());
    }
  }
}
