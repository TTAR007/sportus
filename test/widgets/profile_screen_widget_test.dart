import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportus/core/theme/app_theme.dart';
import 'package:sportus/features/profile/profile_screen.dart';
import 'package:sportus/providers/auth_provider.dart';

Widget _pumpNullUser({bool dark = false}) {
  return ProviderScope(
    overrides: [
      currentUserProvider.overrideWithValue(null),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: const ProfileScreen(),
    ),
  );
}

void main() {
  group('ProfileScreen', () {
    testWidgets('shows "Not signed in" when user is null', (tester) async {
      await tester.pumpWidget(_pumpNullUser());
      await tester.pumpAndSettle();

      expect(find.text('Not signed in.'), findsOneWidget);
      expect(find.text('My Profile'), findsOneWidget);
    });

    testWidgets('shows "Not signed in" in dark mode', (tester) async {
      await tester.pumpWidget(_pumpNullUser(dark: true));
      await tester.pumpAndSettle();

      expect(find.text('Not signed in.'), findsOneWidget);
    });

    testWidgets('shows AppBar title', (tester) async {
      await tester.pumpWidget(_pumpNullUser());
      await tester.pump();

      expect(find.text('My Profile'), findsOneWidget);
    });

    testWidgets('shows back button with correct tooltip', (tester) async {
      await tester.pumpWidget(_pumpNullUser());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);
    });

    testWidgets('back button exists in dark mode', (tester) async {
      await tester.pumpWidget(_pumpNullUser(dark: true));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('shows person_off icon in not-signed-in state',
        (tester) async {
      await tester.pumpWidget(_pumpNullUser());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_off_outlined), findsOneWidget);
    });

    testWidgets('shows person_off icon in dark mode', (tester) async {
      await tester.pumpWidget(_pumpNullUser(dark: true));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_off_outlined), findsOneWidget);
    });
  });
}
