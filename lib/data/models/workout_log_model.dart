import 'package:hive/hive.dart';

part 'workout_log_model.g.dart';

@HiveType(typeId: 13)
class WorkoutLogModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String memberId;

  @HiveField(2)
  String workoutPlanId;

  @HiveField(3)
  String exerciseName;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  String status; // completed | skipped | pending

  @HiveField(6)
  int? actualSetsCompleted;

  @HiveField(7)
  double? weightUsedKg;

  @HiveField(8)
  double? caloriesBurned;

  @HiveField(9)
  int? workoutDurationMinutes;

  @HiveField(10)
  String? notes;

  @HiveField(11)
  DateTime? loggedAt;

  @HiveField(12)
String? trainerFeedback;

@HiveField(13) // NEW: Ensure this ID is unique
  int? reps;

  WorkoutLogModel({
    required this.id,
    required this.memberId,
    required this.workoutPlanId,
    required this.exerciseName,
    required this.date,
    this.status = 'pending',
    this.actualSetsCompleted,
    this.weightUsedKg,
    this.caloriesBurned,
    this.workoutDurationMinutes,
    this.notes,
    this.loggedAt,
    this.trainerFeedback,
    this.reps,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'workoutPlanId': workoutPlanId,
      'exerciseName': exerciseName,
      'date': date.toIso8601String(),
      'status': status,
      'actualSetsCompleted': actualSetsCompleted,
      'weightUsedKg': weightUsedKg,
      'caloriesBurned': caloriesBurned,
      'workoutDurationMinutes': workoutDurationMinutes,
      'notes': notes,
      'loggedAt': loggedAt?.toIso8601String(),
      'trainerFeedback': trainerFeedback,
      'reps': reps,
    };
  }

  // --- ADDED: For Restore (Import) ---
  factory WorkoutLogModel.fromJson(Map<String, dynamic> json) {
    return WorkoutLogModel(
        id: (json['id'] ?? json['_id']).toString(),
      memberId: json['memberId'],
      workoutPlanId: json['workoutPlanId'],
      exerciseName: json['exerciseName'],
      date: DateTime.parse(json['date']),
      status: json['status'] ?? 'pending',
      actualSetsCompleted: json['actualSetsCompleted'],
      weightUsedKg: (json['weightUsedKg'] as num?)?.toDouble(),
      caloriesBurned: (json['caloriesBurned'] as num?)?.toDouble(),
      workoutDurationMinutes: json['workoutDurationMinutes'],
      notes: json['notes'],
      loggedAt: json['loggedAt'] != null ? DateTime.parse(json['loggedAt']) : null,
      trainerFeedback: json['trainerFeedback'],
      reps: json['reps'],
    );
  }
}