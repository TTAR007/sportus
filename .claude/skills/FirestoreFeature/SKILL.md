---
name: FirestoreFeature
description: Scaffold a complete Sportus feature backed by Firestore — model, repository method, Riverpod provider, and screen. USE WHEN the user asks to add a new feature, data model, or Firestore collection to the project.
---

# Firestore Feature Scaffolder

Follow these steps in order when adding a new Firestore-backed feature.

## Step 1 — Define the Freezed model

Create `lib/data/models/<n>_model.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part '<n>_model.freezed.dart';
part '<n>_model.g.dart';

@freezed
sealed class <n>Model with _$<n>Model {
  const factory <n>Model({
    required String id,
    // ... fields
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _<n>Model;

  factory <n>Model.fromJson(Map<String, dynamic> json) =>
      _$<n>ModelFromJson(json);

  factory <n>Model.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return <n>Model.fromJson({...data, 'id': doc.id});
  }
}
```

After creating the model, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Step 2 — Add repository methods

In `lib/data/repositories/activity_repository.dart` (or a new `<n>_repository.dart`):

```dart
// Always return Either<AppException, T>
Future<Either<AppException, <n>Model>> create<n>(<n>Model model) async {
  try {
    final ref = _firestore.collection('<collection>').doc();
    final withId = model.copyWith(id: ref.id);
    await ref.set(withId.toJson());
    return Right(withId);
  } on FirebaseException catch (e) {
    return Left(AppException.firebase(e.code, e.message));
  }
}
```

**Rules:**
- Never call Firestore directly from a provider or widget.
- Soft-delete only: set `deletedAt` to `FieldValue.serverTimestamp()`.
- Use `FieldValue.serverTimestamp()` for `createdAt`/`updatedAt` on writes.

## Step 3 — Create Riverpod providers

In `lib/providers/<n>_provider.dart`.

For **streaming live data** from Firestore, use `StreamNotifier`:

```dart
// Stream provider — real-time Firestore listener
final <n>ListProvider = StreamNotifierProvider<
  <n>ListNotifier, List<<n>Model>
>(<n>ListNotifier.new);

class <n>ListNotifier extends StreamNotifier<List<<n>Model>> {
  @override
  Stream<List<<n>Model>> build() {
    return ref.read(<n>RepositoryProvider).stream<n>List();
  }
}
```

For **one-shot async data**, use `AsyncNotifier`:

```dart
final <n>DetailProvider = AsyncNotifierProvider.family<
  <n>DetailNotifier, <n>Model, String
>(<n>DetailNotifier.new);

class <n>DetailNotifier extends FamilyAsyncNotifier<<n>Model, String> {
  @override
  Future<<n>Model> build(String id) async {
    return ref.read(<n>RepositoryProvider).get<n>(id);
  }
}
```

## Step 4 — Wire up the screen

- Use `ref.watch(<n>ListProvider)` in the screen.
- Always handle all three `AsyncValue` states:
  - Loading → `ShimmerCard` skeleton
  - Error → `SnackBar` with retry
  - Data (empty) → `EmptyState` widget with CTA

```dart
ref.watch(<n>ListProvider).when(
  data: (items) => ListView.builder(...),
  loading: () => const ShimmerCard(),
  error: (e, _) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    });
    return const EmptyState();
  },
);
```

## Step 5 — Update Firestore security rules

Update `firestore.rules` to cover the new collection.
All reads require `request.auth != null`.
Writes are scoped to the owning user (`request.auth.uid == resource.data.hostId`).
