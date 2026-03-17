import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportus/core/theme/app_theme.dart';
import 'package:sportus/features/activity_detail/widgets/participant_count_bar.dart';

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
  group('ParticipantCountBar', () {
    testWidgets('renders participant count text in light mode', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(
          const ParticipantCountBar(current: 3, max: 10),
        ),
      );

      expect(find.text('3 / 10 participants'), findsOneWidget);
    });

    testWidgets('renders correctly in dark mode', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(
          const ParticipantCountBar(current: 3, max: 10),
          dark: true,
        ),
      );

      expect(find.text('3 / 10 participants'), findsOneWidget);
    });

    testWidgets('shows progress indicator', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(
          const ParticipantCountBar(current: 5, max: 10),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('displays full state when current equals max', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(
          const ParticipantCountBar(current: 10, max: 10),
        ),
      );

      expect(find.text('10 / 10 participants'), findsOneWidget);
    });

    testWidgets('has correct semantics label', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(
          const ParticipantCountBar(current: 4, max: 8),
        ),
      );

      // Find the Semantics widget that is a direct child of ParticipantCountBar
      final semantics = tester.widget<Semantics>(
        find.descendant(
          of: find.byType(ParticipantCountBar),
          matching: find.byType(Semantics),
        ).first,
      );
      expect(semantics.properties.label, '4 of 8 participants');
    });

    testWidgets('handles zero participants', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(
          const ParticipantCountBar(current: 0, max: 10),
        ),
      );

      expect(find.text('0 / 10 participants'), findsOneWidget);
    });
  });
}
