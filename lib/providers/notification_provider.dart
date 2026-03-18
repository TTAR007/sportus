import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// FCM instance provider.
final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

/// Manages FCM permission and token lifecycle.
final notificationSetupProvider = FutureProvider<String?>((ref) async {
  final messaging = ref.read(firebaseMessagingProvider);

  // Request permission (iOS shows a prompt; Android auto-grants).
  final settings = await messaging.requestPermission();

  if (settings.authorizationStatus == AuthorizationStatus.denied) {
    return null;
  }

  // Get FCM token for this device.
  final token = await messaging.getToken();
  assert(() {
    debugPrint('FCM token: $token');
    return true;
  }());

  return token;
});

/// Top-level background message handler (must be a top-level function).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages here if needed.
  assert(() {
    debugPrint('Background message: ${message.messageId}');
    return true;
  }());
}
