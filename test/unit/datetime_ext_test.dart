import 'package:flutter_test/flutter_test.dart';
import 'package:sportus/core/extensions/datetime_ext.dart';

void main() {
  group('DateTimeExt.toDateString', () {
    test('formats a known date correctly', () {
      // 2026-03-17 is a Tuesday
      final date = DateTime(2026, 3, 17);
      expect(date.toDateString(), 'Tue, Mar 17');
    });

    test('formats January 1 correctly', () {
      // 2026-01-01 is a Thursday
      final date = DateTime(2026, 1, 1);
      expect(date.toDateString(), 'Thu, Jan 1');
    });

    test('formats December 31 correctly', () {
      // 2025-12-31 is a Wednesday
      final date = DateTime(2025, 12, 31);
      expect(date.toDateString(), 'Wed, Dec 31');
    });
  });

  group('DateTimeExt.toTimeString', () {
    test('formats afternoon time', () {
      final date = DateTime(2026, 1, 1, 15, 0);
      expect(date.toTimeString(), '3:00 PM');
    });

    test('formats morning time', () {
      final date = DateTime(2026, 1, 1, 9, 30);
      expect(date.toTimeString(), '9:30 AM');
    });

    test('formats noon as 12:00 PM', () {
      final date = DateTime(2026, 1, 1, 12, 0);
      expect(date.toTimeString(), '12:00 PM');
    });

    test('formats midnight as 12:00 AM', () {
      final date = DateTime(2026, 1, 1, 0, 0);
      expect(date.toTimeString(), '12:00 AM');
    });

    test('pads minutes with zero', () {
      final date = DateTime(2026, 1, 1, 14, 5);
      expect(date.toTimeString(), '2:05 PM');
    });
  });

  group('DateTimeExt.toDateTimeString', () {
    test('combines date and time', () {
      final date = DateTime(2026, 3, 17, 15, 0);
      expect(date.toDateTimeString(), 'Tue, Mar 17 at 3:00 PM');
    });
  });

  group('DateTimeExt.toTimeOfDay', () {
    test('extracts hour and minute', () {
      final date = DateTime(2026, 1, 1, 14, 30);
      final tod = date.toTimeOfDay();
      expect(tod.hour, 14);
      expect(tod.minute, 30);
    });
  });
}
