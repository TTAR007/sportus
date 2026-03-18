import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportus/core/theme/app_theme.dart';
import 'package:sportus/data/models/activity_model.dart';
import 'package:sportus/features/profile/widgets/profile_activity_card.dart';

Widget pumpWithTheme(Widget child, {bool dark = false}) {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(body: child),
    ),
  );
}

ActivityModel _sampleActivity() => ActivityModel(
      id: 'test-id',
      title: 'Sunday Football',
      sportType: 'football',
      dateTime: DateTime(2026, 4, 1, 15, 0),
      location: 'Central Park',
      maxParticipants: 10,
      description: 'A fun game',
      hostId: 'host1',
      hostName: 'Alice',
      participantIds: const ['host1', 'u2'],
      currentParticipants: 2,
      createdAt: DateTime(2026, 3, 17),
      updatedAt: DateTime(2026, 3, 17),
    );

void main() {
  group('ProfileActivityCard', () {
    testWidgets('renders title, date, and badge in light mode', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(
          ProfileActivityCard(activity: _sampleActivity(), badge: 'Host'),
        ),
      );

      expect(find.text('Sunday Football'), findsOneWidget);
      expect(find.text('Host'), findsOneWidget);
      // Sport icon for football
      expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
    });

    testWidgets('renders correctly in dark mode', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(
          ProfileActivityCard(activity: _sampleActivity(), badge: 'Joined'),
          dark: true,
        ),
      );

      expect(find.text('Sunday Football'), findsOneWidget);
      expect(find.text('Joined'), findsOneWidget);
      expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
    });

    testWidgets('displays correct badge text', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(
          ProfileActivityCard(activity: _sampleActivity(), badge: 'Joined'),
        ),
      );

      expect(find.text('Joined'), findsOneWidget);
    });

    testWidgets('displays formatted date', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(
          ProfileActivityCard(activity: _sampleActivity(), badge: 'Host'),
        ),
      );

      // DateTime(2026, 4, 1, 15, 0) → "Wed, Apr 1 at 3:00 PM"
      expect(find.text('Wed, Apr 1 at 3:00 PM'), findsOneWidget);
    });

    testWidgets('uses other icon for unknown sport type', (tester) async {
      final activity = _sampleActivity().copyWith(sportType: 'unknown_sport');

      await tester.pumpWidget(
        pumpWithTheme(
          ProfileActivityCard(activity: activity, badge: 'Host'),
        ),
      );

      // Falls back to SportType.other → Icons.sports
      expect(find.byIcon(Icons.sports), findsOneWidget);
    });
  });
}
