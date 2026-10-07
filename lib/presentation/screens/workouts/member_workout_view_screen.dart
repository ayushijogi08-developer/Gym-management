import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/workout_plan_provider.dart';
import '../../../providers/workout_log_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../../themes/app_spacing.dart';
import '../../widgets/exercise_card.dart';
import '../../widgets/completion_progress_bar.dart';

class MemberWorkoutViewScreen extends StatefulWidget {
  const MemberWorkoutViewScreen({super.key});

  @override
  State<MemberWorkoutViewScreen> createState() =>
      _MemberWorkoutViewScreenState();
}

class _MemberWorkoutViewScreenState extends State<MemberWorkoutViewScreen> {
  Set<String> _completedExercises = {};

  @override
  void initState() {
    super.initState();
    _loadCompletedExercises();
  }

  void _loadCompletedExercises() {
    final auth = context.read<AuthProvider>();
    final logProvider = context.read<WorkoutLogProvider>();
    final memberId = auth.currentUser?.linkedMemberId ?? '';
    final plan =
        context.read<WorkoutPlanProvider>().getActiveForMember(memberId);

    if (plan != null) {
      final today = DateTime.now();
      final logs = logProvider.getForDate(memberId, today);

      setState(() {
        _completedExercises = logs
            .where((log) =>
                log.workoutPlanId == plan.id && log.status == 'completed')
            .map((log) => log.exerciseName)
            .toSet();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final workoutProvider = context.watch<WorkoutPlanProvider>();
    final logProvider = context.watch<WorkoutLogProvider>();

    final memberId = auth.currentUser?.linkedMemberId ?? '';
    final plan = workoutProvider.getActiveForMember(memberId);

    if (plan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Today\'s Workout')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.surfaceAlt,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fitness_center_outlined,
                    size: 44,
                    color: context.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No Workout Plan Assigned',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Contact your trainer to get a workout plan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final totalCount = plan.exercises.length;
    final completedCount = _completedExercises.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    final allCompleted = completedCount == totalCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Workout'),
        actions: [
          if (allCompleted)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.celebration_rounded,
                          color: AppColors.success, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Done',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Header
          Text(
            'Today',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Progress Bar
          CompletionProgressBar(
            progress: progress,
            title: "Workout Completion",
            subtitle:
                "$completedCount out of $totalCount exercises completed today",
            progressColor:
                allCompleted ? AppColors.success : AppColors.primary,
          ),

          const SizedBox(height: AppSpacing.lg),

          // All Completed Message
          if (allCompleted) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.celebration_rounded,
                      color: AppColors.success, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '🎉 Congratulations! You\'ve completed all exercises!',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Exercises List
          ...plan.exercises.map((exercise) {
            final isCompleted =
                _completedExercises.contains(exercise.exerciseName);

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ExerciseCard(
                exercise: exercise,
                isCompleted: isCompleted,
                onMarkCompleted: () async {
                  await logProvider.markExerciseCompleted(
                    memberId,
                    plan.id,
                    exercise.exerciseName,
                    DateTime.now(),
                    context,
                  );

                  if (mounted) {
                    setState(() {
                      _completedExercises.add(exercise.exerciseName);
                    });
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
