import 'package:hive/hive.dart';
import 'package:gym_management_app/data/local/hive_boxes.dart';
import 'package:gym_management_app/data/models/goal_milestone_model.dart';

/// Lightweight wrapper around the [GoalMilestoneModel] Hive box.
///
/// Milestones live as a sub-list on [GoalModel] but are also kept in
/// this box so the celebration service can query them quickly without
/// loading every goal.
class GoalMilestoneRepository {
  Box<GoalMilestoneModel> get _box =>
      Hive.box<GoalMilestoneModel>(HiveBoxes.goalMilestones);

  List<GoalMilestoneModel> getAll() => _box.values.toList();

  List<GoalMilestoneModel> getByGoal(String goalId) =>
      _box.values.where((m) => m.goalId == goalId).toList();

  /// Returns milestones that have been achieved but not yet celebrated.
  /// Used by the dashboard to replay any missed celebrations on resume.
  List<GoalMilestoneModel> getUncelebrated() =>
      _box.values.where((m) => m.isAchieved && !m.celebrated).toList();

  Future<void> add(GoalMilestoneModel milestone) async {
    await _box.put(milestone.id, milestone);
  }

  Future<void> addAll(List<GoalMilestoneModel> milestones) async {
    final map = {for (final m in milestones) m.id: m};
    await _box.putAll(map);
  }

  Future<void> markAchieved(String id, DateTime when) async {
    final existing = _box.get(id);
    if (existing == null) return;
    if (existing.achievedAt != null) return; // already achieved — idempotent
    existing.achievedAt = when;
    await existing.save();
  }

  Future<void> markCelebrated(String id) async {
    final existing = _box.get(id);
    if (existing == null) return;
    if (existing.celebrated) return;
    existing.celebrated = true;
    await existing.save();
  }

  Future<void> deleteForGoal(String goalId) async {
    final ids = _box.values
        .where((m) => m.goalId == goalId)
        .map((m) => m.id)
        .toList();
    await _box.deleteAll(ids);
  }
}