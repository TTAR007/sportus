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

class ActivityListScreen extends ConsumerStatefulWidget {
  const ActivityListScreen({super.key});

  @override
  ConsumerState<ActivityListScreen> createState() =>
      _ActivityListScreenState();
}

class _ActivityListScreenState extends ConsumerState<ActivityListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Only load more if the raw list has filled the current limit.
      final rawList = ref.read(activityListProvider).value;
      final limit = ref.read(activityLimitProvider);
      if (rawList != null && rawList.length >= limit) {
        ref.read(activityLimitProvider.notifier).loadMore();
      }
    }
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchController.clear();
        ref.read(locationSearchProvider.notifier).clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final activitiesAsync = ref.watch(filteredActivityListProvider);

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: AppTextStyles.bodyLarge.copyWith(color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search by location...',
                  hintStyle: AppTextStyles.bodyLarge.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  ref.read(locationSearchProvider.notifier).update(value);
                },
              )
            : Text(
                'Sportus',
                style:
                    AppTextStyles.headingLarge.copyWith(color: cs.primary),
              ),
        centerTitle: false,
        backgroundColor: cs.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
            tooltip: _showSearch ? 'Close search' : 'Search by location',
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
            tooltip: 'Profile',
          ),
        ],
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
                  final search = ref.read(locationSearchProvider);
                  if (search.isNotEmpty) {
                    return EmptyState(
                      message: 'No activities found for "$search".',
                      icon: Icons.search_off,
                    );
                  }
                  return EmptyState(
                    message: 'No activities yet.\nCreate one!',
                    icon: Icons.sports_outlined,
                    actionLabel: 'Create Activity',
                    onAction: () => context.push('/activities/new'),
                  );
                }
                final limit = ref.read(activityLimitProvider);
                final rawLength =
                    ref.read(activityListProvider).value?.length ??
                        activities.length;
                final hasMore = rawLength >= limit;

                return ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: activities.length + (hasMore ? 1 : 0),
                  separatorBuilder: (_, _) => const Gap(12),
                  itemBuilder: (_, index) {
                    if (index == activities.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      );
                    }
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
