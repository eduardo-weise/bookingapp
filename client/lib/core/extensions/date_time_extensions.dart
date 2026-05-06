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
}
