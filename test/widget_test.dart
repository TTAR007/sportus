import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportus/core/theme/app_theme.dart';

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
  testWidgets('smoke test — app renders in light mode', (tester) async {
    await tester.pumpWidget(
      pumpWithTheme(const Center(child: Text('Sportus'))),
    );
    expect(find.text('Sportus'), findsOneWidget);
  });

  testWidgets('smoke test — app renders in dark mode', (tester) async {
    await tester.pumpWidget(
      pumpWithTheme(const Center(child: Text('Sportus')), dark: true),
    );
    expect(find.text('Sportus'), findsOneWidget);
  });
}
