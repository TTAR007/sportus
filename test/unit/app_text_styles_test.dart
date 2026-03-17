import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportus/core/constants/app_text_styles.dart';

void main() {
  group('AppTextStyles', () {
    test('headingLarge has size 24 and weight 700', () {
      expect(AppTextStyles.headingLarge.fontSize, 24);
      expect(AppTextStyles.headingLarge.fontWeight, FontWeight.w700);
    });

    test('headingMedium has size 20 and weight 600', () {
      expect(AppTextStyles.headingMedium.fontSize, 20);
      expect(AppTextStyles.headingMedium.fontWeight, FontWeight.w600);
    });

    test('bodyLarge has size 16 and weight 400', () {
      expect(AppTextStyles.bodyLarge.fontSize, 16);
      expect(AppTextStyles.bodyLarge.fontWeight, FontWeight.w400);
    });

    test('bodyMedium has size 14 and weight 400', () {
      expect(AppTextStyles.bodyMedium.fontSize, 14);
      expect(AppTextStyles.bodyMedium.fontWeight, FontWeight.w400);
    });

    test('labelSmall has size 12 and weight 500', () {
      expect(AppTextStyles.labelSmall.fontSize, 12);
      expect(AppTextStyles.labelSmall.fontWeight, FontWeight.w500);
    });
  });
}
