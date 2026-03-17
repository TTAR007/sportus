import 'package:flutter/material.dart';

import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/datetime_ext.dart';

/// A read-only text field that opens date and time pickers when tapped.
class DateTimeField extends StatelessWidget {
  const DateTimeField({
    required this.value,
    required this.onChanged,
    this.errorText,
    super.key,
  });

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _pickDateTime(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date & Time',
          errorText: errorText,
          prefixIcon: Icon(
            Icons.calendar_today_outlined,
            color: cs.onSurfaceVariant,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          value != null ? value!.toDateTimeString() : 'Select date and time',
          style: AppTextStyles.bodyLarge.copyWith(
            color: value != null ? cs.onSurface : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: value ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: value != null
          ? TimeOfDay.fromDateTime(value!)
          : const TimeOfDay(hour: 18, minute: 0),
    );

    if (time == null) return;

    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    onChanged(combined);
  }
}
