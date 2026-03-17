---
name: firestore
description: Firestore schema, query patterns, and security rule conventions for Sportus. Activates when working with repository files, Firestore security rules, or data models.
globs:
  - "lib/data/**/*.dart"
  - "firestore.rules"
  - "lib/providers/**/*.dart"
---

# Sportus Firestore Rules

## Collection: `activities`

### Document schema

```
activities/{activityId}
  title               : string           — max 80 chars
  sportType           : string           — SportType enum .name value
  dateTime            : Timestamp        — must be future at creation
  location            : string           — max 200 chars, free text
  maxParticipants     : number           — integer, 2–100
  description         : string | null    — max 500 chars
  hostId              : string           — Firebase Auth UID
  hostName            : string           — display name at creation time
  participantIds      : string[]         — UIDs of joined users
  currentParticipants : number           — denormalised; always == participantIds.length
  createdAt           : Timestamp
  updatedAt           : Timestamp
  deletedAt           : Timestamp | null — null = active; non-null = soft-deleted
```

### Write rules

- `createdAt` and `updatedAt` must always be `FieldValue.serverTimestamp()`.
- `currentParticipants` must always equal `participantIds.length` after every write.
- Never hard-delete. Set `deletedAt = FieldValue.serverTimestamp()` instead.
- Join/leave must use a Firestore **transaction** to atomically update `participantIds` and `currentParticipants`.

### Read rules

- Query only non-deleted activities: `.where('deletedAt', isNull: true)`.
- Default sort: `orderBy('dateTime', descending: false)` — soonest first.
- Filter by sport: `.where('sportType', isEqualTo: sportType.name)`.
- Always include `.where('dateTime', isGreaterThan: Timestamp.now())` in list queries.
- Paginate with `.limit(20)` and `startAfterDocument` for large lists.

## Repository patterns

### Stream (real-time list)

```dart
Stream<List<ActivityModel>> streamActivities({String? sportTypeFilter}) {
  var query = _firestore
      .collection('activities')
      .where('deletedAt', isNull: true)
      .where('dateTime', isGreaterThan: Timestamp.now())
      .orderBy('dateTime');

  if (sportTypeFilter != null) {
    query = query.where('sportType', isEqualTo: sportTypeFilter);
  }

  return query.snapshots().map(
    (snap) => snap.docs.map(ActivityModel.fromFirestore).toList(),
  );
}
```

### Transaction — join activity

```dart
Future<Either<AppException, void>> joinActivity(
  String activityId,
  String userId,
) async {
  try {
    await _firestore.runTransaction((tx) async {
      final ref = _firestore.collection('activities').doc(activityId);
      final snap = await tx.get(ref);
      final model = ActivityModel.fromFirestore(snap);

      if (model.currentParticipants >= model.maxParticipants) {
        throw const AppException.activityFull();
      }
      if (model.participantIds.contains(userId)) {
        throw const AppException.alreadyJoined();
      }

      tx.update(ref, {
        'participantIds': FieldValue.arrayUnion([userId]),
        'currentParticipants': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
    return const Right(null);
  } on AppException catch (e) {
    return Left(e);
  } on FirebaseException catch (e) {
    return Left(AppException.firebase(e.code, e.message));
  }
}
```

## Firestore Security Rules (`firestore.rules`)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /activities/{activityId} {
      allow read: if request.auth != null
                  && resource.data.deletedAt == null;

      allow create: if request.auth != null
                    && request.resource.data.hostId == request.auth.uid;

      allow update: if request.auth != null
                    && (resource.data.hostId == request.auth.uid
                        || onlyUpdatingParticipants());

      allow delete: if false;
    }
  }

  function onlyUpdatingParticipants() {
    return request.resource.data.diff(resource.data).affectedKeys()
      .hasOnly(['participantIds', 'currentParticipants', 'updatedAt']);
  }
}
```
