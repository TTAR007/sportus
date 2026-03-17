import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import 'package:sportus/core/theme/app_theme.dart';
import 'package:sportus/data/repositories/activity_repository.dart';
import 'package:sportus/providers/activity_provider.dart';
import 'package:sportus/providers/auth_provider.dart';
import 'package:sportus/router/app_router.dart';

// ---------------------------------------------------------------------------
// Mock User
// ---------------------------------------------------------------------------

class MockUser extends Mock implements User {}

// ---------------------------------------------------------------------------
// Test app builder
// ---------------------------------------------------------------------------

/// Builds a fully themed Sportus app backed by [fakeFirestore] and a mock
/// user, so integration tests can run without a real Firebase backend.
Widget buildTestApp({
  required FakeFirebaseFirestore fakeFirestore,
  String userId = 'test-user-id',
  String userName = 'Test User',
}) {
  final mockUser = MockUser();
  when(mockUser.uid).thenReturn(userId);
  when(mockUser.displayName).thenReturn(userName);

  return ProviderScope(
    overrides: [
      activityRepositoryProvider.overrideWithValue(
        ActivityRepository(firestore: fakeFirestore),
      ),
      authStateProvider.overrideWith(
        (ref) => Stream.value(mockUser),
      ),
      currentUserProvider.overrideWithValue(mockUser),
    ],
    child: Consumer(
      builder: (context, ref, _) {
        final router = ref.watch(goRouterProvider);
        return MaterialApp.router(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.light,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
    ),
  );
}

// ---------------------------------------------------------------------------
// Seed helper
// ---------------------------------------------------------------------------

/// Inserts an activity document into [firestore] for test setup.
Future<void> seedActivity(
  FakeFirebaseFirestore firestore, {
  required String id,
  required String title,
  String sportType = 'football',
  required DateTime dateTime,
  String location = 'Test Location',
  int maxParticipants = 10,
  String? description,
  String hostId = 'other-user',
  String hostName = 'Other User',
  List<String> participantIds = const [],
  int currentParticipants = 0,
}) async {
  await firestore.collection('activities').doc(id).set({
    'title': title,
    'sportType': sportType,
    'dateTime': Timestamp.fromDate(dateTime),
    'location': location,
    'maxParticipants': maxParticipants,
    'description': description,
    'hostId': hostId,
    'hostName': hostName,
    'participantIds': participantIds,
    'currentParticipants': currentParticipants,
    'createdAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
    'deletedAt': null,
  });
}
