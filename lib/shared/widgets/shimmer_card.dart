import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_color_scheme.dart';

/// A skeleton loading card using shimmer animation.
///
/// Use instead of a bare `CircularProgressIndicator` for loading states.
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({this.height = 100, this.count = 1, super.key});

  /// Height of each shimmer card.
  final double height;

  /// Number of shimmer cards to display in a column.
  final int count;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorScheme>()!;
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: List.generate(count, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index < count - 1 ? 12 : 0),
          child: Shimmer.fromColors(
            baseColor: ext.shimmerBase,
            highlightColor: ext.shimmerHighlight,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outline),
              ),
            ),
          ),
        );
      }),
    );
  }
}
