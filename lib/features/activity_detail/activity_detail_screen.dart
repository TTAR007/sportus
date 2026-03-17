import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_text_styles.dart';
import '../../core/constants/sport_types.dart';
import '../../core/extensions/datetime_ext.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../providers/activity_provider.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/shimmer_card.dart';
import 'widgets/host_actions_bar.dart';
import 'widgets/participant_count_bar.dart';

class ActivityDetailScreen extends ConsumerWidget {
  const ActivityDetailScreen({required this.activityId, super.key});

  final String activityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorScheme>()!;
    final detailAsync = ref.watch(activityDetailProvider(activityId));
    final currentUser = ref.watch(currentUserProvider);
    final formState = ref.watch(activityFormProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
          tooltip: 'Back',
        ),
        backgroundColor: cs.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: detailAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: ShimmerCard(count: 3),
        ),
        error: (error, _) => EmptyState(
          message: 'Could not load activity.',
          icon: Icons.error_outline,
          actionLabel: 'Go Back',
          onAction: () => context.go('/'),
        ),
        data: (activity) {
          final sport = SportType.values.firstWhere(
            (s) => s.name == activity.sportType,
            orElse: () => SportType.other,
          );
          final isHost = currentUser?.uid == activity.hostId;
          final hasJoined = currentUser != null &&
              activity.participantIds.contains(currentUser.uid);
          final isFull = activity.currentParticipants >=
              activity.maxParticipants;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sport chip + title
                Row(
                  children: [
                    Chip(
                      avatar: Icon(sport.icon, size: 16),
                      label: Text(
                        sport.displayLabel,
                        style: AppTextStyles.labelSmall,
                      ),
                      backgroundColor: cs.primaryContainer,
                      side: BorderSide.none,
                    ),
                  ],
                ),
                const Gap(8),
                Text(
                  activity.title,
                  style: AppTextStyles.headingLarge.copyWith(
                    color: cs.onSurface,
                  ),
                ),
                const Gap(4),
                Text(
                  'Hosted by ${activity.hostName}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const Gap(20),

                // Date/time row
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  text: activity.dateTime.toDateTimeString(),
                ),
                const Gap(12),

                // Location row
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  text: activity.location,
                ),
                const Gap(20),

                // Description
                if (activity.description != null &&
                    activity.description!.isNotEmpty) ...[
                  Text(
                    activity.description!,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                  const Gap(20),
                ],

                // Participant bar
                ParticipantCountBar(
                  current: activity.currentParticipants,
                  max: activity.maxParticipants,
                  hasJoined: hasJoined,
                ),
                const Gap(24),

                // Host actions
                if (isHost) ...[
                  HostActionsBar(activityId: activity.id),
                  const Gap(16),
                ],

                // Join / Leave button (non-host only)
                if (!isHost && currentUser != null) ...[
                  if (hasJoined)
                    PrimaryButton(
                      label: 'Leave Activity',
                      isLoading: formState.isLoading,
                      onPressed: () => ref
                          .read(activityFormProvider.notifier)
                          .leaveActivity(activity.id, currentUser.uid)
                          .then((_) =>
                              ref.invalidate(
                                activityDetailProvider(activityId),
                              )),
                    )
                  else
                    PrimaryButton(
                      label: isFull ? 'Activity Full' : 'Join Activity',
                      isLoading: formState.isLoading,
                      onPressed: isFull
                          ? null
                          : () => ref
                              .read(activityFormProvider.notifier)
                              .joinActivity(
                                activity.id,
                                currentUser.uid,
                              )
                              .then((_) =>
                                  ref.invalidate(
                                    activityDetailProvider(activityId),
                                  )),
                    ),
                  const Gap(16),
                ],

                // Joined indicator
                if (hasJoined) ...[
                  Center(
                    child: Text(
                      'You\'ve joined this activity!',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: ext.success,
                      ),
                    ),
                  ),
                  const Gap(16),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: cs.onSurfaceVariant),
        const Gap(12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyLarge.copyWith(
              color: cs.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
