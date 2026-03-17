import 'package:flutter/material.dart';

enum SportType {
  football,
  basketball,
  tennis,
  running,
  badminton,
  volleyball,
  other;

  String get displayLabel {
    switch (this) {
      case SportType.football:
        return 'Football';
      case SportType.basketball:
        return 'Basketball';
      case SportType.tennis:
        return 'Tennis';
      case SportType.running:
        return 'Running';
      case SportType.badminton:
        return 'Badminton';
      case SportType.volleyball:
        return 'Volleyball';
      case SportType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case SportType.football:
        return Icons.sports_soccer;
      case SportType.basketball:
        return Icons.sports_basketball;
      case SportType.tennis:
        return Icons.sports_tennis;
      case SportType.running:
        return Icons.directions_run;
      case SportType.badminton:
        return Icons.sports_tennis;
      case SportType.volleyball:
        return Icons.sports_volleyball;
      case SportType.other:
        return Icons.sports;
    }
  }
}
