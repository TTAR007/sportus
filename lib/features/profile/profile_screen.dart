import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_text_styles.dart';
import '../../providers/activity_provider.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/shimmer_card.dart';
import 'widgets/profile_activity_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return Scaffold(
        appBar: _buildAppBar(context, cs),
        body: const EmptyState(
          message: 'Not signed in.',
          icon: Icons.person_off_outlined,
        ),
      );
    }

    final activitiesAsync = ref.watch(userActivitiesProvider(currentUser.uid));

    return Scaffold(
      appBar: _buildAppBar(context, cs),
      body: activitiesAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: ShimmerCard(count: 4),
        ),
        error: (error, _) => EmptyState(
          message: 'Could not load your activities.',
          icon: Icons.error_outline,
          actionLabel: 'Retry',
          onAction: () =>
              ref.invalidate(userActivitiesProvider(currentUser.uid)),
        ),
        data: (activities) {
          final hosted = activities
              .where((a) => a.hostId == currentUser.uid)
              .toList();
          final joined = activities
              .where((a) =>
                  a.hostId != currentUser.uid &&
                  a.participantIds.contains(currentUser.uid))
              .toList();

          if (hosted.isEmpty && joined.isEmpty) {
            return EmptyState(
              message: 'No activities yet.\n'
                  'Create or join one to get started!',
              icon: Icons.sports_outlined,
              actionLabel: 'Browse Activities',
              onAction: () => context.go('/'),
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // User info header
              const Gap(8),
              Center(
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: cs.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 36,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
              const Gap(12),
              Center(
                child: Text(
                  currentUser.displayName ?? 'Anonymous',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: cs.onSurface,
                  ),
                ),
              ),
              const Gap(4),
              Center(
                child: Text(
                  currentUser.isAnonymous
                      ? 'Guest user'
                      : (currentUser.email ?? ''),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              const Gap(24),

              // Hosted section
              if (hosted.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Hosted (${hosted.length})',
                  icon: Icons.star_outline,
                ),
                const Gap(8),
                ...hosted.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ProfileActivityCard(
                        activity: a,
                        badge: 'Host',
                      ),
                    )),
                const Gap(12),
              ],

              // Joined section
              if (joined.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Joined (${joined.length})',
                  icon: Icons.group_outlined,
                ),
                const Gap(8),
                ...joined.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ProfileActivityCard(
                        activity: a,
                        badge: 'Joined',
                      ),
                    )),
              ],
              const Gap(16),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, ColorScheme cs) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/'),
        tooltip: 'Back',
      ),
      title: Text(
        'My Profile',
        style: AppTextStyles.headingMedium.copyWith(color: cs.onSurface),
      ),
      backgroundColor: cs.surfaceContainerLowest,
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: cs.primary),
        const Gap(8),
        Text(
          title,
          style: AppTextStyles.headingMedium.copyWith(color: cs.onSurface),
        ),
      ],
    );
  }
}
