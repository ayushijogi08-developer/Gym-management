import 'package:flutter/material.dart';
import 'package:gym_management_app/data/models/goal_milestone_model.dart';
import 'package:gym_management_app/data/models/goal_model.dart';
import 'package:gym_management_app/presentation/widgets/gradient_button.dart';
import 'package:gym_management_app/themes/app_colors.dart';

/// Celebration shown when a goal crosses a milestone threshold.
///
/// Mirrors the style of `CelebrationDialog` but includes a numbered
/// milestone chip and the goal title so the user understands what they
/// just hit. Reuses the existing gradient button for the dismiss CTA.
class MilestoneCelebrationDialog extends StatelessWidget {
  final GoalModel goal;
  final GoalMilestoneModel milestone;

  const MilestoneCelebrationDialog({
    super.key,
    required this.goal,
    required this.milestone,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.background,
              AppColors.background.withValues(alpha: 0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Big number chip — communicates "what milestone?"
            Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Text(
                '${milestone.threshold.toInt()}%',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Icon(
              Icons.celebration,
              color: Colors.green,
              size: 56,
            ),
            const SizedBox(height: 8),
            const Text(
              '🎉 Milestone Reached! 🎉',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              milestone.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              goal.goalTitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${goal.progressPercentage.toStringAsFixed(0)}% complete',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Keep Going! 💪',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}