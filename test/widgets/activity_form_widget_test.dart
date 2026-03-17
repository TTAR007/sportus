import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportus/core/constants/sport_types.dart';
import 'package:sportus/core/theme/app_theme.dart';
import 'package:sportus/features/activity_form/activity_form_screen.dart';
import 'package:sportus/features/activity_form/widgets/datetime_field.dart';
import 'package:sportus/features/activity_form/widgets/sport_type_selector.dart';

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

void main() {
  group('ActivityFormScreen (create mode)', () {
    testWidgets('renders form fields in light mode', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(const ActivityFormScreen()),
      );

      expect(find.text('New Activity'), findsOneWidget);
      expect(find.text('Sport Type'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.byType(SportTypeSelector), findsOneWidget);
      expect(find.byType(DateTimeField), findsOneWidget);
      expect(find.text('Create Activity'), findsOneWidget);
    });

    testWidgets('renders form fields in dark mode', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(const ActivityFormScreen(), dark: true),
      );

      expect(find.text('New Activity'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.text('Create Activity'), findsOneWidget);
    });

    testWidgets('shows validation errors on empty submit', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(const ActivityFormScreen()),
      );

      // Ensure the button is visible by scrolling
      await tester.ensureVisible(find.text('Create Activity'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Activity'));
      await tester.pumpAndSettle();

      // Title and Location are required
      expect(find.text('Title is required.'), findsOneWidget);
      expect(find.text('Location is required.'), findsOneWidget);
      expect(find.text('Max participants is required.'), findsOneWidget);
      expect(find.text('Date and time is required.'), findsOneWidget);
    });

    testWidgets('title field validates max length', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(const ActivityFormScreen()),
      );

      // Enter title > 80 chars — use the first TextFormField (Title)
      await tester.enterText(
        find.byType(TextFormField).first,
        'A' * 81,
      );

      // Ensure button is visible and tap submit
      await tester.ensureVisible(find.text('Create Activity'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Activity'));
      await tester.pumpAndSettle();

      expect(
        find.text('Title must be at most 80 characters.'),
        findsOneWidget,
      );
    });
  });

  group('SportTypeSelector', () {
    testWidgets('renders all sport types in light mode', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(
          SportTypeSelector(
            selected: SportType.football,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Football'), findsOneWidget);
      expect(find.text('Basketball'), findsOneWidget);
      expect(find.text('Tennis'), findsOneWidget);
      expect(find.text('Running'), findsOneWidget);
      expect(find.text('Badminton'), findsOneWidget);
      expect(find.text('Volleyball'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
    });

    testWidgets('renders correctly in dark mode', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(
          SportTypeSelector(
            selected: SportType.tennis,
            onChanged: (_) {},
          ),
          dark: true,
        ),
      );

      expect(find.text('Tennis'), findsOneWidget);
      expect(find.text('Football'), findsOneWidget);
    });

    testWidgets('calls onChanged when a chip is tapped', (tester) async {
      SportType? tapped;
      await tester.pumpWidget(
        pumpWithTheme(
          SportTypeSelector(
            selected: SportType.football,
            onChanged: (s) => tapped = s,
          ),
        ),
      );

      await tester.tap(find.text('Tennis'));
      expect(tapped, SportType.tennis);
    });
  });

  group('DateTimeField', () {
    testWidgets('shows placeholder when no value in light mode',
        (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(
          DateTimeField(value: null, onChanged: (_) {}),
        ),
      );

      expect(find.text('Select date and time'), findsOneWidget);
      expect(find.text('Date & Time'), findsOneWidget);
    });

    testWidgets('renders correctly in dark mode', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(
          DateTimeField(value: null, onChanged: (_) {}),
          dark: true,
        ),
      );

      expect(find.text('Select date and time'), findsOneWidget);
    });

    testWidgets('displays formatted date when value is set', (tester) async {
      final date = DateTime(2026, 6, 15, 14, 30);
      await tester.pumpWidget(
        pumpWithTheme(
          DateTimeField(value: date, onChanged: (_) {}),
        ),
      );

      // Should show formatted date, not placeholder
      expect(find.text('Select date and time'), findsNothing);
    });

    testWidgets('shows error text when provided', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(
          DateTimeField(
            value: null,
            onChanged: (_) {},
            errorText: 'Date and time is required.',
          ),
        ),
      );

      expect(find.text('Date and time is required.'), findsOneWidget);
    });

    testWidgets('opens date picker on tap', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(
          DateTimeField(value: null, onChanged: (_) {}),
        ),
      );

      await tester.tap(find.text('Select date and time'));
      await tester.pumpAndSettle();

      // DatePicker dialog should appear
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });
  });
}
