import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Join / leave activity flow', () {
    testWidgets('User can join and then leave an activity', (tester) async {
      final fakeFirestore = FakeFirebaseFirestore();
      final futureDate = DateTime.now().add(const Duration(days: 7));

      // Seed an activity hosted by someone else
      await seedActivity(
        fakeFirestore,
        id: 'activity-1',
        title: 'Morning Basketball',
        dateTime: futureDate,
        location: 'City Gym',
        maxParticipants: 5,
        hostId: 'other-user',
        hostName: 'Jane Doe',
      );

      await tester.pumpWidget(buildTestApp(fakeFirestore: fakeFirestore));
      await tester.pumpAndSettle();

      // ── List screen: activity is visible ──────────────────────────────
      expect(find.text('Morning Basketball'), findsOneWidget);

      // ── Navigate to detail ────────────────────────────────────────────
      await tester.tap(find.text('Morning Basketball'));
      await tester.pumpAndSettle();

      // Verify detail content
      expect(find.text('Morning Basketball'), findsOneWidget);
      expect(find.text('City Gym'), findsOneWidget);
      expect(find.text('Hosted by Jane Doe'), findsOneWidget);
      expect(find.text('0 / 5 participants'), findsOneWidget);

      // ── Join the activity ─────────────────────────────────────────────
      await tester.ensureVisible(find.text('Join Activity'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Join Activity'));
      await tester.pumpAndSettle();

      // Verify participant count increased
      expect(find.text('1 / 5 participants'), findsOneWidget);
      // Verify joined indicator
      expect(find.text("You've joined this activity!"), findsOneWidget);

      // ── Leave the activity ────────────────────────────────────────────
      await tester.ensureVisible(find.text('Leave Activity'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Leave Activity'));
      await tester.pumpAndSettle();

      // Verify participant count reverted
      expect(find.text('0 / 5 participants'), findsOneWidget);
      // Verify joined indicator gone
      expect(find.text("You've joined this activity!"), findsNothing);
    });

    testWidgets('Join button is disabled when activity is full',
        (tester) async {
      final fakeFirestore = FakeFirebaseFirestore();
      final futureDate = DateTime.now().add(const Duration(days: 7));

      // Seed a full activity (2/2 participants)
      await seedActivity(
        fakeFirestore,
        id: 'activity-full',
        title: 'Full Yoga Class',
        dateTime: futureDate,
        location: 'Yoga Studio',
        maxParticipants: 2,
        hostId: 'other-user',
        hostName: 'Jane Doe',
        participantIds: ['user-a', 'user-b'],
        currentParticipants: 2,
      );

      await tester.pumpWidget(buildTestApp(fakeFirestore: fakeFirestore));
      await tester.pumpAndSettle();

      // Navigate to detail
      await tester.tap(find.text('Full Yoga Class'));
      await tester.pumpAndSettle();

      // Verify full state
      expect(find.text('2 / 2 participants'), findsOneWidget);
      expect(find.text('Activity Full'), findsOneWidget);
    });
  });
}
