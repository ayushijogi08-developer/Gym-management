
import 'package:gym_management_app/data/local/hive_boxes.dart';
import 'package:gym_management_app/data/network/api_client.dart';
import 'package:gym_management_app/data/network/api_endpoints.dart';
import 'package:hive/hive.dart';
import '../models/diet_plan_model.dart';
import 'base_repository.dart';
 
class DietPlanRepository extends BaseRepository<DietPlanModel> {
  // Pass the Hive box name and API endpoint to the BaseRepository
  DietPlanRepository() : super(HiveBoxes.dietPlans, ApiEndpoints.dietPlans);

// --- ADD THESE SYNCHRONOUS LOCAL METHODS ---
  List<DietPlanModel> getAllLocal() => box.values.toList();

  List<DietPlanModel> getActiveByMemberLocal(String memberId) {
  return box.values.where((p) => 
    p.memberId == memberId && 
    p.isActive == true
  ).toList();
}
  List<DietPlanModel> getByTrainerLocal(String trainerId) {
    return box.values.where((p) => p.createdByTrainerId == trainerId).toList();
  }
   
// lib/data/repositories/diet_plan_repository.dart

// Update the getAll definition to accept the optional trainerId
Future<List<DietPlanModel>> getAll({String? trainerId}) async {
  try {
    // Determine the correct URL
    final requestEndpoint = (trainerId != null && trainerId.isNotEmpty) 
        ? '$endpoint/trainer/$trainerId' 
        : endpoint;

    final response = await ApiClient.get(requestEndpoint);
    final List<dynamic> data = response.data['data'] ?? [];

    final List<DietPlanModel> plans = [];
    for (var item in data) {
      try {
        plans.add(DietPlanModel.fromJson(item as Map<String, dynamic>));
      } catch (e) {
        print('❌ Failed to parse diet plan: $e');
      }
    }

    final box = Hive.box<DietPlanModel>(HiveBoxes.dietPlans);
    await box.clear();
    for (var plan in plans) {
      await box.put(plan.id, plan);
    }

    return plans;
  } catch (e) {
    print('Error fetching diet plans: $e');
    return [];
  }
}

  // GET BY ID
  Future<DietPlanModel?> getById(String id) async {
    try {
      final response = await ApiClient.get('$endpoint/$id');
      return DietPlanModel.fromJson(response.data['data']);
    } catch (e) {
      print('Error fetching diet plan: $e');
      return null;
    }
  }

  // GET ACTIVE PLANS BY MEMBER
  Future<List<DietPlanModel>> getActiveByMember(String memberId) async {
    try {
      final response = await ApiClient.get('$endpoint/member/$memberId/active');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => DietPlanModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching member diet plans: $e');
      return [];
    }
  }

  // GET BY TRAINER
  Future<List<DietPlanModel>> getByTrainer(String trainerId) async {
    try {
      final response = await ApiClient.get('$endpoint/trainer/$trainerId');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => DietPlanModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching trainer diet plans: $e');
      return [];
    }
  }

  // ADD DIET PLAN (Uses BaseRepository logic for Offline/Sync)
  Future<void> addDietPlan(DietPlanModel plan) async {
    await add(plan, id: plan.id);
  }

  // UPDATE DIET PLAN (Uses BaseRepository logic for Offline/Sync)
  Future<void> updateDietPlan(DietPlanModel plan) async {
    await update(plan, id: plan.id);
  }

 Future<void> deleteDietPlan(String id) async {
  try {
    // Call API
    await ApiClient.delete('$endpoint/$id');   // Make sure this endpoint exists
    
    // Delete from Hive
    await box.delete(id);
    
    print('Diet plan $id deleted from local storage');
  } catch (e) {
    print('Error deleting diet plan: $e');
    rethrow;
  }
}
}