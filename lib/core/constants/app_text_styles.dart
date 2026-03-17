import 'package:flutter/material.dart';

/// Text style tokens for Sportus.
///
/// The Inter font family is applied at the theme level via
/// `GoogleFonts.interTextTheme()` in [AppTheme]. These tokens define
/// only size and weight — the font family is inherited from the theme.
abstract final class AppTextStyles {
  static const headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static const headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const buttonLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}
