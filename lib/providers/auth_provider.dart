import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Streams the current Firebase Auth state.
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Synchronous read of the current user (null if not authenticated).
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});
