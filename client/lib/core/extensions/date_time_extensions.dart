import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  /// Compares only the date part (year, month, day) of two DateTimes.
  /// Handles UTC/local timezone differences by converting both to UTC.
  bool isSameDateUtc(DateTime other) {
    final thisUtc = toUtc();
    final otherUtc = other.toUtc();
    return thisUtc.year == otherUtc.year &&
           thisUtc.month == otherUtc.month &&
           thisUtc.day == otherUtc.day;
  }

  /// Returns this value converted to local timezone for UI display.
  DateTime get localDateTime => toLocal();

  /// Formats this date using local timezone.
  String formatLocal(String pattern, {String locale = 'pt_BR'}) {
    return DateFormat(pattern, locale).format(localDateTime);
  }

  /// UI helper for short card date (e.g. "06 mai").
  String get displayDateShort => formatLocal('dd MMM');

  /// UI helper for time (e.g. "19:30").
  String get displayTime => formatLocal('HH:mm');

  /// UI helper for long date in today badge (e.g. "06 de maio").
  String get displayDateLong => formatLocal("dd 'de' MMMM");
}
