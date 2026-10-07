import 'package:hive/hive.dart';
import 'exercise_model.dart';

part 'workout_plan_model.g.dart';

@HiveType(typeId: 12)
class WorkoutPlanModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String memberId;

  @HiveField(2)
  String createdByTrainerId;

  @HiveField(3)
  String category;

  @HiveField(4)
  List<ExerciseModel> exercises;

  @HiveField(5)
  DateTime? startDate;

  @HiveField(6)
  DateTime? endDate;

  @HiveField(7)
  bool isActive;

  WorkoutPlanModel({
    required this.id,
    required this.memberId,
    required this.createdByTrainerId,
    required this.category,
    required this.exercises,
    this.startDate,
    this.endDate,
    this.isActive = true,
  });
  // --- ADDED: For Backup (Export) ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'createdByTrainerId': createdByTrainerId,
      'category': category,
      // Ensure ExerciseModel also has a toJson() method
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
    };
  }

  // --- ADDED: For Restore (Import) ---
  factory WorkoutPlanModel.fromJson(Map<String, dynamic> json) {
    return WorkoutPlanModel(
    id: (json['id'] ?? json['_id']).toString(),
      memberId: json['memberId'],
      createdByTrainerId: json['createdByTrainerId'],
      category: json['category'],
      // Ensure ExerciseModel also has a fromJson() method
      exercises: (json['exercises'] as List)
          .map((e) => ExerciseModel.fromJson(e))
          .toList(),
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isActive: json['isActive'] ?? true,
    );
  }
}