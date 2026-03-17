import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportus/core/constants/sport_types.dart';

void main() {
  group('SportType', () {
    test('has 7 values', () {
      expect(SportType.values.length, 7);
    });

    test('each value has a non-empty displayLabel', () {
      for (final type in SportType.values) {
        expect(type.displayLabel, isNotEmpty);
      }
    });

    test('each value has an icon', () {
      for (final type in SportType.values) {
        expect(type.icon, isA<IconData>());
      }
    });

    test('displayLabel returns correct values', () {
      expect(SportType.football.displayLabel, 'Football');
      expect(SportType.basketball.displayLabel, 'Basketball');
      expect(SportType.tennis.displayLabel, 'Tennis');
      expect(SportType.running.displayLabel, 'Running');
      expect(SportType.badminton.displayLabel, 'Badminton');
      expect(SportType.volleyball.displayLabel, 'Volleyball');
      expect(SportType.other.displayLabel, 'Other');
    });

    test('icon returns correct values', () {
      expect(SportType.football.icon, Icons.sports_soccer);
      expect(SportType.basketball.icon, Icons.sports_basketball);
      expect(SportType.running.icon, Icons.directions_run);
      expect(SportType.volleyball.icon, Icons.sports_volleyball);
    });
  });
}
