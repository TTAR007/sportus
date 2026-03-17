import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportus/data/models/activity_model.dart';

void main() {
  late ActivityModel sampleModel;

  setUp(() {
    sampleModel = ActivityModel(
      id: 'abc123',
      title: 'Sunday Football',
      sportType: 'football',
      dateTime: DateTime(2026, 4, 1, 15, 0),
      location: 'Central Park',
      maxParticipants: 10,
      description: 'Friendly match',
      hostId: 'user1',
      hostName: 'Alice',
      participantIds: const ['user1', 'user2'],
      currentParticipants: 2,
      createdAt: DateTime(2026, 3, 17),
      updatedAt: DateTime(2026, 3, 17),
    );
  });

  group('ActivityModel', () {
    test('fromJson / toJson round-trip preserves data', () {
      final json = sampleModel.toJson();
      final restored = ActivityModel.fromJson(json);
      expect(restored.id, sampleModel.id);
      expect(restored.title, sampleModel.title);
      expect(restored.sportType, sampleModel.sportType);
      expect(restored.dateTime, sampleModel.dateTime);
      expect(restored.location, sampleModel.location);
      expect(restored.maxParticipants, sampleModel.maxParticipants);
      expect(restored.description, sampleModel.description);
      expect(restored.hostId, sampleModel.hostId);
      expect(restored.hostName, sampleModel.hostName);
      expect(restored.participantIds, sampleModel.participantIds);
      expect(restored.currentParticipants, sampleModel.currentParticipants);
    });

    test('default values for participantIds and currentParticipants', () {
      final model = ActivityModel(
        id: 'x',
        title: 'Test',
        sportType: 'tennis',
        dateTime: DateTime(2026, 5, 1),
        location: 'Court A',
        maxParticipants: 4,
        hostId: 'u1',
        hostName: 'Bob',
        createdAt: DateTime(2026, 3, 17),
        updatedAt: DateTime(2026, 3, 17),
      );
      expect(model.participantIds, isEmpty);
      expect(model.currentParticipants, 0);
      expect(model.deletedAt, isNull);
      expect(model.description, isNull);
    });

    test('copyWith produces a new instance with changed field', () {
      final updated = sampleModel.copyWith(title: 'New Title');
      expect(updated.title, 'New Title');
      expect(updated.location, sampleModel.location);
      expect(identical(updated, sampleModel), isFalse);
    });

    test('fromFirestore reads a Firestore document correctly', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final now = DateTime(2026, 4, 1, 15, 0);
      final created = DateTime(2026, 3, 17);

      await fakeFirestore.collection('activities').doc('doc1').set({
        'title': 'Basketball Jam',
        'sportType': 'basketball',
        'dateTime': Timestamp.fromDate(now),
        'location': 'Gym A',
        'maxParticipants': 8,
        'description': null,
        'hostId': 'host1',
        'hostName': 'Charlie',
        'participantIds': ['host1'],
        'currentParticipants': 1,
        'createdAt': Timestamp.fromDate(created),
        'updatedAt': Timestamp.fromDate(created),
        'deletedAt': null,
      });

      final doc =
          await fakeFirestore.collection('activities').doc('doc1').get();
      final model = ActivityModel.fromFirestore(doc);

      expect(model.id, 'doc1');
      expect(model.title, 'Basketball Jam');
      expect(model.sportType, 'basketball');
      expect(model.dateTime, now);
      expect(model.location, 'Gym A');
      expect(model.maxParticipants, 8);
      expect(model.description, isNull);
      expect(model.hostId, 'host1');
      expect(model.hostName, 'Charlie');
      expect(model.participantIds, ['host1']);
      expect(model.currentParticipants, 1);
      expect(model.deletedAt, isNull);
    });

    test('toFirestore produces correct map (no id, no timestamps)', () {
      final map = sampleModel.toFirestore();
      expect(map.containsKey('id'), isFalse);
      expect(map.containsKey('createdAt'), isFalse);
      expect(map.containsKey('updatedAt'), isFalse);
      expect(map['title'], 'Sunday Football');
      expect(map['sportType'], 'football');
      expect(map['dateTime'], isA<Timestamp>());
      expect(map['maxParticipants'], 10);
      expect(map['participantIds'], ['user1', 'user2']);
      expect(map['currentParticipants'], 2);
    });
  });
}
