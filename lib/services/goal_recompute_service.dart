import 'package:gym_management_app/data/enums/goal_enums.dart';
import 'package:gym_management_app/data/models/goal_model.dart';
import 'package:gym_management_app/data/repositories/attendance_repository.dart';
import 'package:gym_management_app/data/repositories/body_progress_repository.dart';
import 'package:gym_management_app/data/repositories/goal_repository.dart';
import 'package:gym_management_app/data/repositories/meal_log_repository.dart';
import 'package:gym_management_app/data/repositories/workout_log_repository.dart';
import 'package:gym_management_app/domain/services/goal_metric_context.dart';
import 'package:gym_management_app/domain/services/goal_metric_service.dart';

/// Reconciles local goal state with the canonical server snapshot
/// after a sync drain. Cheap to run — only iterates active automatic
/// goals for the affected members.
///
/// Triggered by [SyncService] after every queued operation completes.
class GoalRecomputeService {
  GoalRecomputeService._();

  static final GoalRecomputeService instance = GoalRecomputeService._();

  /// Recompute a single goal from the latest sources. Idempotent:
  /// returns false if nothing changed.
  Future<bool> recomputeGoal(String goalId) async {
    final goalRepo = GoalRepository();
    final goals = goalRepo.getAllLocal();
    final goalIndex = goals.indexWhere((g) => g.id == goalId);
    if (goalIndex < 0) return false;
    final goal = goals[goalIndex];
    if (!goal.isAutomaticallyTrackable) return false;

    final ctx = _buildContext(goal.memberId);
    final previousPercent = goal.progressPercentage;
    final changed = GoalMetricService.applyAutomatic(goal, ctx);
    if (!changed) return false;

    await goalRepo.updateGoal(goal);
    await _reevaluateMilestones(goal, previousPercent);
    return true;
  }

  /// Recompute all automatic goals for a member. Used by the sync
  /// service when a body-progress entry is replayed.
  Future<void> runForMember(String memberId) async {
    final goalRepo = GoalRepository();
    final goals = goalRepo.getAllLocal();
    final autoGoals = goals
        .where((g) =>
            g.memberId == memberId &&
            g.status == GoalStatus.active &&
            g.isAutomaticallyTrackable)
        .toList();
    if (autoGoals.isEmpty) return;

    final ctx = _buildContext(memberId);

    for (final goal in autoGoals) {
      final previousPercent = goal.progressPercentage;
      final changed = GoalMetricService.applyAutomatic(goal, ctx);
      if (!changed) continue;
      await goalRepo.updateGoal(goal);
      await _reevaluateMilestones(goal, previousPercent);
    }
  }

  /// Build a [GoalMetricContext] from local Hive. The recompute
  /// service doesn't have a [BuildContext] so it reads every
  /// metric source directly from its Hive box and filters by
  /// member. This is the canonical context-builder for both the
  /// online hook (when no widget tree is mounted) and the
  /// sync-queue replay path.
  GoalMetricContext _buildContext(String memberId) {
    final bodyRepo = BodyProgressRepository();
    final workoutRepo = WorkoutLogRepository();
    final attendanceRepo = AttendanceRepository();
    final mealRepo = MealLogRepository();

    return GoalMetricContext(
      memberId: memberId,
      bodyProgressDesc: bodyRepo.getHistoryByMemberLocal(memberId),
      workoutLogs: workoutRepo
          .getAll()
          .where((l) => l.memberId == memberId)
          .toList(),
      attendance: attendanceRepo
          .getAllLocal()
          .where((a) => a.memberId == memberId)
          .toList(),
      mealLogs: mealRepo
          .getAll()
          .where((l) => l.memberId == memberId)
          .toList(),
    );
  }

  /// Stamp milestone achievement timestamps when a goal's percentage
  /// crosses a threshold. Persists via the milestone box but doesn't
  /// surface UI — celebration is owned by [GoalProvider].
  Future<void> _reevaluateMilestones(
      GoalModel goal, double previousPercent) async {
    final now = DateTime.now();
    for (final m in goal.milestones) {
      if (m.isAchieved) continue;
      if (goal.progressPercentage >= m.threshold &&
          previousPercent < m.threshold) {
        m.achievedAt = now;
      }
    }
    await goal.save();
  }
}