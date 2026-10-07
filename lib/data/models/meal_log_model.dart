import 'package:hive/hive.dart';

part 'meal_log_model.g.dart';

@HiveType(typeId: 9)
class MealLogModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String memberId;

  @HiveField(2)
  String dietPlanId;

  @HiveField(3)
  String mealType;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  String status; // completed | skipped | pending

  @HiveField(6)
  String? personalNote;

  @HiveField(7)
  DateTime? loggedAt;

  MealLogModel({
    required this.id,
    required this.memberId,
    required this.dietPlanId,
    required this.mealType,
    required this.date,
    this.status = 'pending',
    this.personalNote,
    this.loggedAt,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'dietPlanId': dietPlanId,
      'mealType': mealType,
      'date': date.toIso8601String(),
      'status': status,
      'personalNote': personalNote,
      'loggedAt': loggedAt?.toIso8601String(),
    };
  }

  // --- ADDED: For Restore (Import) ---
  factory MealLogModel.fromJson(Map<String, dynamic> json) {
    return MealLogModel(
      id: json['_id'] ?? json['id'] ?? '',
      memberId: json['memberId'],
      dietPlanId: json['dietPlanId'],
      mealType: json['mealType'],
      date: DateTime.parse(json['date']),
      status: json['status'],
      personalNote: json['personalNote'],
      loggedAt: json['loggedAt'] != null ? DateTime.parse(json['loggedAt']) : null,
    );
  }
}