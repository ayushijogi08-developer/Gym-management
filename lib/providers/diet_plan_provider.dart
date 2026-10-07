import 'package:flutter/material.dart';
import 'package:gym_management_app/data/network/api_client.dart';
import 'package:gym_management_app/domain/entities/user_role.dart';
import '../data/models/diet_plan_model.dart';
import '../data/models/meal_model.dart';
import '../data/repositories/diet_plan_repository.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class DietPlanProvider extends ChangeNotifier {
  final DietPlanRepository _repo = DietPlanRepository();

  List<DietPlanModel> _plans = [];

  List<DietPlanModel> get plans => _plans;

  void loadFromLocal() {
    _plans = _repo.getAllLocal();
    notifyListeners();
  }
 
  DietPlanModel? getActiveForMember(String memberId) {
    return _repo.getActiveByMemberLocal(memberId).firstOrNull; 
  }
  
  List<DietPlanModel> getByTrainer(String trainerId) {
    if (trainerId.isEmpty) return [];

    print("DEBUG: Filtering for Trainer: $trainerId. Total in memory: ${_plans.length}");
    
    final filtered = _plans.where((p) {
      final match = p.createdByTrainerId.trim() == trainerId.trim();
      if (match) print("DEBUG: Found matching plan: ${p.id}");
      return match;
    }).toList();

    return filtered;
  }

  Future<void> deleteDietPlan(String planId, BuildContext context) async {
    try {
      final response = await ApiClient.delete('/api/diet-plans/$planId');
      
      if (response.statusCode == 200) {
        _plans.removeWhere((p) => p.id == planId);
        notifyListeners();
        await refreshDietPlans();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diet plan deleted successfully')),
        );
      }
    } catch (e) {
      print("Error deleting diet plan: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete diet plan')),
      );
    }
  }

  // FIX: Use named parameter 'data'
  Future<void> createDietPlan({
    required String memberId,
    required String category,
    required List<MealModel> meals,
    required BuildContext context,
     DateTime? startDate,  // ADD THIS
  DateTime? endDate,
  }) async {
    final auth = context.read<AuthProvider>();
    if (!auth.hasPermission('canEditDietPlans')) return;

    final dailyCalories = meals.fold(0.0, (sum, m) => sum + m.calories);
    final dailyProtein = meals.fold(0.0, (sum, m) => sum + m.protein);
    final dailyWater = meals.fold(0, (sum, m) => sum + (m.waterIntakeMl ?? 0));

    final planData = {
      'memberId': memberId,
      'trainerId': auth.currentUser?.linkedTrainerId ?? auth.currentUser!.id,
      'category': category,
      'meals': meals.map((m) => m.toJson()).toList(),
      'startDate': (startDate ?? DateTime.now()).toIso8601String(),
    'endDate': (endDate ?? DateTime.now().add(Duration(days: 30))).toIso8601String(),
      'dailyCalorieTarget': dailyCalories,
      'dailyProteinTarget': dailyProtein,
      'dailyWaterTargetMl': dailyWater,
      'isActive': true,
    };

    try {
      // FIX: Use named parameter 'data'
      final response = await ApiClient.post(
        '/api/diet-plans',
        data: planData,  // Changed to named parameter
      );
      
      if (response.statusCode == 201) {
        final authProvider = context.read<AuthProvider>();
        final dietProvider = context.read<DietPlanProvider>();
        
        if (authProvider.currentRole == UserRole.trainer) {
          final trainerId = authProvider.currentUser?.linkedTrainerId ?? 
                           authProvider.currentUser?.id ?? '';
          await dietProvider.refreshForTrainer(trainerId);
        } else {
          await dietProvider.refreshDietPlans();
        }

         if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diet plan created successfully!')),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create diet plan')),
        );
      }
    }
    } catch (e) {
      print("Error creating diet plan: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create diet plan')),
      );
    }
  }
}
// Add this method
Future<DietPlanModel?> getActiveForMemberAsync(String memberId) async {
  // First try to get from API
  try {
    final plans = await _repo.getActiveByMember(memberId);
    if (plans.isNotEmpty) {
      return plans.first;
    }
  } catch (e) {
    print('Error fetching active diet plan: $e');
  }
  // Fallback to local
  return _repo.getActiveByMemberLocal(memberId).firstOrNull;
}

  // FIX: Use named parameter 'data'
  Future<void> updateDietPlan(DietPlanModel plan) async {
    try {
      // FIX: Use named parameter 'data'
      final response = await ApiClient.put(
        '/api/diet-plans/${plan.id}',
        data: plan.toJson(),  // Changed to named parameter
      );
      if (response.statusCode == 200) {
        await _repo.updateDietPlan(plan);
        await refreshDietPlans();
      }
    } catch (e) {
      print("Error updating diet plan: $e");
    }
  }

  Future<void> refreshForTrainer(String trainerId) async {
    try {
      print("🔄 Refreshing plans for trainer: $trainerId");
      _plans = await _repo.getByTrainer(trainerId);
      print("✅ Loaded ${_plans.length} plans for trainer");
      notifyListeners();
    } catch (e) {
      print("❌ Error refreshing trainer plans: $e");
      _plans = _repo.getByTrainerLocal(trainerId);
      notifyListeners();
    }
  }

  Future<void> refreshForMember(String memberId) async {
  try {
    print("🔄 Refreshing diet for member: $memberId");
    
    // First try to get from API
    final freshPlans = await _repo.getActiveByMember(memberId);
    
    if (freshPlans.isNotEmpty) {
      print("✅ Found ${freshPlans.length} active diet plan(s) for member");
      for (var plan in freshPlans) {
        await _repo.addDietPlan(plan);
      }
      _plans = freshPlans;
    } else {
      // Fallback to local
      _plans = _repo.getAllLocal();
    }
    notifyListeners();
  } catch (e) {
    print("❌ Error in refreshForMember: $e");
    _plans = _repo.getAllLocal();
    notifyListeners();
  }
}

  Future<void> refreshDietPlans({String? trainerId}) async {
    try {
      _plans = await _repo.getAll(trainerId: trainerId); 
      notifyListeners();
    } catch (e) {
      print("Error refreshing diet plans: $e");
      _plans = _repo.getAllLocal();
      notifyListeners();
    }
  }
}