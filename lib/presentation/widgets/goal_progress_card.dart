import 'package:flutter/material.dart';
import 'package:gym_management_app/data/enums/goal_enums.dart';
import 'package:gym_management_app/data/models/body_progress_model.dart';
import 'package:gym_management_app/data/models/goal_model.dart';
import 'package:gym_management_app/domain/services/goal_metric_context.dart';
import 'package:gym_management_app/domain/services/goal_metric_service.dart';
import 'package:gym_management_app/themes/app_colors.dart';
import 'package:gym_management_app/themes/app_design_tokens.dart';
import 'package:gym_management_app/providers/goal_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'glass_container.dart';
import 'goal_progress_update_dialog.dart';

class GoalProgressCard extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback? onEdit;
  final bool showUpdateButton;

  /// Optional body-progress history so the card can render the latest
  /// measurement value next to the auto-sync badge. When null and the
  /// goal is automatic, the dialog will read it lazily on open.
  final List<BodyProgressModel>? bodyProgressHistory;

  /// NEW: optional callback invoked when the user confirms deletion in
  /// the confirmation dialog. When null, the delete button is hidden so
  /// the card can be reused in screens that don't support deletion.
  final VoidCallback? onDelete;

  const GoalProgressCard({
    super.key,
    required this.goal,
    this.onEdit,
    this.showUpdateButton = true,
    this.bodyProgressHistory,
    this.onDelete, // NEW
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal.progressPercentage;
    final isCompleted = goal.isCompleted;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            goal.goalTitle,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (goal.isAutomaticallyTrackable) ...[
                          const SizedBox(width: 6),
                          _buildAutoBadge(context),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${goal.currentValue.toStringAsFixed(1)} / ${goal.targetValue.toStringAsFixed(1)} ${goal.unit}',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Flexible(
                fit: FlexFit.loose,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green.withValues(alpha: 0.2) : Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCompleted ? Colors.green : Colors.amber,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isCompleted ? '✅ Completed' : '${progress.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: isCompleted ? Colors.green : Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          LinearProgressIndicator(
            value: (progress / 100).clamp(0.0, 1.0),
            backgroundColor: context.border.withValues(alpha: 0.4),
            color: isCompleted ? Colors.green : AppColors.primary,
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),

          // Milestone strip — show celebrated milestones as small chips.
          if (goal.milestones.any((m) => m.isAchieved))
            _buildMilestoneStrip(context),

          // Target Date & Actions
          Row(
            children: [
              if (goal.targetDate != null)
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: context.textSecondary,
                ),
              if (goal.targetDate != null)
                const SizedBox(width: 4),
              if (goal.targetDate != null)
                Flexible(
                  flex: 2,
                  fit: FlexFit.loose,
                  child: Text(
                    'By ${goal.targetDate!.toString().split(' ')[0]}',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
              const Spacer(),
              // Update Progress Button
              if (showUpdateButton && !isCompleted)
                _buildActionButton(
                  context,
                  icon: goal.isAutomaticallyTrackable
                      ? Icons.auto_awesome
                      : Icons.trending_up,
                  label: 'Update',
                  color: Colors.blue,
                  onTap: () => _showUpdateDialog(context),
                ),
              const SizedBox(width: 8),
              // Edit Button
              if (onEdit != null)
                _buildActionButton(
                  context,
                  icon: Icons.edit,
                  label: 'Edit',
                  color: Colors.amber,
                  onTap: onEdit!,
                ),
              // NEW: Delete Button (only when the screen supplied a handler)
              if (onDelete != null) ...[
                const SizedBox(width: 8),
                _buildActionButton(
                  context,
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  color: Colors.red,
                  onTap: () => _confirmAndDelete(context),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// NEW: show a confirmation dialog before invoking [onDelete]. Guards
  /// against accidental taps by requiring an explicit "Delete" tap.
  Future<void> _confirmAndDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete goal?'),
        content: const Text(
          'Are you sure you want to delete this goal? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      onDelete?.call();
    }
  }

  Widget _buildAutoBadge(BuildContext context) {
    return Tooltip(
      message: 'Auto-tracked from your body progress logs',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 10, color: AppColors.primary),
            const SizedBox(width: 3),
            Text(
              'AUTO',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneStrip(BuildContext context) {
    // Show all milestones, dimmed when not yet achieved.
    final achieved = goal.milestones.where((m) => m.isAchieved).toList();
    if (achieved.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: achieved.map((m) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flag, size: 10, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  '${m.threshold.toInt()}%',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateDialog(BuildContext context) async {
    // Build a metric context from the providers so we can show the
    // latest source value when the goal is automatic. Falls back to
    // a body-progress-only context if the caller passed a history.
    double? latestValue;
    final GoalMetricContext metricCtx;
    if (bodyProgressHistory != null) {
      metricCtx = GoalMetricContext(
        memberId: goal.memberId,
        bodyProgressDesc: bodyProgressHistory!,
        workoutLogs: const [],
        attendance: const [],
        mealLogs: const [],
      );
    } else {
      metricCtx = GoalMetricContext.fromProviders(
        context,
        memberId: goal.memberId,
      );
    }
    latestValue = GoalMetricService.pickLatestValue(goal, metricCtx);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => GoalProgressUpdateDialog(
        goal: goal,
        latestBodyProgressValue: latestValue,
      ),
    );

    if (result == null || !context.mounted) return;

    // Automatic goal path: route the user to the body-progress form so
    // they can log a measurement that will auto-update the goal.
    if (result['navigateTo'] is String) {
      context.push(result['navigateTo'] as String);
      return;
    }

    // Manual goal path: update currentValue and persist.
    final goalProvider = context.read<GoalProvider>();
    final newNotes = result['notes'] as String?;
    final updatedGoal = GoalModel(
      id: goal.id,
      memberId: goal.memberId,
      goalType: goal.goalType,
      goalTitle: goal.goalTitle,
      targetValue: goal.targetValue,
      currentValue: result['currentValue'] as double,
      unit: goal.unit,
      startDate: goal.startDate,
      targetDate: goal.targetDate,
      priority: goal.priority,
      status: result['currentValue'] >= goal.targetValue
          ? GoalStatus.completed
          : goal.status,
      trainerNotes: goal.trainerNotes,
      memberNotes: newNotes ?? goal.memberNotes,
      trackingMode: goal.trackingMode,
      startingValue: goal.startingValue,
      remainingValue: goal.remainingValue,
      progressPercentage: goal.progressPercentage,
      completedAt: goal.completedAt,
      milestones: goal.milestones,
      notes: newNotes ?? goal.notes,
      metricKind: goal.metricKind,
    );

    await goalProvider.updateGoal(updatedGoal);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progress updated successfully!')),
      );
    }
  }
}
