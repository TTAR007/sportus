import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/sport_types.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/activity_provider.dart';
import '../../../shared/widgets/primary_button.dart';
import 'datetime_field.dart';
import 'sport_type_selector.dart';

/// The form field column used by both create and edit modes.
class ActivityFormFields extends StatelessWidget {
  const ActivityFormFields({
    required this.formKey,
    required this.titleCtrl,
    required this.locationCtrl,
    required this.descriptionCtrl,
    required this.maxParticipantsCtrl,
    required this.selectedSport,
    required this.onSportChanged,
    required this.selectedDateTime,
    required this.dateTimeError,
    required this.onDateTimeChanged,
    required this.formState,
    required this.isEdit,
    required this.onSubmit,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleCtrl;
  final TextEditingController locationCtrl;
  final TextEditingController descriptionCtrl;
  final TextEditingController maxParticipantsCtrl;
  final SportType selectedSport;
  final ValueChanged<SportType> onSportChanged;
  final DateTime? selectedDateTime;
  final String? dateTimeError;
  final ValueChanged<DateTime> onDateTimeChanged;
  final ActivityFormState formState;
  final bool isEdit;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sport type selector
            Text(
              'Sport Type',
              style: AppTextStyles.bodyMedium.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const Gap(8),
            SportTypeSelector(
              selected: selectedSport,
              onChanged: onSportChanged,
            ),
            const Gap(20),

            // Title
            TextFormField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Sunday Football',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: AppTextStyles.bodyLarge.copyWith(
                color: cs.onSurface,
              ),
              validator: Validators.validateTitle,
            ),
            const Gap(16),

            // Location
            TextFormField(
              controller: locationCtrl,
              decoration: InputDecoration(
                labelText: 'Location',
                hintText: 'e.g. Central Park',
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                  color: cs.onSurfaceVariant,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: AppTextStyles.bodyLarge.copyWith(
                color: cs.onSurface,
              ),
              validator: Validators.validateLocation,
            ),
            const Gap(16),

            // Date & Time
            DateTimeField(
              value: selectedDateTime,
              errorText: dateTimeError,
              onChanged: onDateTimeChanged,
            ),
            const Gap(16),

            // Max participants
            TextFormField(
              controller: maxParticipantsCtrl,
              decoration: InputDecoration(
                labelText: 'Max Participants',
                hintText: '2–100',
                prefixIcon: Icon(
                  Icons.group_outlined,
                  color: cs.onSurfaceVariant,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: AppTextStyles.bodyLarge.copyWith(
                color: cs.onSurface,
              ),
              keyboardType: TextInputType.number,
              validator: Validators.validateMaxParticipants,
            ),
            const Gap(16),

            // Description (optional)
            TextFormField(
              controller: descriptionCtrl,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Tell participants what to expect...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
              ),
              style: AppTextStyles.bodyLarge.copyWith(
                color: cs.onSurface,
              ),
              maxLines: 4,
              validator: Validators.validateDescription,
            ),
            const Gap(24),

            // Error message
            if (formState.errorMessage != null) ...[
              Text(
                formState.errorMessage!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: cs.error,
                ),
              ),
              const Gap(12),
            ],

            // Submit button
            PrimaryButton(
              label: isEdit ? 'Save Changes' : 'Create Activity',
              isLoading: formState.isLoading,
              onPressed: onSubmit,
            ),
            const Gap(32),
          ],
        ),
      ),
    );
  }
}
