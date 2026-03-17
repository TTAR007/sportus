import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_text_styles.dart';
import '../../../providers/activity_provider.dart';

/// Edit and Delete action buttons shown only to the host.
class HostActionsBar extends ConsumerWidget {
  const HostActionsBar({required this.activityId, super.key});

  final String activityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Edit button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () =>
                context.push('/activities/$activityId/edit'),
            icon: const Icon(Icons.edit_outlined, size: 20),
            label: Text(
              'Edit',
              style: AppTextStyles.bodyMedium.copyWith(
                color: cs.primary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.primary,
              side: BorderSide(color: cs.primary),
              minimumSize: const Size(44, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Delete button
        Expanded(
          child: TextButton.icon(
            onPressed: () => _confirmDelete(context, ref),
            icon: Icon(Icons.delete_outline, size: 20, color: cs.error),
            label: Text(
              'Delete',
              style: AppTextStyles.bodyMedium.copyWith(
                color: cs.error,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: cs.error,
              minimumSize: const Size(44, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final cs = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Activity'),
        content: const Text(
          'Are you sure you want to cancel this activity?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: cs.error),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(activityFormProvider.notifier)
          .deleteActivity(activityId);
      if (context.mounted) {
        context.go('/');
      }
    }
  }
}
