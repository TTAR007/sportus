import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/shimmer_card.dart';

/// Transparently signs the user in anonymously if not authenticated.
///
/// Wraps the main app content: shows a loading state while auth initialises,
/// triggers anonymous sign-in if needed, and renders [child] once ready.
class AuthGate extends ConsumerWidget {
  const AuthGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final cs = Theme.of(context).colorScheme;

    return authState.when(
      data: (user) {
        if (user == null) {
          // Trigger anonymous sign-in
          _signInAnonymously();
          return _LoadingScreen();
        }
        return child;
      },
      loading: () => _LoadingScreen(),
      error: (error, _) => Scaffold(
        body: Center(
          child: Text(
            'Something went wrong. Please restart the app.',
            style: AppTextStyles.bodyLarge.copyWith(color: cs.error),
          ),
        ),
      ),
    );
  }

  Future<void> _signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (_) {
      // Auth error will be surfaced through authStateProvider
    }
  }
}

class _LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sportus',
              style: AppTextStyles.headingLarge.copyWith(
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 200,
              child: ShimmerCard(),
            ),
          ],
        ),
      ),
    );
  }
}
