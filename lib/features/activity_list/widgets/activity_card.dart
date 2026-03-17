import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/sport_types.dart';
import '../../../core/extensions/datetime_ext.dart';
import '../../../data/models/activity_model.dart';

/// A card displaying a summary of an activity in the list.
class ActivityCard extends StatelessWidget {
  const ActivityCard({required this.activity, super.key});

  final ActivityModel activity;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Resolve the sport type enum for icon/label.
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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Sport icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  sport.icon,
                  color: cs.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const Gap(12),
              // Title, date, location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: AppTextStyles.headingMedium.copyWith(
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    Text(
                      activity.dateTime.toDateTimeString(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      activity.location,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Gap(8),
              // Participant count
              Column(
                children: [
                  Icon(Icons.people_outline, size: 20, color: cs.primary),
                  const Gap(4),
                  Text(
                    '${activity.currentParticipants}/${activity.maxParticipants}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
