---
name: architecture
description: Sportus architectural constraints — state management, navigation, data layer, and code organisation rules that apply to every Dart file in the project.
globs:
  - "lib/**/*.dart"
---

# Sportus Architecture Rules

These rules apply to every Dart file under `lib/`. They are non-negotiable.

## State Management — Riverpod only

- Use `flutter_riverpod` exclusively.
- **Never** use `setState`, `ChangeNotifier`, `InheritedWidget`, `BLoC`, or the `provider` package.
- All providers are declared in `lib/providers/` as top-level `final` variables.
- Use `AsyncNotifier` for async data (lists, detail views). Use `Notifier` for form/UI state.
- Screens read state with `ref.watch(...)`. Side-effects use `ref.read(...).someMethod()`.
- Providers must never receive or store a `BuildContext`.

```dart
// ✅ Correct
final activityListProvider = AsyncNotifierProvider<ActivityListNotifier,
    List<ActivityModel>>(ActivityListNotifier.new);

// ❌ Wrong — never use setState
class _MyScreenState extends State<MyScreen> {
  void _load() => setState(() { ... });
}
```

## Navigation — go_router only

- Use `go_router` exclusively. **Never** call `Navigator.push()`, `Navigator.pop()`, or `Navigator.of(context)`.
- All routes are defined in `lib/router/app_router.dart`. No inline `GoRoute` definitions elsewhere.
- Navigate with `context.go('/path')` or `context.push('/path')`.
- Pass complex objects via Riverpod state, not route `extra`, except for simple string IDs.

```dart
// ✅ Correct
context.push('/activities/${activity.id}/edit');

// ❌ Wrong
Navigator.push(context, MaterialPageRoute(builder: (_) => EditScreen()));
```

## Data Layer — repository pattern

- All Firestore reads/writes go through `ActivityRepository` (or a feature-specific repository).
- **No widget or provider** may import `cloud_firestore` directly.
- Repository methods return `Either<AppException, T>` using a sealed class.
- Soft-delete only: set `deletedAt = FieldValue.serverTimestamp()`. Never call `.delete()` from the client.
- Always use `FieldValue.serverTimestamp()` for `createdAt` and `updatedAt` on writes.

```dart
// ✅ Correct — via repository
final result = await ref.read(activityRepositoryProvider).joinActivity(id, userId);

// ❌ Wrong — direct Firestore in a provider or widget
FirebaseFirestore.instance.collection('activities').doc(id).update({...});
```

## Models — Freezed immutable data classes

- All data models use `@freezed` from `freezed_annotation`.
- Never mutate a model field directly. Use `.copyWith(...)` to produce a new instance.
- Run `dart run build_runner build --delete-conflicting-outputs` after any model change.

## File Organisation

- Files must stay under **300 lines**. Split if larger.
- Every feature lives under `lib/features/<feature>/`.
- Widgets used by **one feature** → `lib/features/<feature>/widgets/`.
- Widgets used by **multiple features** → `lib/shared/widgets/`.
- No business logic in widget files. Widgets call providers; providers call repositories.

## Naming Conventions

| Kind | Convention | Example |
|------|-----------|---------|
| Files | `snake_case` | `activity_card.dart` |
| Classes | `PascalCase` | `ActivityCard` |
| Providers | `camelCase` + `Provider` suffix | `activityListProvider` |
| Notifiers | `PascalCase` + `Notifier` suffix | `ActivityListNotifier` |
| Private members | `_camelCase` | `_handleJoin` |

## Error Handling

- Transient errors (network, Firestore) → `SnackBar`.
- Form validation errors → inline under each field.
- Always handle all three `AsyncValue` states:
  - Loading → `ShimmerCard` skeleton (`lib/shared/widgets/shimmer_card.dart`)
  - Error → `SnackBar` with retry option
  - Data (empty) → `EmptyState` widget (`lib/shared/widgets/empty_state.dart`) with CTA

## Logging

- **Never** use `print()` in production code.
- Use `debugPrint()` inside `assert(...)` for debug-only output.

## Testing

- All repository logic has unit tests using `fake_cloud_firestore`.
- All providers have unit tests using `ProviderContainer.test()` (built into Riverpod 3).
- Key widget flows have widget tests that run in **both** `ThemeMode.light` and `ThemeMode.dark`.
- `flutter analyze` must pass with **0 warnings** before every commit.
