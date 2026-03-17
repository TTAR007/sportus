import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportus/core/theme/app_theme.dart';
import 'package:sportus/shared/widgets/empty_state.dart';

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
  group('EmptyState', () {
    testWidgets('renders message in light mode', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(const EmptyState(message: 'No items')),
      );
      expect(find.text('No items'), findsOneWidget);
    });

    testWidgets('renders message in dark mode', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(
          const EmptyState(message: 'No items'),
          dark: true,
        ),
      );
      expect(find.text('No items'), findsOneWidget);
    });

    testWidgets('shows icon when provided', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(
          const EmptyState(message: 'Empty', icon: Icons.inbox),
        ),
      );
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('shows action button when actionLabel provided',
        (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(
          EmptyState(
            message: 'Empty',
            actionLabel: 'Create',
            onAction: () {},
          ),
        ),
      );
      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('hides action button when actionLabel is null',
        (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(const EmptyState(message: 'Empty')),
      );
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('action button fires callback', (tester) async {
      var fired = false;
      await tester.pumpWidget(
        pumpWithTheme(
          EmptyState(
            message: 'Empty',
            actionLabel: 'Retry',
            onAction: () => fired = true,
          ),
        ),
      );
      await tester.tap(find.text('Retry'));
      expect(fired, isTrue);
    });
  });
}
