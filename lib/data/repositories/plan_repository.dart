// import 'package:hive/hive.dart';
// import '../local/hive_boxes.dart';
// import '../models/plan_model.dart';

// class PlanRepository {
//   Box<PlanModel> get _box => Hive.box<PlanModel>(HiveBoxes.plans);

//   List<PlanModel> getAllPlans() => _box.values.toList();

//   Future<void> addPlan(PlanModel plan) async {
//     await _box.put(plan.id, plan);
//   }

//   Future<void> updatePlan(PlanModel plan) async {
//     await plan.save();
//   }

//   Future<void> deletePlan(String id) async {
//     await _box.delete(id);
//   }

//   PlanModel? getPlanById(String id) => _box.get(id);
// }
import 'package:gym_management_app/data/local/hive_boxes.dart';
import 'package:gym_management_app/data/network/api_client.dart';
import 'package:gym_management_app/data/network/api_endpoints.dart';
import '../models/plan_model.dart';
import 'base_repository.dart';

class PlanRepository extends BaseRepository<PlanModel> {
  // Pass the Hive box name and API endpoint to the BaseRepository
  PlanRepository() : super(HiveBoxes.plans, ApiEndpoints.plans);

List<PlanModel> getAllPlansLocal() => box.values.toList();
  
  PlanModel? getPlanByIdLocal(String id) => box.get(id);
  // GET ALL PLANS (Keep as is, or implement local-first caching)
  Future<List<PlanModel>> getAllPlans({String? search}) async {
    try {
      final response = await ApiClient.get(
        endpoint, // Uses inherited endpoint
        params: search != null && search.isNotEmpty ? {'search': search} : null,
      );

      final List<dynamic> data = response.data['data'];
      return data.map((json) => PlanModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching plans: $e');
      return [];
    }
  }

  // ADD PLAN (Uses BaseRepository's Optimistic + Queue logic)
  Future<void> addPlan(PlanModel plan) async {
    await add(plan, id: plan.id);
  }

  // UPDATE PLAN (Uses BaseRepository's Optimistic + Queue logic)
  Future<void> updatePlan(PlanModel plan) async {
    await update(plan, id: plan.id);
  }

  // DELETE PLAN (Uses BaseRepository's logic)
  Future<void> deletePlan(String id) async {
    await delete(id);
  }

  // GET PLAN BY ID (Fetch from API)
  Future<PlanModel?> getPlanById(String id) async {
    try {
      final response = await ApiClient.get('$endpoint/$id');
      return PlanModel.fromJson(response.data['data']);
    } catch (e) {
      print('Error fetching plan: $e');
      return null;
    }
  }
} 