import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CircleDurationOption {
  final int value;
  CircleDurationOption({required this.value});

  String getName(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    int hrs = value ~/ 60;
    int mins = value % 60;
    if (hrs == 0) {
      return t.minsValue(mins);
    } else if (mins == 0) {
      if (hrs == 1) {
        return t.hourOne;
      } else {
        return t.hoursValue(hrs);
      }
    } else {
      if (mins == 30) {
        return t.hoursAndHalfValue(hrs);
      } else if (hrs == 1) {
        return t.hourOneAndMinsValue(mins);
      }
      return t.hoursAndMinsValue(hrs, mins);
    }
  }
}
