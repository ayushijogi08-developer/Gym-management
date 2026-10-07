import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../themes/app_colors.dart';

class SkeletonCard extends StatelessWidget {
  final double height;

  const SkeletonCard({super.key, this.height = 80});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.card.withValues(alpha: 0.6),
      highlightColor: AppColors.card.withValues(alpha: 0.9),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}