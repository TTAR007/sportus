import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/app_text_styles.dart';

/// A linear progress bar showing participant count vs max.
class ParticipantCountBar extends StatelessWidget {
  const ParticipantCountBar({
    required this.current,
    required this.max,
    this.hasJoined = false,
    super.key,
  });

  final int current;
  final int max;
  final bool hasJoined;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ratio = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    final isFull = current >= max;

    Color barColor;
    if (isFull) {
      barColor = cs.error;
    } else if (hasJoined) {
      barColor = cs.primary;
    } else {
      barColor = cs.primary;
    }

    return Semantics(
      label: '$current of $max participants',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: cs.outline.withAlpha(64),
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
          const Gap(8),
          Text(
            '$current / $max participants',
            style: AppTextStyles.bodyMedium.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
