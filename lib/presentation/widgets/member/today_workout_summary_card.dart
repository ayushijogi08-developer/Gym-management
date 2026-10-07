import 'package:flutter/material.dart';
import '../../../themes/app_design_tokens.dart';
import '../glass_container.dart';

class TodayWorkoutSummaryCard extends StatelessWidget {
  final String exercisesCount;
  final String completedCount;
  final double progress;
  final VoidCallback onTap;

  const TodayWorkoutSummaryCard({
    super.key,
    required this.exercisesCount,
    required this.completedCount,
    this.progress = 0.0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                const Icon(Icons.fitness_center, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Workout',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  '$completedCount/$exercisesCount',
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: context.border.withValues(alpha: 0.4),
                    color: progress >= 1.0 ? Colors.green : Colors.orange,
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(progress * 100).toInt()}%',
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