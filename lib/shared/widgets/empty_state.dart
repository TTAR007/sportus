import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../core/constants/app_text_styles.dart';
import 'primary_button.dart';

/// A centered empty/error state with icon, message, and optional CTA button.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 64,
                color: cs.onSurfaceVariant,
              ),
              const Gap(16),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const Gap(24),
              SizedBox(
                width: 220,
                child: PrimaryButton(
                  label: actionLabel!,
                  onPressed: onAction,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
