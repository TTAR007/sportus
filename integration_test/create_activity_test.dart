import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Create activity flow', () {
    testWidgets('User can create an activity and see it in the list',
        (tester) async {
      final fakeFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(buildTestApp(fakeFirestore: fakeFirestore));
      await tester.pumpAndSettle();

      // ── List screen: empty state ──────────────────────────────────────
      expect(find.textContaining('No activities yet'), findsOneWidget);

      // ── Navigate to create form via FAB ───────────────────────────────
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify we're on the create form
      expect(find.text('New Activity'), findsOneWidget);

      // ── Fill in form fields ───────────────────────────────────────────

      // Title
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Sunday Football',
      );

      // Location
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Location'),
        'Central Park',
      );

      // Max participants
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Max Participants'),
        '10',
      );

      // ── Pick date & time ──────────────────────────────────────────────

      // Tap the date/time field to open the DatePicker
      await tester.tap(find.text('Select date and time'));
      await tester.pumpAndSettle();

      // Accept the default date (tomorrow) by tapping OK
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Accept the default time (18:00) by tapping OK
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // ── Submit the form ───────────────────────────────────────────────

      await tester.ensureVisible(find.text('Create Activity'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Activity'));
      await tester.pumpAndSettle();

      // ── Verify activity appears in the list ───────────────────────────

      expect(find.text('Sunday Football'), findsOneWidget);
      expect(find.text('Central Park'), findsOneWidget);
    });

    testWidgets('Form shows validation errors when submitted empty',
        (tester) async {
      final fakeFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(buildTestApp(fakeFirestore: fakeFirestore));
      await tester.pumpAndSettle();

      // Navigate to create form
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Scroll to and tap submit without filling anything
      await tester.ensureVisible(find.text('Create Activity'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Activity'));
      await tester.pumpAndSettle();

      // Verify validation errors appear
      expect(find.text('Title is required.'), findsOneWidget);
      expect(find.text('Location is required.'), findsOneWidget);
      expect(find.text('Date and time is required.'), findsOneWidget);
    });
  });
}
