import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sportus/core/theme/app_theme.dart';
import 'package:sportus/shared/widgets/shimmer_card.dart';

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
  group('ShimmerCard', () {
    testWidgets('renders Shimmer widget in light mode', (tester) async {
      await tester.pumpWidget(pumpWithTheme(const ShimmerCard()));
      expect(find.byType(Shimmer), findsOneWidget);
    });

    testWidgets('renders Shimmer widget in dark mode', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(const ShimmerCard(), dark: true),
      );
      expect(find.byType(Shimmer), findsOneWidget);
    });

    testWidgets('renders correct count of cards', (tester) async {
      await tester.pumpWidget(
        pumpWithTheme(const ShimmerCard(count: 3)),
      );
      expect(find.byType(Shimmer), findsNWidgets(3));
    });
  });
}
