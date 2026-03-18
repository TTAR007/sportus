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

  // ---------------------------------------------------------------------------
  // LocationSearchNotifier
  // ---------------------------------------------------------------------------

  group('locationSearchProvider', () {
    test('default state is empty string', () {
      final search = container.read(locationSearchProvider);
      expect(search, '');
    });

    test('update sets the query', () {
      container.read(locationSearchProvider.notifier).update('park');
      expect(container.read(locationSearchProvider), 'park');
    });

    test('clear resets to empty string', () {
      container.read(locationSearchProvider.notifier).update('park');
      container.read(locationSearchProvider.notifier).clear();
      expect(container.read(locationSearchProvider), '');
    });
  });

  // ---------------------------------------------------------------------------
  // filteredActivityListProvider
  // ---------------------------------------------------------------------------

  group('filteredActivityListProvider', () {
    test('returns all activities when search is empty', () async {
      await seedActivity(title: 'A');
      await seedActivity(title: 'B');

      // Wait for the stream to emit
      container.listen(activityListProvider, (_, _) {},
          fireImmediately: true);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final result = container.read(filteredActivityListProvider);
      result.whenData((list) {
        expect(list.length, greaterThanOrEqualTo(2));
      });
    });

    test('filters activities by location (case-insensitive)', () async {
      // Seed with different locations
      final ref1 = fakeFirestore.collection('activities').doc();
      await ref1.set({
        'title': 'Game at Park',
        'sportType': 'football',
        'dateTime': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 1)),
        ),
        'location': 'Central Park',
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

      final ref2 = fakeFirestore.collection('activities').doc();
      await ref2.set({
        'title': 'Game at Gym',
        'sportType': 'basketball',
        'dateTime': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 2)),
        ),
        'location': 'City Gym',
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

      // Wait for stream data
      container.listen(activityListProvider, (_, _) {},
          fireImmediately: true);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Apply search filter
      container.read(locationSearchProvider.notifier).update('park');

      final result = container.read(filteredActivityListProvider);
      result.whenData((list) {
        expect(list.every((a) => a.location.toLowerCase().contains('park')),
            isTrue);
      });
    });
  });

  // ---------------------------------------------------------------------------
  // ActivityLimitNotifier
  // ---------------------------------------------------------------------------

  group('activityLimitProvider', () {
    test('default is 20', () {
      final limit = container.read(activityLimitProvider);
      expect(limit, 20);
    });

    test('loadMore increments by 20', () {
      container.read(activityLimitProvider.notifier).loadMore();
      expect(container.read(activityLimitProvider), 40);
      container.read(activityLimitProvider.notifier).loadMore();
      expect(container.read(activityLimitProvider), 60);
    });

    test('reset returns to 20', () {
      container.read(activityLimitProvider.notifier).loadMore();
      container.read(activityLimitProvider.notifier).loadMore();
      container.read(activityLimitProvider.notifier).reset();
      expect(container.read(activityLimitProvider), 20);
    });
  });

  // ---------------------------------------------------------------------------
  // userActivitiesProvider
  // ---------------------------------------------------------------------------

  group('userActivitiesProvider', () {
    test('emits activities for user who is host', () async {
      await seedActivity(title: 'Hosted Game');

      container.listen(
        userActivitiesProvider('host1'),
        (_, _) {},
        fireImmediately: true,
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));

      final result = container.read(userActivitiesProvider('host1'));
      result.whenData((list) {
        expect(list.any((a) => a.title == 'Hosted Game'), isTrue);
      });
    });

    test('emits activities for user who is participant', () async {
      final ref = fakeFirestore.collection('activities').doc();
      await ref.set({
        'title': 'Joined Game',
        'sportType': 'tennis',
        'dateTime': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 1)),
        ),
        'location': 'Court',
        'maxParticipants': 10,
        'description': null,
        'hostId': 'otherHost',
        'hostName': 'Other',
        'participantIds': ['user1'],
        'currentParticipants': 1,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'deletedAt': null,
      });

      container.listen(
        userActivitiesProvider('user1'),
        (_, _) {},
        fireImmediately: true,
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));

      final result = container.read(userActivitiesProvider('user1'));
      result.whenData((list) {
        expect(list.any((a) => a.title == 'Joined Game'), isTrue);
      });
    });

    test('returns empty list for user with no activities', () async {
      container.listen(
        userActivitiesProvider('nobody'),
        (_, _) {},
        fireImmediately: true,
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));

      final result = container.read(userActivitiesProvider('nobody'));
      result.whenData((list) {
        expect(list, isEmpty);
      });
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
