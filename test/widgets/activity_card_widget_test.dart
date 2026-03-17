import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportus/core/theme/app_theme.dart';
import 'package:sportus/data/models/activity_model.dart';
import 'package:sportus/features/activity_list/widgets/activity_card.dart';

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
  group('ActivityCard', () {
    testWidgets('renders title, location, participant count in light mode',
        (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(ActivityCard(activity: _sampleActivity())),
      );

      expect(find.text('Sunday Football'), findsOneWidget);
      expect(find.text('Central Park'), findsOneWidget);
      expect(find.text('2/10'), findsOneWidget);
    });

    testWidgets('renders correctly in dark mode', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(
          ActivityCard(activity: _sampleActivity()),
          dark: true,
        ),
      );

      expect(find.text('Sunday Football'), findsOneWidget);
      expect(find.text('Central Park'), findsOneWidget);
    });

    testWidgets('displays sport icon', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(ActivityCard(activity: _sampleActivity())),
      );

      // Football uses Icons.sports_soccer
      expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
    });
  });
}
