import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:totem/models/repeat_options.dart';

class CircleRepeatUnitOption {
  final RepeatUnit? value;
  CircleRepeatUnitOption({required this.value});

  String getName(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    switch (value) {
      case RepeatUnit.hours:
        return t.hourly;
      case RepeatUnit.days:
        return t.daily;
      case RepeatUnit.weeks:
        return t.weekly;
      case RepeatUnit.months:
        return t.monthly;
      default:
        return t.never;
    }
  }

  String getUnitName(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    switch (value) {
      case RepeatUnit.hours:
        return t.hours;
      case RepeatUnit.days:
        return t.days;
      case RepeatUnit.weeks:
        return t.weeks;
      case RepeatUnit.months:
        return t.months;
      default:
        return '';
    }
  }
}
