import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../themes/app_colors.dart';

class SkeletonChatBubble extends StatelessWidget {
  final bool isUser;

  const SkeletonChatBubble({super.key, this.isUser = false});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.card.withValues(alpha: 0.6),
      highlightColor: AppColors.card.withValues(alpha: 0.9),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            left: isUser ? 64 : 0,
            right: isUser ? 0 : 64,
            bottom: 12,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUser ? AppColors.primary : AppColors.card,
            borderRadius: BorderRadius.circular(20),
          ),
          width: 220,
          height: 60,
        ),
      ),
    );
  }
}