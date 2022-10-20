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
}
