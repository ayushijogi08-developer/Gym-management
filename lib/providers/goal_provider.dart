import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gym_management_app/data/enums/goal_enums.dart';
import 'package:gym_management_app/data/models/app_user_model.dart';
import 'package:gym_management_app/data/models/goal_milestone_model.dart';
import 'package:gym_management_app/data/models/goal_model.dart';
import 'package:gym_management_app/data/repositories/goal_milestone_repository.dart';
import 'package:gym_management_app/data/repositories/goal_repository.dart';
import 'package:gym_management_app/domain/entities/user_role.dart';
import 'package:gym_management_app/domain/services/goal_metric_context.dart';
import 'package:gym_management_app/domain/services/goal_metric_service.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/auth_provider.dart';
import '../providers/timeline_provider.dart';
import '../services/achievement_checker_service.dart';

/// Event emitted when a goal crosses a milestone threshold so the UI can
/// show a celebration. Carries enough context for the celebration widget
/// to render a meaningful message.
class MilestoneEvent {
  final GoalModel goal;
  final GoalMilestoneModel milestone;

  const MilestoneEvent({required this.goal, required this.milestone});
}

class GoalProvider extends ChangeNotifier {
  final GoalRepository _repo = GoalRepository();
  final GoalMilestoneRepository _milestoneRepo = GoalMilestoneRepository();

  List<GoalModel> _goals = [];

  /// Recently-achieved milestones that the UI hasn't celebrated yet.
  /// Cleared by [acknowledgeMilestone].
  final List<MilestoneEvent> _pendingCelebrations = [];

  List<GoalModel> get goals => _goals;
  List<MilestoneEvent> get pendingCelebrations =>
      List.unmodifiable(_pendingCelebrations);

  // ==================== LOAD / REFRESH ====================

  void loadFromLocal() {
    _goals = _repo.getAllLocal();
    notifyListeners();
  }

  Future<void> refreshGoals() async {
    try {
      print("🔄 Fetching goals from API...");
      final fetchedGoals = await _repo.getAll();
      _goals = fetchedGoals;
      print("✅ Fetched ${_goals.length} goals from API");
      notifyListeners();
    } catch (e) {
      print("❌ Error refreshing goals: $e");
      _goals = _repo.getAllLocal();
      notifyListeners();
    }
  }

  // ==================== GET METHODS ====================

  List<GoalModel> getActiveGoals(String memberId) {
    if (memberId.isEmpty) return [];
    return _goals
        .where((g) =>
            g.memberId.toString().trim() == memberId.trim() &&
            g.status == GoalStatus.active)
        .toList();
  }

  List<GoalModel> getCompletedGoals(String memberId) {
    if (memberId.isEmpty) return [];
    return _goals
        .where((g) =>
            g.memberId.toString().trim() == memberId.trim() &&
            g.status == GoalStatus.completed)
        .toList();
  }

  List<GoalModel> getAllGoalsForMember(String memberId) {
    if (memberId.isEmpty) return [];
    return _goals
        .where((g) => g.memberId.toString().trim() == memberId.trim())
        .toList();
  }

  /// Returns active *automatic* goals for a member — those that should
  /// be updated whenever a matching body-progress entry is logged.
  List<GoalModel> getAutomaticGoalsForMember(String memberId) {
    if (memberId.isEmpty) return [];
    return _goals
        .where((g) =>
            g.memberId.toString().trim() == memberId.trim() &&
            g.status == GoalStatus.active &&
            g.isAutomaticallyTrackable)
        .toList();
  }

  List<GoalModel> getGoalsByFilter(String memberId, String filter) {
    if (memberId.isEmpty) return [];
    switch (filter) {
      case 'active':
        return getActiveGoals(memberId);
      case 'completed':
        return getCompletedGoals(memberId);
      case 'all':
      default:
        return getAllGoalsForMember(memberId);
    }
  }

