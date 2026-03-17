import 'package:flutter/material.dart';

@immutable
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  const AppColorScheme({
    required this.success,
    required this.onSuccess,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  final Color success;
  final Color onSuccess;
  final Color shimmerBase;
  final Color shimmerHighlight;

  static const light = AppColorScheme(
    success: Color(0xFF16A34A),
    onSuccess: Color(0xFFFFFFFF),
    shimmerBase: Color(0xFFE2E8F0),
    shimmerHighlight: Color(0xFFF8FAFC),
  );

  static const dark = AppColorScheme(
    success: Color(0xFF4ADE80),
    onSuccess: Color(0xFF0F172A),
    shimmerBase: Color(0xFF1E293B),
    shimmerHighlight: Color(0xFF2D3F55),
  );

  @override
  AppColorScheme copyWith({
    Color? success,
    Color? onSuccess,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) =>
      AppColorScheme(
        success: success ?? this.success,
        onSuccess: onSuccess ?? this.onSuccess,
        shimmerBase: shimmerBase ?? this.shimmerBase,
        shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      );

  @override
  AppColorScheme lerp(AppColorScheme? other, double t) {
    if (other == null) return this;
    return AppColorScheme(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
    );
  }
}
