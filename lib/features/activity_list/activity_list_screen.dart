import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_text_styles.dart';
import '../../providers/activity_provider.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/shimmer_card.dart';
import 'widgets/activity_card.dart';
import 'widgets/sport_filter_chips.dart';

class ActivityListScreen extends ConsumerWidget {
  const ActivityListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final activitiesAsync = ref.watch(activityListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sportus',
          style: AppTextStyles.headingLarge.copyWith(color: cs.primary),
        ),
        centerTitle: false,
        backgroundColor: cs.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          const SportFilterChips(),
          const Gap(12),
          Expanded(
            child: activitiesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ShimmerCard(count: 5, height: 100),
              ),
              error: (error, _) => EmptyState(
                message: 'Something went wrong.\n$error',
                icon: Icons.error_outline,
                actionLabel: 'Retry',
                onAction: () => ref.invalidate(activityListProvider),
              ),
              data: (activities) {
                if (activities.isEmpty) {
                  return EmptyState(
                    message: 'No activities yet.\nCreate one!',
                    icon: Icons.sports_outlined,
                    actionLabel: 'Create Activity',
                    onAction: () => context.push('/activities/new'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: activities.length,
                  separatorBuilder: (_, _) => const Gap(12),
                  itemBuilder: (_, index) {
                    return ActivityCard(activity: activities[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/activities/new'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        tooltip: 'Create Activity',
        child: const Icon(Icons.add),
      ),
    );
  }
}
