import 'package:flutter/foundation.dart';

extension DateTimeEx on DateTime {
  static DateTime? fromMapValue(dynamic val) {
    if (val == null) {
      return null;
    }
    try {
      if (val is DateTime) {
        return val;
      } else if (val is int) {
        return DateTime.fromMillisecondsSinceEpoch(val);
      } else if (val is String) {
        return DateTime.parse(val);
      } else {
        return DateTime.parse(val.toDate().toString());
      }
    } catch (e, st) {
      debugPrint(e.toString());
      debugPrint(st.toString());
    }
    return null;
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
