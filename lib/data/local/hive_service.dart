import 'package:gym_management_app/data/local/sync_queue_model.dart';
import 'package:gym_management_app/data/models/achievement_model.dart';
import 'package:gym_management_app/data/models/body_progress_model.dart';
import 'package:gym_management_app/data/models/chat_message_model.dart';
import 'package:gym_management_app/data/models/diet_plan_model.dart';
import 'package:gym_management_app/data/models/exercise_model.dart';
import 'package:gym_management_app/data/models/goal_milestone_model.dart';
import 'package:gym_management_app/data/models/goal_model.dart';
import 'package:gym_management_app/data/models/gym_config_model.dart';
import 'package:gym_management_app/data/models/meal_log_model.dart';
import 'package:gym_management_app/data/models/meal_model.dart';
import 'package:gym_management_app/data/models/meal_reminder_model.dart';
import 'package:gym_management_app/data/models/notification_model.dart';
import 'package:gym_management_app/data/models/payment_model.dart';
import 'package:gym_management_app/data/models/subscription_model.dart';
import 'package:gym_management_app/data/models/timeline_event_model.dart';
import 'package:gym_management_app/data/models/trainer_model.dart';
import 'package:gym_management_app/data/models/workout_log_model.dart';
import 'package:gym_management_app/data/models/workout_plan_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/member_model.dart';
import '../models/plan_model.dart';
import '../models/attendance_model.dart';
import 'hive_boxes.dart';
import '../models/app_user_model.dart';
class HiveService {
  HiveService._();

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(MemberModelAdapter());
    Hive.registerAdapter(PlanModelAdapter());
    Hive.registerAdapter(AttendanceModelAdapter());   // ← Make sure this is here
    Hive.registerAdapter(TrainerModelAdapter());
    Hive.registerAdapter(AppUserModelAdapter());
    Hive.registerAdapter(SubscriptionModelAdapter());
    Hive.registerAdapter(PaymentModelAdapter());
    Hive.registerAdapter(MealModelAdapter());
Hive.registerAdapter(DietPlanModelAdapter());
Hive.registerAdapter(MealLogModelAdapter());
Hive.registerAdapter(MealReminderModelAdapter());
Hive.registerAdapter(ExerciseModelAdapter());
Hive.registerAdapter(WorkoutPlanModelAdapter());
Hive.registerAdapter(WorkoutLogModelAdapter());
Hive.registerAdapter(BodyProgressModelAdapter());
Hive.registerAdapter(GoalModelAdapter());
    Hive.registerAdapter(GoalMilestoneModelAdapter());
Hive.registerAdapter(AchievementModelAdapter()); 
Hive.registerAdapter(ChatMessageModelAdapter());
Hive.registerAdapter(TimelineEventModelAdapter());
Hive.registerAdapter(NotificationModelAdapter());
Hive.registerAdapter(GymConfigModelAdapter());
  Hive.registerAdapter(BranchModelAdapter());

  Hive.registerAdapter(SyncQueueModelAdapter());
    await Future.wait([
      Hive.openBox<MemberModel>(HiveBoxes.members),
      Hive.openBox<PlanModel>(HiveBoxes.plans),
      Hive.openBox<TrainerModel>(HiveBoxes.trainers),
      Hive.openBox<AttendanceModel>(HiveBoxes.attendance),   // ← Typed correctly
      Hive.openBox<SubscriptionModel>(HiveBoxes.subscriptions),
      Hive.openBox<PaymentModel>(HiveBoxes.payments),
      

      Hive.openBox(HiveBoxes.settings),
      Hive.openBox<AppUserModel>(HiveBoxes.users),
      Hive.openBox<DietPlanModel>(HiveBoxes.dietPlans),
      Hive.openBox<MealLogModel>(HiveBoxes.mealLogs),
      Hive.openBox<MealReminderModel>(HiveBoxes.mealReminders),
      Hive.openBox<WorkoutPlanModel>(HiveBoxes.workoutPlans),
      Hive.openBox<WorkoutLogModel>(HiveBoxes.workoutLogs),
      Hive.openBox<BodyProgressModel>(HiveBoxes.bodyProgress),
      Hive.openBox<GoalModel>(HiveBoxes.goals),
      Hive.openBox<GoalMilestoneModel>(HiveBoxes.goalMilestones),
      Hive.openBox<AchievementModel>(HiveBoxes.achievements),
      Hive.openBox<ChatMessageModel>(HiveBoxes.chatHistory),
      Hive.openBox<ChatMessageModel>(HiveBoxes.aiAssistant),
      Hive.openBox<TimelineEventModel>(HiveBoxes.timelineEvents),
      Hive.openBox<NotificationModel>(HiveBoxes.notifications),
      Hive.openBox<GymConfigModel>(HiveBoxes.gymConfig),
      Hive.openBox<SyncQueueModel>(HiveBoxes.syncQueue),


    ]);
  }
}