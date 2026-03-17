---
name: FlutterTest
description: Write unit, widget, or integration tests for Sportus Flutter code. USE WHEN the user asks to add tests, write a test, or check test coverage for any file in the project. Covers Riverpod provider tests, repository unit tests with fake_cloud_firestore, and widget tests with theme support.
---

# Flutter Test Writer

## Determine the test type

| What you're testing | Test type | Location |
|---------------------|-----------|----------|
| Freezed model, validators, extensions | Unit | `test/unit/` |
| Repository with Firestore | Unit (mocked) | `test/unit/` |
| Riverpod providers | Unit | `test/providers/` |
| Widget rendering and interactions | Widget | `test/widgets/` |
| Full user flows (create, join, delete) | Integration | `integration_test/` |

## Unit test — Repository (fake_cloud_firestore)

```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportus/data/repositories/activity_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ActivityRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = ActivityRepository(firestore: fakeFirestore);
  });

  test('createActivity stores document and returns model', () async {
    final result = await repository.createActivity(/* test model */);
    expect(result.isRight(), true);
  });
}
```

## Provider test — Riverpod 3 built-in (no extra package)

`riverpod_test` does not exist for Riverpod 3. Use `ProviderContainer.test()` which is built
directly into `flutter_riverpod ^3.x`. The container is automatically disposed after the test.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sportus/providers/activity_provider.dart';

void main() {
  late MockActivityRepository mockRepo;

  setUp(() {
    mockRepo = MockActivityRepository();
  });

  test('activityListProvider emits list on successful stream', () async {
    when(mockRepo.streamActivities()).thenAnswer(
      (_) => Stream.value([mockActivity]),
    );

    final container = ProviderContainer.test(overrides: [
      activityRepositoryProvider.overrideWithValue(mockRepo),
    ]);
    // No addTearDown needed — ProviderContainer.test() disposes automatically

    final result = await container.read(activityListProvider.future);
    expect(result, [mockActivity]);
  });
}
```

## Widget test — theme helper

The helper is named `pumpWithTheme`. Use this exact name in every widget test file.
Always test **both** light and dark modes.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportus/core/theme/app_theme.dart';

Widget pumpWithTheme(Widget child, {bool dark = false}) {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(body: child),
    ),
  );
}

testWidgets('ActivityCard renders in light mode', (tester) async {
  await tester.pumpWidget(pumpWithTheme(ActivityCard(activity: mockActivity)));
  expect(find.text(mockActivity.title), findsOneWidget);
});

testWidgets('ActivityCard renders in dark mode', (tester) async {
  await tester.pumpWidget(pumpWithTheme(ActivityCard(activity: mockActivity), dark: true));
  expect(find.text(mockActivity.title), findsOneWidget);
});
```

## Integration test skeleton

```dart
// integration_test/create_activity_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sportus/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('User can create and see an activity', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    // tap FAB → fill form → submit → verify item in list
  });
}
```

## Coverage requirements

| Layer | Target |
|-------|--------|
| Models | 100% |
| Repository | ≥ 80% |
| Providers | ≥ 80% — use `ProviderContainer.test()` |
| Widget flows | Light + dark mode both covered |
