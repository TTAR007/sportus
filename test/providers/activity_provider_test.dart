import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportus/core/constants/sport_types.dart';
import 'package:sportus/data/repositories/activity_repository.dart';
import 'package:sportus/providers/activity_provider.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ActivityRepository repo;
  late ProviderContainer container;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repo = ActivityRepository(firestore: fakeFirestore);
    container = ProviderContainer.test(overrides: [
      activityRepositoryProvider.overrideWithValue(repo),
    ]);
  });

  Future<String> seedActivity({
    String sportType = 'football',
    String title = 'Test',
  }) async {
    final ref = fakeFirestore.collection('activities').doc();
    await ref.set({
      'title': title,
      'sportType': sportType,
      'dateTime': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 1)),
      ),
      'location': 'Park',
      'maxParticipants': 10,
      'description': null,
      'hostId': 'host1',
      'hostName': 'Host',
      'participantIds': <String>[],
      'currentParticipants': 0,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'deletedAt': null,
    });
    return ref.id;
  }

  group('sportFilterProvider', () {
    test('default is null', () {
      final filter = container.read(sportFilterProvider);
      expect(filter, isNull);
    });

    test('selecting a type updates state', () {
      container
          .read(sportFilterProvider.notifier)
          .select(SportType.tennis);
      expect(container.read(sportFilterProvider), SportType.tennis);
    });

    test('selecting null resets to all', () {
      container
          .read(sportFilterProvider.notifier)
          .select(SportType.football);
      container.read(sportFilterProvider.notifier).select(null);
      expect(container.read(sportFilterProvider), isNull);
    });
  });

  group('activityDetailProvider', () {
    test('returns model for existing activity', () async {
      final id = await seedActivity(title: 'Detail Test');

      final result = await container.read(
        activityDetailProvider(id).future,
      );
      expect(result.title, 'Detail Test');
      expect(result.id, id);
    });

    test('results in error for missing activity', () async {
      // Trigger the provider and wait for it to settle.
      container.listen(
        activityDetailProvider('missing'),
        (_, _) {},
        fireImmediately: true,
      );
      // Allow the future to complete.
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final asyncValue = container.read(activityDetailProvider('missing'));
      expect(asyncValue.hasError, isTrue);
    });
  });

  group('activityFormProvider', () {
    test('default state has isLoading false and no error', () {
      final formState = container.read(activityFormProvider);
      expect(formState.isLoading, isFalse);
      expect(formState.errorMessage, isNull);
    });

    test('createActivity returns Right and resets state', () async {
      final notifier = container.read(activityFormProvider.notifier);

      final result = await notifier.createActivity(
        title: 'New Game',
        sportType: 'tennis',
        dateTime: DateTime.now().add(const Duration(days: 2)),
        location: 'Court A',
        maxParticipants: 4,
        hostId: 'u1',
        hostName: 'Alice',
      );

      expect(result.isRight, isTrue);

      final formState = container.read(activityFormProvider);
      expect(formState.isLoading, isFalse);
      expect(formState.errorMessage, isNull);
    });

    test('deleteActivity soft-deletes via repository', () async {
      final id = await seedActivity();
      final notifier = container.read(activityFormProvider.notifier);

      final result = await notifier.deleteActivity(id);
      expect(result.isRight, isTrue);

      final doc =
          await fakeFirestore.collection('activities').doc(id).get();
      expect(doc['deletedAt'], isNotNull);
    });
  });
}
