import 'package:flutter/material.dart';
import '../../../themes/app_colors.dart';

class QuickReplyChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const QuickReplyChip({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Text(
          text,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        ),
      ),
    );
  }
}