import 'dart:convert';
import 'package:hive/hive.dart';
import '../data/local/hive_boxes.dart';
import '../data/models/member_model.dart';
import '../data/models/plan_model.dart';
import '../data/models/subscription_model.dart';
import '../data/models/payment_model.dart';
import '../data/models/attendance_model.dart';
import '../data/models/achievement_model.dart';
import '../data/models/diet_plan_model.dart';
import '../data/models/goal_model.dart';
import '../data/models/meal_log_model.dart';
import '../data/models/meal_reminder_model.dart';
import '../data/models/trainer_model.dart';
import '../data/models/app_user_model.dart';
import '../data/models/workout_log_model.dart';
import '../data/models/workout_plan_model.dart';
import '../data/models/body_progress_model.dart';

class BackupRestoreService {
  /// List every box name that should be included in a backup.
  static const List<String> _allBoxNames = [
    HiveBoxes.members,
    HiveBoxes.plans,
    HiveBoxes.subscriptions,
    HiveBoxes.payments,
    HiveBoxes.attendance,
    HiveBoxes.settings,
    'achievements_box',
    'diet_plans_box',
    'goals_box',
    'meal_logs_box',
    'meal_reminders_box',
    'trainers_box',
    'users_box',
    'workout_logs_box',
    'workout_plans_box',
    'body_progress_box',
    // add any box name not already covered by HiveBoxes constants
  ];

  /// Exports all boxes into one JSON string.
  static Future<String> exportBackup() async {
    final Map<String, dynamic> backupData = {};

    for (final boxName in _allBoxNames) {
      if (!Hive.isBoxOpen(boxName)) continue;
      final box = _getTypedBox(boxName);
      final Map<String, dynamic> boxData = {};

      for (final key in box.keys) {
        final value = box.get(key);
        // Hive objects need to be converted to plain maps for JSON.
        // Each model should expose a toJson() — see note below.
        boxData[key.toString()] = _serializeValue(value);
      }
      backupData[boxName] = boxData;
    }

    backupData['_metadata'] = {
      'exportedAt': DateTime.now().toIso8601String(),
      'appVersion': '1.0.0',
    };

    return jsonEncode(backupData);
  }

  static dynamic _serializeValue(dynamic value) {
    // If the model has a toJson() method, use it.
    // Otherwise fall back to toString() (not ideal, flagged below).
    try {
      return (value as dynamic).toJson();
    } catch (_) {
      return value.toString();
    }
  }

  /// Restores all boxes from a JSON backup string.
  /// WARNING: this overwrites all current data in matching boxes.
  static Future<void> importBackup(String jsonString) async {
    final Map<String, dynamic> backupData = jsonDecode(jsonString);

    for (final boxName in _allBoxNames) {
      if (!backupData.containsKey(boxName)) continue;
      if (!Hive.isBoxOpen(boxName)) continue;

      final box = _getTypedBox(boxName);
      await box.clear();

      final Map<String, dynamic> boxData = backupData[boxName];
      for (final entry in boxData.entries) {
        final deserialized = _deserializeValue(boxName, entry.value);
        await box.put(entry.key, deserialized);
      }
    }
  }
  static dynamic _deserializeValue(String boxName, dynamic json) {
    if (boxName == HiveBoxes.settings) return json;
    
    switch (boxName) {
      case HiveBoxes.members: return MemberModel.fromJson(json);
      case HiveBoxes.plans: return PlanModel.fromJson(json);
      case HiveBoxes.subscriptions: return SubscriptionModel.fromJson(json);
      case HiveBoxes.payments: return PaymentModel.fromJson(json);
      case HiveBoxes.attendance: return AttendanceModel.fromJson(json);
      case 'achievements_box': return AchievementModel.fromJson(json);
      case 'diet_plans_box': return DietPlanModel.fromJson(json);
      case 'goals_box': return GoalModel.fromJson(json);
      case 'meal_logs_box': return MealLogModel.fromJson(json);
      case 'meal_reminders_box': return MealReminderModel.fromJson(json);
      case 'trainers_box': return TrainerModel.fromJson(json);
      case 'users_box': return AppUserModel.fromJson(json);
      case 'workout_logs_box': return WorkoutLogModel.fromJson(json);
      case 'workout_plans_box': return WorkoutPlanModel.fromJson(json);
      case 'body_progress_box': return BodyProgressModel.fromJson(json);
      default: return json;
    }
  }
  
  static Box _getTypedBox(String boxName) {
  switch (boxName) {
    case HiveBoxes.members:
      return Hive.box<MemberModel>(boxName);
    case HiveBoxes.plans:
      return Hive.box<PlanModel>(boxName);
    case HiveBoxes.subscriptions:
      return Hive.box<SubscriptionModel>(boxName);
    case HiveBoxes.payments:
      return Hive.box<PaymentModel>(boxName);
    case HiveBoxes.attendance:
      return Hive.box<AttendanceModel>(boxName);
    case HiveBoxes.settings:
      return Hive.box(boxName); // untyped/dynamic box, this one is fine as-is
    case 'achievements_box':
      return Hive.box<AchievementModel>(boxName);
    case 'diet_plans_box':
      return Hive.box<DietPlanModel>(boxName);
    case 'goals_box':
      return Hive.box<GoalModel>(boxName);
    case 'meal_logs_box':
      return Hive.box<MealLogModel>(boxName);
    case 'meal_reminders_box':
      return Hive.box<MealReminderModel>(boxName);
    case 'trainers_box':
      return Hive.box<TrainerModel>(boxName);
    case 'users_box':
      return Hive.box<AppUserModel>(boxName);
    case 'workout_logs_box':
      return Hive.box<WorkoutLogModel>(boxName);
    case 'workout_plans_box':
      return Hive.box<WorkoutPlanModel>(boxName);
    case 'body_progress_box':
      return Hive.box<BodyProgressModel>(boxName);
    default:
      throw Exception('Unknown box name: $boxName');
  }
}
}