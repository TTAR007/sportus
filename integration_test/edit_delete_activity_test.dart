import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Edit activity flow', () {
    testWidgets('Host can edit an activity and see updated data',
        (tester) async {
      final fakeFirestore = FakeFirebaseFirestore();
      final futureDate = DateTime.now().add(const Duration(days: 7));

      // Seed an activity hosted by the test user
      await seedActivity(
        fakeFirestore,
        id: 'activity-1',
        title: 'Evening Tennis',
        dateTime: futureDate,
        location: 'Tennis Court',
        maxParticipants: 4,
        hostId: 'test-user-id',
        hostName: 'Test User',
      );

      await tester.pumpWidget(buildTestApp(fakeFirestore: fakeFirestore));
      await tester.pumpAndSettle();

      // ── Navigate to detail ────────────────────────────────────────────
      await tester.tap(find.text('Evening Tennis'));
      await tester.pumpAndSettle();

      // Verify host actions are visible
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // ── Tap Edit ──────────────────────────────────────────────────────
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Verify edit form with pre-filled title
      expect(find.text('Edit Activity'), findsOneWidget);

      // ── Change the title ──────────────────────────────────────────────
      final titleField = find.widgetWithText(TextFormField, 'Title');
      await tester.enterText(titleField, 'Morning Tennis');
      await tester.pumpAndSettle();

      // ── Save changes ──────────────────────────────────────────────────
      await tester.ensureVisible(find.text('Save Changes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      // ── Verify updated data on detail screen ──────────────────────────
      expect(find.text('Morning Tennis'), findsOneWidget);
      expect(find.text('Evening Tennis'), findsNothing);
    });
  });

  group('Delete activity flow', () {
    testWidgets('Host can delete an activity after confirmation',
        (tester) async {
      final fakeFirestore = FakeFirebaseFirestore();
      final futureDate = DateTime.now().add(const Duration(days: 7));

      // Seed an activity hosted by the test user
      await seedActivity(
        fakeFirestore,
        id: 'activity-2',
        title: 'Saturday Volleyball',
        dateTime: futureDate,
        location: 'Beach Court',
        maxParticipants: 12,
        hostId: 'test-user-id',
        hostName: 'Test User',
      );

      await tester.pumpWidget(buildTestApp(fakeFirestore: fakeFirestore));
      await tester.pumpAndSettle();

      // ── Navigate to detail ────────────────────────────────────────────
      await tester.tap(find.text('Saturday Volleyball'));
      await tester.pumpAndSettle();

      // ── Tap Delete ────────────────────────────────────────────────────
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // ── Confirmation dialog is shown ──────────────────────────────────
      expect(find.text('Cancel Activity'), findsOneWidget);
      expect(
        find.text('Are you sure you want to cancel this activity?'),
        findsOneWidget,
      );

      // ── Confirm deletion ──────────────────────────────────────────────
      await tester.tap(find.text('Yes, cancel'));
      await tester.pumpAndSettle();

      // ── Verify redirected to list and activity is gone ────────────────
      expect(find.text('Saturday Volleyball'), findsNothing);
    });

    testWidgets('Host can dismiss delete confirmation dialog', (tester) async {
      final fakeFirestore = FakeFirebaseFirestore();
      final futureDate = DateTime.now().add(const Duration(days: 7));

      await seedActivity(
        fakeFirestore,
        id: 'activity-3',
        title: 'Sunday Running',
        dateTime: futureDate,
        location: 'City Park',
        maxParticipants: 20,
        hostId: 'test-user-id',
        hostName: 'Test User',
      );

      await tester.pumpWidget(buildTestApp(fakeFirestore: fakeFirestore));
      await tester.pumpAndSettle();

      // Navigate to detail
      await tester.tap(find.text('Sunday Running'));
      await tester.pumpAndSettle();

      // Tap Delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Dismiss by tapping No
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      // Verify still on detail screen — activity not deleted
      expect(find.text('Sunday Running'), findsOneWidget);
      expect(find.text('Cancel Activity'), findsNothing);
    });
  });
}
