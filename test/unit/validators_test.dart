import 'package:flutter_test/flutter_test.dart';
import 'package:sportus/core/utils/validators.dart';

void main() {
  group('Validators.validateTitle', () {
    test('returns error for null', () {
      expect(Validators.validateTitle(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.validateTitle(''), isNotNull);
    });

    test('returns error for whitespace only', () {
      expect(Validators.validateTitle('   '), isNotNull);
    });

    test('returns error for > 80 chars', () {
      final longTitle = 'a' * 81;
      expect(Validators.validateTitle(longTitle), isNotNull);
    });

    test('returns null for valid title', () {
      expect(Validators.validateTitle('Football game'), isNull);
    });

    test('returns null for exactly 80 chars', () {
      final title = 'a' * 80;
      expect(Validators.validateTitle(title), isNull);
    });
  });

  group('Validators.validateLocation', () {
    test('returns error for null', () {
      expect(Validators.validateLocation(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.validateLocation(''), isNotNull);
    });

    test('returns error for > 200 chars', () {
      final longLocation = 'a' * 201;
      expect(Validators.validateLocation(longLocation), isNotNull);
    });

    test('returns null for valid location', () {
      expect(Validators.validateLocation('Central Park'), isNull);
    });

    test('returns null for exactly 200 chars', () {
      final location = 'a' * 200;
      expect(Validators.validateLocation(location), isNull);
    });
  });

  group('Validators.validateDescription', () {
    test('returns null for null (optional)', () {
      expect(Validators.validateDescription(null), isNull);
    });

    test('returns null for empty string (optional)', () {
      expect(Validators.validateDescription(''), isNull);
    });

    test('returns error for > 500 chars', () {
      final longDesc = 'a' * 501;
      expect(Validators.validateDescription(longDesc), isNotNull);
    });

    test('returns null for valid description', () {
      expect(Validators.validateDescription('A fun game'), isNull);
    });

    test('returns null for exactly 500 chars', () {
      final desc = 'a' * 500;
      expect(Validators.validateDescription(desc), isNull);
    });
  });

  group('Validators.validateMaxParticipants', () {
    test('returns error for null', () {
      expect(Validators.validateMaxParticipants(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.validateMaxParticipants(''), isNotNull);
    });

    test('returns error for non-numeric', () {
      expect(Validators.validateMaxParticipants('abc'), isNotNull);
    });

    test('returns error for < 2', () {
      expect(Validators.validateMaxParticipants('1'), isNotNull);
    });

    test('returns error for > 100', () {
      expect(Validators.validateMaxParticipants('101'), isNotNull);
    });

    test('returns null for 2', () {
      expect(Validators.validateMaxParticipants('2'), isNull);
    });

    test('returns null for 100', () {
      expect(Validators.validateMaxParticipants('100'), isNull);
    });

    test('returns null for 50', () {
      expect(Validators.validateMaxParticipants('50'), isNull);
    });
  });

  group('Validators.validateFutureDate', () {
    test('returns error for null', () {
      expect(Validators.validateFutureDate(null), isNotNull);
    });

    test('returns error for past date', () {
      final past = DateTime.now().subtract(const Duration(days: 1));
      expect(Validators.validateFutureDate(past), isNotNull);
    });

    test('returns null for future date', () {
      final future = DateTime.now().add(const Duration(days: 1));
      expect(Validators.validateFutureDate(future), isNull);
    });
  });
}
