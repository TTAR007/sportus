import 'package:flutter/material.dart';

import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/sport_types.dart';

/// A horizontal wrap of FilterChips for selecting a sport type.
class SportTypeSelector extends StatelessWidget {
  const SportTypeSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final SportType selected;
  final ValueChanged<SportType> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: SportType.values.map((sport) {
        final isSelected = sport == selected;
        return FilterChip(
          avatar: Icon(sport.icon, size: 16),
          label: Text(
            sport.displayLabel,
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected
                  ? cs.onPrimaryContainer
                  : cs.onSurfaceVariant,
            ),
          ),
          selected: isSelected,
          selectedColor: cs.primaryContainer,
          backgroundColor: cs.surface,
          side: BorderSide(
            color: isSelected ? Colors.transparent : cs.outline,
          ),
          onSelected: (_) => onChanged(sport),
        );
      }).toList(),
    );
  }
}
