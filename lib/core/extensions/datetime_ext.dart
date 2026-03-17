import 'package:flutter/material.dart';

extension DateTimeExt on DateTime {
  /// e.g. "Mon, Mar 17"
  String toDateString() {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${weekdays[weekday - 1]}, ${months[month - 1]} $day';
  }

  /// e.g. "3:00 PM"
  String toTimeString() {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  /// e.g. "Mon, Mar 17 at 3:00 PM"
  String toDateTimeString() {
    return '${toDateString()} at ${toTimeString()}';
  }

  /// Returns a [TimeOfDay] from this DateTime.
  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);
}
