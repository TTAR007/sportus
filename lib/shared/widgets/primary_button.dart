import 'package:flutter/material.dart';

import '../../core/constants/app_text_styles.dart';

/// A full-width primary action button.
///
/// Height: 52px, radius: 12px, uses `cs.primary` / `cs.onPrimary`.
/// Shows a small loading indicator when [isLoading] is true.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          disabledBackgroundColor: cs.primary.withAlpha(128),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(cs.onPrimary),
                ),
              )
            : Text(
                label,
                style: AppTextStyles.buttonLabel.copyWith(
                  color: cs.onPrimary,
                ),
              ),
      ),
    );
  }
}
