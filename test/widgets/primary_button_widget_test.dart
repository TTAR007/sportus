import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportus/core/theme/app_theme.dart';
import 'package:sportus/shared/widgets/primary_button.dart';

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
  group('PrimaryButton', () {
    testWidgets('renders label in light mode', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(PrimaryButton(label: 'Submit', onPressed: () {})),
      );
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('renders label in dark mode', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(
          PrimaryButton(label: 'Submit', onPressed: () {}),
          dark: true,
        ),
      );
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('fires callback on tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        pumpWithTheme(
          PrimaryButton(label: 'Go', onPressed: () => tapped = true),
        ),
      );
      await tester.tap(find.text('Go'));
      expect(tapped, isTrue);
    });

    testWidgets('shows loading indicator and disables tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        pumpWithTheme(
          PrimaryButton(
            label: 'Go',
            onPressed: () => tapped = true,
            isLoading: true,
          ),
        ),
      );
      // Label is hidden when loading
      expect(find.text('Go'), findsNothing);
      // Progress indicator is visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Tap does nothing
      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isFalse);
    });
  });
}
