import 'package:gym_management_app/data/local/hive_boxes.dart';
import 'package:gym_management_app/data/network/api_client.dart';
import 'package:gym_management_app/data/network/api_endpoints.dart';
import 'package:gym_management_app/data/repositories/goal_milestone_repository.dart';
import '../models/goal_model.dart';
import 'base_repository.dart';

class GoalRepository extends BaseRepository<GoalModel> {
  // Pass the Hive box name and API endpoint to the BaseRepository
  GoalRepository() : super(HiveBoxes.goals, ApiEndpoints.goals);

  /// Creates a goal optimistically: write to Hive first, then push to the
  /// server. If the server call fails, the row is queued via
  /// [SyncQueueRepository] so the operation replays on next sync.
  ///
  /// Pre-refactor this method overrode [BaseRepository.add] with an
  /// API-first flow that bypassed the offline-first contract; we now
  /// inherit the optimistic behavior from [BaseRepository] directly.
  ///
  /// NOTE: We don't override `add` here. Milestones are attached to the
  /// goal's [GoalModel.milestones] sub-list and persisted as part of the
  /// goal record itself.

  List<GoalModel> getAllLocal() => box.values.toList();

  List<GoalModel> getActiveByMemberLocal(String memberId) =>
      box.values.where((g) => g.memberId == memberId && g.status == 'active').toList();

  List<GoalModel> getCompletedByMemberLocal(String memberId) =>
      box.values.where((g) => g.memberId == memberId && g.status == 'completed').toList();

  // --- API fetch methods ---

  Future<List<GoalModel>> getAll() async {
    try {
      final response = await ApiClient.get(endpoint);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => GoalModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching all goals: $e');
      return [];
    }
  }

  Future<List<GoalModel>> getActiveByMember(String memberId) async {
    try {
      final response = await ApiClient.get('$endpoint/member/$memberId/active');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => GoalModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching active goals: $e');
      return [];
    }
  }

  Future<List<GoalModel>> getCompletedByMember(String memberId) async {
    try {
      final response = await ApiClient.get('$endpoint/member/$memberId/completed');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => GoalModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching completed goals: $e');
      return [];
    }
  }

  // --- CRUD wrappers (use BaseRepository's optimistic + queue logic) ---

  Future<void> addGoal(GoalModel goal) async {
    // Optimistic: write locally, then push; queue on failure.
    await add(goal, id: goal.id);
  }

  Future<void> updateGoal(GoalModel goal) async {
    // Optimistic: write locally, then push; queue on failure.
    await update(goal, id: goal.id);
  }

  Future<void> deleteGoal(String id) async {
    // BaseRepository.delete also removes the record from the local box
    // and queues the API call if it fails. We additionally clean up any
    // milestones attached to the goal so they don't linger as ghosts.
    try {
      await GoalMilestoneRepository().deleteForGoal(id);
    } catch (e) {
      print('⚠️ Failed to delete milestones for goal $id: $e');
    }
    await delete(id);
  }

  /// Imports a goal record verbatim (used by backup restore + sync).
  /// Bypasses the API push so the caller can opt to batch-push later.
  Future<void> importGoal(GoalModel goal) async {
    await box.put(goal.id, goal);
  }
}