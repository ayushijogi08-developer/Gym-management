import 'package:flutter/material.dart';
import '../../../themes/app_colors.dart';

class DietCategoryChip extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onTap;

  const DietCategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(category),
        backgroundColor: isSelected ? AppColors.primary : Colors.grey.withValues(alpha: 0.2),
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
      ),
    );
  }
}