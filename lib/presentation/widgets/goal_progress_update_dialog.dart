import 'package:flutter/material.dart';
import 'package:gym_management_app/data/models/goal_model.dart';
import 'package:gym_management_app/themes/app_colors.dart';
import 'package:gym_management_app/themes/app_design_tokens.dart';
import 'app_text_field.dart';
import 'gradient_button.dart';

class GoalProgressUpdateDialog extends StatefulWidget {
  final GoalModel goal;
  /// Optional latest body-progress value. When supplied, the dialog
  /// shows it for automatic goals instead of a free-form input.
  final double? latestBodyProgressValue;

  const GoalProgressUpdateDialog({
    super.key,
    required this.goal,
    this.latestBodyProgressValue,
  });

  @override
  State<GoalProgressUpdateDialog> createState() => _GoalProgressUpdateDialogState();
}

class _GoalProgressUpdateDialogState extends State<GoalProgressUpdateDialog> {
  final TextEditingController _currentValueController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentValueController.text = widget.goal.currentValue.toString();
  }

  @override
  void dispose() {
    _currentValueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _isAutomatic => widget.goal.isAutomaticallyTrackable;

  @override
  Widget build(BuildContext context) {
    final remaining = widget.goal.computedRemainingValue;
    final progress = widget.goal.progressPercentage;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: context.surface,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.edit, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Update Progress',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: context.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Goal Info Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.goal.goalTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Target: ${widget.goal.targetValue} ${widget.goal.unit}',
                        style: TextStyle(color: context.textSecondary),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Progress: ${progress.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: widget.goal.isCompleted
                              ? Colors.green
                              : Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Remaining: ${remaining.toStringAsFixed(1)} ${widget.goal.unit}',
                    style: TextStyle(color: context.textSecondary),
                  ),
                  if (_isAutomatic) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Auto-synced from body progress',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Progress Bar
            LinearProgressIndicator(
              value: (progress / 100).clamp(0.0, 1.0),
              backgroundColor: context.border.withValues(alpha: 0.4),
              color: widget.goal.isCompleted
                  ? Colors.green
                  : AppColors.primary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 20),

            if (_isAutomatic) _buildAutomaticBody(context)
            else _buildManualBody(context),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 44),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: context.textPrimary),
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GradientButton(
                    label: _isAutomatic ? 'Go Log Entry' : 'Update Progress',
                    onPressed: _onPrimaryAction,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Body for automatic goals: show the latest body-progress value
  /// (read-only) and steer the user toward logging a new measurement.
  Widget _buildAutomaticBody(BuildContext context) {
    final latest = widget.latestBodyProgressValue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Latest measurement',
          style: TextStyle(
            color: context.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: context.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.monitor_weight_outlined,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  latest != null
                      ? '${latest.toStringAsFixed(1)} ${widget.goal.unit}'
                      : 'No measurement yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Progress updates automatically when you log a new body measurement. '
          'Tap "Go Log Entry" to record one now.',
          style: TextStyle(
            color: context.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Notes (Optional)',
          controller: _notesController,
          maxLines: 2,
        ),
      ],
    );
  }

  /// Body for manual goals: free-form current-value input + notes.
  Widget _buildManualBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Current Value (${widget.goal.unit})',
          controller: _currentValueController,
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v?.isEmpty ?? true) return 'Required';
            if (double.tryParse(v!) == null) return 'Invalid number';
            return null;
          },
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Notes (Optional)',
          controller: _notesController,
          maxLines: 2,
        ),
      ],
    );
  }

  void _onPrimaryAction() {
    if (_isAutomatic) {
      // Automatic goals don't take a typed value — close the dialog and
      // let the caller route the user to the body-progress form. We
      // surface a `navigateTo` flag so callers (typically
      // `GoalProgressCard`) can push `/add-progress-entry`.
      Navigator.pop(context, {
        'navigateTo': '/add-progress-entry',
        'goalId': widget.goal.id,
        'notes': _notesController.text.trim(),
      });
      return;
    }

    final value = double.tryParse(_currentValueController.text);
    if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number')),
      );
      return;
    }

    Navigator.pop(context, {
      'currentValue': value,
      'notes': _notesController.text.trim(),
    });
  }
}
