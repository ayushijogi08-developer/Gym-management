import 'package:gym_management_app/data/local/hive_boxes.dart';
import 'package:gym_management_app/data/network/api_client.dart';
import 'package:gym_management_app/data/network/api_endpoints.dart';
import '../models/workout_plan_model.dart';
import 'base_repository.dart';

class WorkoutPlanRepository extends BaseRepository<WorkoutPlanModel> {
  // Pass the Hive box name and API endpoint to the BaseRepository
  WorkoutPlanRepository() : super(HiveBoxes.workoutPlans, ApiEndpoints.workoutPlans);

List<WorkoutPlanModel> getAllLocal() => box.values.toList();

  List<WorkoutPlanModel> getActiveByMemberLocal(String memberId) =>
      box.values.where((p) => p.memberId == memberId && p.isActive).toList();

  List<WorkoutPlanModel> getByTrainerLocal(String trainerId) =>
      box.values.where((p) => p.createdByTrainerId == trainerId).toList();
      
  // GET ALL WORKOUT PLANS
  Future<List<WorkoutPlanModel>> getAll() async {
    try {
      final response = await ApiClient.get(endpoint);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => WorkoutPlanModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching workout plans: $e');
      return [];
    }
  }

  // GET BY ID
  Future<WorkoutPlanModel?> getById(String id) async {
    try {
      final response = await ApiClient.get('$endpoint/$id');
      return WorkoutPlanModel.fromJson(response.data['data']);
    } catch (e) {
      print('Error fetching workout plan: $e');
      return null;
    }
  }

  // GET ACTIVE BY MEMBER
  Future<List<WorkoutPlanModel>> getActiveByMember(String memberId) async {
    try {
      final response = await ApiClient.get('$endpoint/member/$memberId/active');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => WorkoutPlanModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching active plans for member: $e');
      return [];
    }
  }

  // GET BY TRAINER
  Future<List<WorkoutPlanModel>> getByTrainer(String trainerId) async {
    try {
      final response = await ApiClient.get('$endpoint/trainer/$trainerId');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => WorkoutPlanModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching plans by trainer: $e');
      return [];
    }
  }

 Future<void> addWorkoutPlan(WorkoutPlanModel plan) async {
    try {
      final response = await ApiClient.post(
        endpoint,
        data: plan.toJson(),  // Changed to named parameter
      );
      final serverId = response.data['data']['_id'] as String;

      if (plan.id != serverId) {
        await box.delete(plan.id);
      }

      final syncedPlan = WorkoutPlanModel(
        id: serverId,
        memberId: plan.memberId,
        createdByTrainerId: plan.createdByTrainerId,
        category: plan.category,
        exercises: plan.exercises,
        startDate: plan.startDate,
        endDate: plan.endDate,
        isActive: plan.isActive,
      );
      await box.put(serverId, syncedPlan);
    } catch (e) {
      print("❌ Error creating workout plan on server: $e");
      await add(plan, id: plan.id);
    }
  }

  // FIX: Use named parameter 'data'
  Future<void> updateWorkoutPlanRemote(WorkoutPlanModel plan) async {
    try {
      final response = await ApiClient.put(
        '$endpoint/${plan.id}',
        data: plan.toJson(),  // Changed to named parameter
      );
      print("✅ Workout plan updated on server: ${response.data}");
      await box.put(plan.id, plan);
    } catch (e) {
      print("❌ Error updating workout plan on server: $e");
      await update(plan, id: plan.id);
    }
  }

  Future<void> deleteWorkoutPlanLocal(String planId) async {
    if (box.containsKey(planId)) {
      await box.delete(planId);
      print("✅ Successfully deleted plan $planId locally");
    } else {
      print("⚠️ Plan $planId not found locally");
    }
  }
}