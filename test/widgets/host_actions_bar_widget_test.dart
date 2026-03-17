import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportus/core/theme/app_theme.dart';
import 'package:sportus/features/activity_detail/widgets/host_actions_bar.dart';

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
  group('HostActionsBar', () {
    testWidgets('renders Edit and Delete buttons in light mode',
        (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(const HostActionsBar(activityId: 'test-id')),
      );

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('renders correctly in dark mode', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(
          const HostActionsBar(activityId: 'test-id'),
          dark: true,
        ),
      );

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('shows edit and delete icons', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(const HostActionsBar(activityId: 'test-id')),
      );

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('tapping Delete shows confirmation dialog', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(const HostActionsBar(activityId: 'test-id')),
      );

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel Activity'), findsOneWidget);
      expect(
        find.text('Are you sure you want to cancel this activity?'),
        findsOneWidget,
      );
      expect(find.text('No'), findsOneWidget);
      expect(find.text('Yes, cancel'), findsOneWidget);
    });

    testWidgets('dismissing confirmation dialog does not navigate',
        (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(const HostActionsBar(activityId: 'test-id')),
      );

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Tap "No" to dismiss
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      // Dialog should be dismissed, buttons still visible
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });
  });
}
