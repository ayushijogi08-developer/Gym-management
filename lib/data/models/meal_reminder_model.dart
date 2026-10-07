import 'package:hive/hive.dart';

part 'meal_reminder_model.g.dart';

@HiveType(typeId: 10)
class MealReminderModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String memberId;

  @HiveField(2)
  String dietPlanId;

  @HiveField(3)
  String mealType;

  @HiveField(4)
  String scheduledTime; // "HH:mm" format

  @HiveField(5)
  bool isEnabled;

  @HiveField(6)
  bool mutedByMember;

  @HiveField(7)
  String? customMessage;

  @HiveField(8)
  bool repeatDaily;

  @HiveField(9)
  String? dndStart; // "HH:mm"

  @HiveField(10)
  String? dndEnd;   // "HH:mm"

  MealReminderModel({
    required this.id,
    required this.memberId,
    required this.dietPlanId,
    required this.mealType,
    required this.scheduledTime,
    this.isEnabled = true,
    this.mutedByMember = false,
    this.customMessage,
    this.repeatDaily = true,
    this.dndStart,
    this.dndEnd,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'dietPlanId': dietPlanId,
      'mealType': mealType,
      'scheduledTime': scheduledTime,
      'isEnabled': isEnabled,
      'mutedByMember': mutedByMember,
      'customMessage': customMessage,
      'repeatDaily': repeatDaily,
      'dndStart': dndStart,
      'dndEnd': dndEnd,
    };
  }

  // --- ADDED: For Restore (Import) ---
  factory MealReminderModel.fromJson(Map<String, dynamic> json) {
    return MealReminderModel(
      id: json['id'],
      memberId: json['memberId'],
      dietPlanId: json['dietPlanId'],
      mealType: json['mealType'],
      scheduledTime: json['scheduledTime'],
      isEnabled: json['isEnabled'] ?? true,
      mutedByMember: json['mutedByMember'] ?? false,
      customMessage: json['customMessage'],
      repeatDaily: json['repeatDaily'] ?? true,
      dndStart: json['dndStart'],
      dndEnd: json['dndEnd'],
    );
  }
}