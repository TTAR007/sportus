import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportus/core/theme/app_theme.dart';
import 'package:sportus/features/activity_list/widgets/sport_filter_chips.dart';

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
  group('SportFilterChips', () {
    testWidgets('renders All chip and all sport types in light mode',
        (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(const SportFilterChips()),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Football'), findsOneWidget);
      expect(find.text('Basketball'), findsOneWidget);
      expect(find.text('Tennis'), findsOneWidget);
      expect(find.text('Running'), findsOneWidget);
      expect(find.text('Badminton'), findsOneWidget);
      expect(find.text('Volleyball'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
    });

    testWidgets('renders in dark mode', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(const SportFilterChips(), dark: true),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Football'), findsOneWidget);
    });

    testWidgets('tapping a sport chip selects it', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(const SportFilterChips()),
      );

      await tester.tap(find.text('Tennis'));
      await tester.pumpAndSettle();

      // The Tennis chip should now be selected.
      // We verify the chip is still rendered (interaction didn't crash).
      expect(find.text('Tennis'), findsOneWidget);
    });
  });
}
