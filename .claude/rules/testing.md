---
name: testing
description: Testing conventions, helpers, and coverage requirements for Sportus. Activates when working with any test file.
globs:
  - "test/**/*.dart"
  - "integration_test/**/*.dart"
---

# Sportus Testing Rules

## Test file locations

| Test type | Location | File naming |
|-----------|----------|-------------|
| Model / utility unit tests | `test/unit/` | `<subject>_test.dart` |
| Repository unit tests | `test/unit/` | `<name>_repository_test.dart` |
| Provider unit tests | `test/providers/` | `<name>_provider_test.dart` |
| Widget tests | `test/widgets/` | `<name>_widget_test.dart` |
| Integration tests | `integration_test/` | `<flow>_test.dart` |

## Theme helper — required in every widget test

The helper is named `pumpWithTheme`. Use this exact name consistently across all widget test files.
Every widget test must run in **both** light and dark modes.

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
```

```dart
testWidgets('renders correctly in light mode', (tester) async {
  await tester.pumpWidget(pumpWithTheme(MyWidget()));
  expect(find.byType(MyWidget), findsOneWidget);
});

testWidgets('renders correctly in dark mode', (tester) async {
  await tester.pumpWidget(pumpWithTheme(MyWidget(), dark: true));
  expect(find.byType(MyWidget), findsOneWidget);
});
```

## Repository tests — always use fake_cloud_firestore

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

Never connect to real Firestore in unit or widget tests.

## Provider tests — Riverpod 3 built-in (no extra package)

`riverpod_test` does not exist for Riverpod 3. Use `ProviderContainer.test()` built into
`flutter_riverpod ^3.x`. Mock the repository using `@GenerateMocks([ActivityRepository])`.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

final container = ProviderContainer.test(overrides: [
  activityRepositoryProvider.overrideWithValue(mockRepo),
]);
// No addTearDown needed — automatically disposed after the test
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

## Coverage targets

| Layer | Target |
|-------|--------|
| Models + extensions | 100% |
| Repository | ≥ 80% |
| Providers | ≥ 80% |
| Widgets — key flows | Light + dark mode both covered |

## CI gate

`flutter analyze && flutter test` must pass with 0 failures before any PR merges.

```bash
flutter analyze
flutter test --coverage
```
