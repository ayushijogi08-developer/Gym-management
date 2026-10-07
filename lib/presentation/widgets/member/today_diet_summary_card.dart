import 'package:flutter/material.dart';
import '../../../themes/app_design_tokens.dart';
import '../glass_container.dart';

class TodayDietSummaryCard extends StatelessWidget {
  final String mealsCompleted;
  final String totalMeals;
  final VoidCallback onTap;

  const TodayDietSummaryCard({
    super.key,
    required this.mealsCompleted,
    required this.totalMeals,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final completedVal = double.tryParse(mealsCompleted) ?? 0.0;
    final totalVal = double.tryParse(totalMeals) ?? 1.0;
    final dietProgress = totalVal > 0 ? (completedVal / totalVal).clamp(0.0, 1.0) : 0.0;

    return GlassContainer(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant_menu, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Diet',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  '$mealsCompleted/$totalMeals',
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar for diet
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: dietProgress,
                    backgroundColor: context.border.withValues(alpha: 0.4),
                    color: Colors.green,
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(dietProgress * 100).toInt()}%',
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}