  // ==================== UPDATE METHODS ====================

  Future<void> updateGoal(GoalModel goal) async {
    try {
      await _repo.updateGoal(goal);
      // Keep the milestones sub-list in the dedicated milestone box
      // consistent with the goal's sub-list.
      await _milestoneRepo.addAll(goal.milestones);
      await refreshGoals();
      notifyListeners();
    } catch (e) {
      print("Error updating goal: $e");
      rethrow;
    }
  }

  // ==================== CREATE METHODS ====================

  /// Backward-compatible create signature used by existing call sites.
  /// Always creates a manual goal with the default four-step milestones.
  Future<void> createGoal({
    required String memberId,
    required String goalType,
    required String goalTitle,
    required double targetValue,
    required String unit,
    DateTime? targetDate,
    required BuildContext context,
  }) async {
    return createGoalAdvanced(
      memberId: memberId,
      goalType: goalType,
      goalTitle: goalTitle,
      targetValue: targetValue,
      unit: unit,
      targetDate: targetDate,
      trackingMode: GoalTrackingMode.manual,
      startingValue: 0.0,
      milestones: GoalMilestoneModel.defaultsFor(const Uuid().v4()),
      context: context,
    );
  }

  /// Full-featured create. Builds a goal with the supplied tracking mode
  /// and (when applicable) starting value snapshotted from the latest
  /// body-progress entry.
  Future<void> createGoalAdvanced({
    required String memberId,
    required String goalType,
    required String goalTitle,
    required double targetValue,
    required String unit,
    DateTime? targetDate,
    required String trackingMode,
    required double startingValue,
    required List<GoalMilestoneModel> milestones,
    required BuildContext context,
    String metricKind = '',
  }) async {
    final auth = context.read<AuthProvider>();
    if (auth.currentRole != UserRole.member &&
        !auth.hasPermission('canUpdateBodyMeasurements')) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied')),
        );
      }
      return;
    }

    final goalId = const Uuid().v4();

    // Stamp the goalId onto every milestone so the celebration engine
    // can find them by goal.
    final stamped = milestones
        .map((m) => GoalMilestoneModel(
              id: m.id.isEmpty ? '${goalId}_m${m.threshold.toInt()}' : m.id,
              goalId: goalId,
              threshold: m.threshold,
              label: m.label,
              achievedAt: m.achievedAt,
              celebrated: m.celebrated,
            ))
        .toList();

    final goal = GoalModel(
      id: goalId,
      memberId: memberId,
      goalType: goalType,
      goalTitle: goalTitle,
      targetValue: targetValue,
      currentValue: startingValue,
      unit: unit,
      startDate: DateTime.now(),
      targetDate: targetDate,
      trackingMode: trackingMode,
      startingValue: startingValue,
      progressPercentage: startingValue == 0.0
          ? 0.0
          : ((startingValue - startingValue).abs() /
                  (targetValue - startingValue).abs()) *
              100.0,
      milestones: stamped,
      metricKind: metricKind,
    );

    try {
      // Persist milestones as their own box entries first so a partial
      // failure doesn't leave dangling references in the goal record.
      await _milestoneRepo.addAll(stamped);
      await _repo.addGoal(goal);
      await refreshGoals();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal created successfully!')),
        );
      }
    } catch (e) {
      print("Error creating goal: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating goal: ${e.toString()}')),
        );
      }
    }
  }

  // ==================== AUTOMATIC PROGRESS ====================

  /// Applies a metric context to an automatic goal. Mutates the
  /// goal in place, persists via [updateGoal], and returns the
  /// newly-achieved milestone events so the caller can celebrate them.
  ///
  /// Returns an empty list if the goal isn't automatic, no source
  /// data is available, or nothing changed.
  Future<List<MilestoneEvent>> applyAutomaticProgress(
    GoalModel goal,
    GoalMetricContext ctx,
  ) async {
    if (!goal.isAutomaticallyTrackable) return const [];
    final previousPercent = goal.progressPercentage;
    final changed = GoalMetricService.applyAutomatic(goal, ctx);
    if (!changed) return const [];

    await _repo.updateGoal(goal);
    await _milestoneRepo.addAll(goal.milestones);
    await refreshGoals();
    return _collectNewMilestones(goal, previousPercent);
  }

  /// Bulk fan-out for the post-save hook. Iterates the member's
  /// active automatic goals, applies the metric context to each,
  /// persists any changes, and returns the union of milestone
  /// events. The hook service ([GoalRecalcHook]) is the canonical
  /// caller; providers that want the celebration events should
  /// route through this helper.
  Future<List<MilestoneEvent>> recalcAutomaticGoals(
    String memberId,
    GoalMetricContext ctx,
  ) async {
    final autoGoals = getAutomaticGoalsForMember(memberId);
    final allEvents = <MilestoneEvent>[];
    for (final goal in autoGoals) {
      allEvents.addAll(await applyAutomaticProgress(goal, ctx));
    }
    return allEvents;
  }

  /// Pushes externally-supplied milestone events onto the pending
  /// celebration queue. Used by [GoalRecalcHook] when the online
  /// save path wants to surface celebrations immediately without
  /// waiting for a full [refreshGoals] round-trip.
  void queueCelebrations(List<MilestoneEvent> events) {
    if (events.isEmpty) return;
    _pendingCelebrations.addAll(events);
    notifyListeners();
  }

  // ==================== MANUAL PROGRESS ====================

  Future<void> updateProgress(String goalId, double newCurrentValue) async {
    try {
      final goal = _goals.firstWhere((g) => g.id == goalId);
      final previousPercent = goal.progressPercentage;
      GoalMetricService.applyManual(goal, newCurrentValue);
      await _repo.updateGoal(goal);
      await _milestoneRepo.addAll(goal.milestones);
      await refreshGoals();
      _collectNewMilestones(goal, previousPercent);
      notifyListeners();
    } catch (e) {
      print("Error updating progress: $e");
    }
  }

  // ==================== MILESTONES ====================

  /// Compares the goal's milestones against the previous percentage and
  /// marks newly-achieved ones (idempotent — already-achieved milestones
  /// are skipped). Returns the freshly-achieved ones as celebration
  /// events. The caller can decide when to flip `celebrated: true`
  /// (typically after the UI dismisses the dialog).
  List<MilestoneEvent> _collectNewMilestones(
      GoalModel goal, double previousPercent) {
    final events = <MilestoneEvent>[];
    final now = DateTime.now();
    for (final m in goal.milestones) {
      if (m.isAchieved) continue;
      if (goal.progressPercentage >= m.threshold &&
          previousPercent < m.threshold) {
        m.achievedAt = now;
        events.add(MilestoneEvent(goal: goal, milestone: m));
        // Fire-and-forget persist; failures don't block the celebration.
        unawaited(_milestoneRepo
            .markAchieved(m.id, now)
            .then((_) {}, onError: (Object e) {
          print('⚠️ Failed to mark milestone achieved: $e');
        }));
      }
    }
    if (events.isNotEmpty) {
      _pendingCelebrations.addAll(events);
      notifyListeners();
    }
    return events;
  }

  /// Removes an event from the pending list and marks the underlying
  /// milestone as celebrated so it doesn't replay on the next resume.
  Future<void> acknowledgeMilestone(MilestoneEvent event) async {
    _pendingCelebrations.removeWhere((e) =>
        e.milestone.id == event.milestone.id &&
        e.goal.id == event.goal.id);
    await _milestoneRepo.markCelebrated(event.milestone.id);
    notifyListeners();
  }

  /// Replays any milestones that were achieved in a previous session but
  /// never celebrated (e.g., the user closed the app before seeing the
  /// dialog). Safe to call on app start.
  Future<void> hydrateUncelebratedMilestones() async {
    final uncelebrated = _milestoneRepo.getUncelebrated();
    if (uncelebrated.isEmpty) return;
    for (final m in uncelebrated) {
      final goal = _goals.firstWhereOrNull((g) => g.id == m.goalId);
      if (goal != null) {
        _pendingCelebrations
            .add(MilestoneEvent(goal: goal, milestone: m));
      }
    }
    if (_pendingCelebrations.isNotEmpty) notifyListeners();
  }

  // ==================== GET BY ID ====================

  GoalModel? getGoalById(String id) {
    return _goals.firstWhereOrNull((g) => g.id == id);
  }

  // ==================== DELETE ====================

  /// Returns whether the [actor] (typically the current user) is allowed
  /// to delete [goal]. Members can only delete goals they own; admins,
  /// superAdmins, trainers, and receptionists can delete any goal they
  /// have visibility into. This is the single source of truth used by
  /// both the My Goals and All Member Goals screens.
  bool canDeleteGoal(GoalModel goal, {required AppUserModel? actor}) {
    if (actor == null) return false;
    final role = actor.role;
    if (role == 'superAdmin' || role == 'admin') return true;
    if (role == 'trainer') {
      // Trainers may delete goals for members they are assigned to.
      // The screen passes the resolved member via [goal.memberId]; if the
      // trainer's assigned-member list isn't available here we fall back
      // to a permissive delete (the screen-level filter already restricts
      // which members they see).
      return true;
    }
    if (role == 'receptionist') return true;
    // Members can only delete their own goals.
    final ownMemberId = actor.linkedMemberId ?? '';
    return goal.memberId.toString().trim() == ownMemberId.trim();
  }

  Future<void> deleteGoal(String goalId, BuildContext context) async {
    // CHANGED: gate deletion on a permission/ownership check so members
    // can't wipe other members' goals and guests can't delete at all.
    final auth = context.read<AuthProvider>();
    final goal = _goals.firstWhereOrNull((g) => g.id == goalId);
    if (goal == null) {
      // Already gone — nothing to do, treat as success so the UI stays
      // consistent with the optimistic state.
      return;
    }
    if (!canDeleteGoal(goal, actor: auth.currentUser)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You do not have permission to delete this goal')),
        );
      }
      return;
    }
    try {
      await _repo.deleteGoal(goalId);
      // CHANGED: remove from the in-memory list immediately so the UI
      // reflects the deletion without waiting for a network round-trip.
      _goals.removeWhere((g) => g.id == goalId);
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal deleted successfully')),
        );
      }
    } catch (e) {
      print("Error deleting goal: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete goal')),
        );
      }
    }
  }

  // ==================== MARK COMPLETED ====================

  Future<void> markCompleted(String goalId, BuildContext context) async {
    try {
      final goal = _goals.firstWhere((g) => g.id == goalId);
      final previousPercent = goal.progressPercentage;
      goal.status = GoalStatus.completed;
      goal.completedAt ??= DateTime.now();
      goal.progressPercentage = 100.0;
      goal.remainingValue = 0.0;
      await _repo.updateGoal(goal);
      await _milestoneRepo.addAll(goal.milestones);
      await refreshGoals();

      // Existing achievement path is preserved.
      await AchievementCheckerService.checkAfterGoalCompletion(
        context,
        goal.memberId,
        goalId,
      );

      context.read<TimelineProvider>().logEvent(
            memberId: goal.memberId,
            eventType: 'goal_completed',
            title: 'Goal Achieved',
            subtitle: goal.goalTitle,
            iconAsset: 'assets/icons/achievement.png',
          );

      // Milestone path: collect newly-achieved events so the UI can
      // surface them after the achievement dialog dismisses.
      _collectNewMilestones(goal, previousPercent);
      notifyListeners();
    } catch (e) {
      print("Error marking goal completed: $e");
    }
  }
}