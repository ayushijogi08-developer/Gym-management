import 'package:hive/hive.dart';
import 'meal_model.dart';

part 'diet_plan_model.g.dart';

@HiveType(typeId: 8)
class DietPlanModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String memberId;

  @HiveField(2)
  String createdByTrainerId;

  @HiveField(3)
  String category;

  @HiveField(4)
  List<MealModel> meals;

  @HiveField(5)
  double dailyCalorieTarget;

  @HiveField(6)
  double dailyProteinTarget;

  @HiveField(7)
  int dailyWaterTargetMl;

  @HiveField(8)
  DateTime? startDate;

  @HiveField(9)
  DateTime? endDate;

  @HiveField(10)
  bool isActive;

  DietPlanModel({
    required this.id,
    required this.memberId,
    required this.createdByTrainerId,
    required this.category,
    required this.meals,
    required this.dailyCalorieTarget,
    required this.dailyProteinTarget,
    required this.dailyWaterTargetMl,
    this.startDate,
    this.endDate,
    this.isActive = true,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'createdByTrainerId': createdByTrainerId,
      'category': category,
      'meals': meals.map((m) => m.toJson()).toList(), // Assumes MealModel has toJson()
      'dailyCalorieTarget': dailyCalorieTarget,
      'dailyProteinTarget': dailyProteinTarget,
      'dailyWaterTargetMl': dailyWaterTargetMl,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
    };
  }

factory DietPlanModel.fromJson(Map<String, dynamic> json) {
  try {
    return DietPlanModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),

      // Handle memberId as object or string
      memberId: json['memberId'] is Map<String, dynamic>
          ? (json['memberId']['_id'] ?? json['memberId']['id'] ?? '').toString()
          : (json['memberId'] ?? '').toString(),

      // Handle trainerId as object or string
      createdByTrainerId: json['trainerId'] is Map<String, dynamic>
          ? (json['trainerId']['_id'] ?? json['trainerId']['id'] ?? '').toString()
          : (json['trainerId'] ?? json['createdByTrainerId'] ?? '').toString().trim(),

      category: (json['category'] ?? 'General Fitness').toString(),

      meals: (json['meals'] as List?)
              ?.map((m) => m is Map<String, dynamic> 
                  ? MealModel.fromJson(m) 
                  : MealModel.fromJson({}))
              .toList() 
          ?? [],

      dailyCalorieTarget: (json['dailyCalorieTarget'] as num?)?.toDouble() ?? 0.0,
      dailyProteinTarget: (json['dailyProteinTarget'] as num?)?.toDouble() ?? 0.0,
      dailyWaterTargetMl: (json['dailyWaterTargetMl'] as num?)?.toInt() ?? 0,

      startDate: json['startDate'] != null 
          ? DateTime.tryParse(json['startDate'].toString()) 
          : null,

      endDate: json['endDate'] != null 
          ? DateTime.tryParse(json['endDate'].toString()) 
          : null,

      // Default to true if missing
      isActive: json.containsKey('isActive') 
          ? json['isActive'] == true 
          : true,
    );
  } catch (e) {
    print('❌ Error parsing DietPlan: $e');
    print('JSON: $json');
    rethrow;
  }
}
}