import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gym_management_app/data/models/exercise_model.dart';
import 'package:gym_management_app/data/network/api_client.dart';
import 'package:gym_management_app/data/network/api_endpoints.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../data/models/workout_plan_model.dart';
import '../data/repositories/workout_plan_repository.dart';
import '../providers/auth_provider.dart';

class WorkoutPlanProvider extends ChangeNotifier {
  final WorkoutPlanRepository _repo = WorkoutPlanRepository();

  List<WorkoutPlanModel> getAll() => _repo.getAllLocal();

  WorkoutPlanModel? getActiveForMember(String memberId) {
    return _repo.getActiveByMemberLocal(memberId).firstOrNull;
  }

  List<WorkoutPlanModel> getByTrainer(String trainerId) => _repo.getByTrainerLocal(trainerId);

// Update the getByMember method to properly handle the response
Future<List<WorkoutPlanModel>> getByMember(String memberId) async {
  try {
    print("🌐 API Call: GET /workout-plans/member/$memberId");
    
    final response = await ApiClient.get('${ApiEndpoints.workoutPlans}/member/$memberId');
    
    print("API Response Status: ${response.statusCode}");
    print("API Response Data: ${response.data}");

    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'] ?? [];
      final plans = data.map((json) => WorkoutPlanModel.fromJson(json)).toList();
      
      // Save to local storage
      for (var plan in plans) {
        await _repo.addWorkoutPlan(plan);
      }
      
      print("✅ Successfully loaded ${plans.length} workout plans");
      notifyListeners();
      return plans;
    } else {
      print("❌ API returned error: ${response.data['message']}");
      return [];
    }
  } catch (e) {
    print("❌ Error fetching workout plans for member: $e");
    if (e is DioException) {
      print("Dio Error Response: ${e.response?.data}");
    }
    return _repo.getActiveByMemberLocal(memberId);
  }
}
  Future<void> createWorkoutPlan({
    required String memberId,
    required String category,
    required List<ExerciseModel> exercises,
    required BuildContext context,
  }) async {
    final auth = context.read<AuthProvider>();
    if (!auth.hasPermission('canEditWorkoutPlans')) return;

    final plan = WorkoutPlanModel(
      id: const Uuid().v4(),
      memberId: memberId,
      createdByTrainerId: auth.currentUser?.linkedTrainerId ?? '',
      category: category,
      exercises: exercises,
      startDate: DateTime.now(),
      isActive: true,
    );

    await _repo.addWorkoutPlan(plan);
    notifyListeners();
  }

  WorkoutPlanModel? getById(String id) {
    try {
      return _repo.getAllLocal().firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateWorkoutPlan({
    required String planId,
    required String memberId,
    required String category,
    required List<ExerciseModel> exercises,
  }) async {
    final plan = getById(planId);
    if (plan == null) return;

    plan.memberId = memberId;
    plan.category = category;
    plan.exercises = exercises;

    await _repo.updateWorkoutPlanRemote(plan);
    notifyListeners();
  }
Future<void> deleteWorkoutPlan(String planId) async {
  try {
    await ApiClient.delete('${ApiEndpoints.workoutPlans}/$planId'); // ✅
    await _repo.deleteWorkoutPlanLocal(planId);
    notifyListeners();
  } catch (e) {
    print("Error deleting plan: $e");
    rethrow;
  }
}
}