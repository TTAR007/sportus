import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/sport_types.dart';
import '../../../providers/activity_provider.dart';

/// A horizontal scrollable row of filter chips for sport types.
class SportFilterChips extends ConsumerWidget {
  const SportFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final selected = ref.watch(sportFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                'All',
                style: AppTextStyles.labelSmall.copyWith(
                  color: selected == null
                      ? cs.onPrimaryContainer
                      : cs.onSurfaceVariant,
                ),
              ),
              selected: selected == null,
              onSelected: (_) {
                ref.read(sportFilterProvider.notifier).select(null);
              },
              selectedColor: cs.primaryContainer,
              backgroundColor: Colors.transparent,
              side: BorderSide(
                color: selected == null ? Colors.transparent : cs.outline,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
            ),
          ),
          // One chip per sport type
          ...SportType.values.map((type) {
            final isSelected = selected == type;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  type.displayLabel,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isSelected
                        ? cs.onPrimaryContainer
                        : cs.onSurfaceVariant,
                  ),
                ),
                avatar: Icon(
                  type.icon,
                  size: 16,
                  color: isSelected
                      ? cs.onPrimaryContainer
                      : cs.onSurfaceVariant,
                ),
                selected: isSelected,
                onSelected: (_) {
                  ref.read(sportFilterProvider.notifier).select(
                        isSelected ? null : type,
                      );
                },
                selectedColor: cs.primaryContainer,
                backgroundColor: Colors.transparent,
                side: BorderSide(
                  color: isSelected ? Colors.transparent : cs.outline,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                showCheckmark: false,
              ),
            );
          }),
        ],
      ),
    );
  }
}
