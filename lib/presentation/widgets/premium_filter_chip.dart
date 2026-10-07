import 'package:flutter/material.dart';
import 'package:gym_management_app/themes/app_colors.dart';
import 'package:gym_management_app/themes/app_design_tokens.dart';

/// Pill-shaped filter chip that adapts to the active theme.
class PremiumFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;

  const PremiumFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = selectedColor ?? AppColors.primary;
    final unselectedText = AppColors.textPrimaryOf(context);
    final unselectedBorder = AppColors.borderOf(context);
    final unselectedFill = AppColors.surfaceAltOf(context);
    final selectedText = accent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.base,
        curve: AppMotion.ease,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withValues(alpha: 0.12)
              : unselectedFill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? accent : unselectedBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? selectedText : unselectedText,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}