import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/sport_types.dart';
import '../../../core/extensions/datetime_ext.dart';
import '../../../data/models/activity_model.dart';

/// A compact activity card used on the profile screen with a role badge.
class ProfileActivityCard extends StatelessWidget {
  const ProfileActivityCard({
    required this.activity,
    required this.badge,
    super.key,
  });

  final ActivityModel activity;
  final String badge;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final sport = SportType.values.firstWhere(
      (s) => s.name == activity.sportType,
      orElse: () => SportType.other,
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outline),
      ),
      color: cs.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/activities/${activity.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Sport icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  sport.icon,
                  color: cs.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const Gap(12),
              // Title + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(2),
                    Text(
                      activity.dateTime.toDateTimeString(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              // Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
