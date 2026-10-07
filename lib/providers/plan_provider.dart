import 'package:flutter/foundation.dart';
import 'package:gym_management_app/data/network/api_client.dart';
import '../data/models/plan_model.dart';
import '../data/repositories/plan_repository.dart';

class PlanProvider extends ChangeNotifier {
  final PlanRepository _repository = PlanRepository();

  List<PlanModel> _allPlans = [];
  String _filter = 'All'; // All, Active, Inactive

  String get currentFilter => _filter;

  List<PlanModel> get plans {
    if (_filter == 'All') return _allPlans;
    return _allPlans
        .where((p) => p.status.toLowerCase() == _filter.toLowerCase())
        .toList();
  }

  PlanProvider() {
    loadPlans();
  }

  // --- API METHODS ---

  Future<void> loadPlans() async {
    try {
      final response = await ApiClient.get('/api/plans');
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        _allPlans = data.map((json) => PlanModel.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print("Error loading plans: $e");
      _allPlans = _repository.getAllPlansLocal();
      notifyListeners();
    }
  }

  // ADD THIS METHOD: Get plan by ID
  PlanModel? getPlanById(String id) {
    try {
      return _allPlans.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // ADD THIS METHOD: Get plan by name (using planName)
  PlanModel? getPlanByName(String planName) {
    try {
      return _allPlans.firstWhere((p) => p.planName.toLowerCase() == planName.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  // FIX: Use named parameter 'data'
  Future<bool> createPlan(Map<String, dynamic> planData) async {
    try {
      final response = await ApiClient.post(
        '/api/plans',
        data: planData,
      );
      if (response.statusCode == 201) {
        await loadPlans();
        return true;
      }
    } catch (e) {
      print("Create Plan Error: $e");
    }
    return false;
  }

  // FIX: Use named parameter 'data'
  Future<bool> updatePlan(String id, Map<String, dynamic> planData) async {
    try {
      final response = await ApiClient.put(
        '/api/plans/$id',
        data: planData,
      );
      if (response.statusCode == 200) {
        await loadPlans();
        return true;
      }
    } catch (e) {
      print("Update Plan Error: $e");
    }
    return false;
  }

  Future<void> deletePlan(String id) async {
    try {
      await ApiClient.delete('/api/plans/$id');
      await _repository.deletePlan(id);
      await loadPlans();
    } catch (e) {
      print("Delete Plan Error: $e");
    }
  }

  // FIX: Use named parameter 'data'
  Future<void> togglePlanStatus(String id) async {
    try {
      await ApiClient.patch(
        '/api/plans/$id/toggle-status',
        data: {},
      );
      await loadPlans();
    } catch (e) {
      print("Toggle Status Error: $e");
    }
  }

  // --- UI HELPERS ---

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }
}