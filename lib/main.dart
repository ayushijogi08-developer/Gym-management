import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_management_app/services/sync_service.dart';
import 'package:provider/provider.dart';

// Import all your providers
import 'package:gym_management_app/providers/achievement_provider.dart';
import 'package:gym_management_app/providers/ai_assistant_provider.dart';
import 'package:gym_management_app/providers/attendance_provider.dart';
import 'package:gym_management_app/providers/auth_provider.dart';
import 'package:gym_management_app/providers/body_progress_provider.dart';
import 'package:gym_management_app/providers/diet_plan_provider.dart';
import 'package:gym_management_app/providers/goal_provider.dart';
import 'package:gym_management_app/providers/meal_reminder_provider.dart';
import 'package:gym_management_app/providers/notification_provider.dart';
import 'package:gym_management_app/providers/payment_provider.dart';
import 'package:gym_management_app/providers/subscription_provider.dart';
import 'package:gym_management_app/providers/theme_provider.dart';
import 'package:gym_management_app/providers/timeline_provider.dart';
import 'package:gym_management_app/providers/trainer_provider.dart';
import 'package:gym_management_app/providers/workout_log_provider.dart';
import 'package:gym_management_app/providers/workout_plan_provider.dart';
import 'package:gym_management_app/providers/member_provider.dart';
import 'package:gym_management_app/providers/plan_provider.dart';
import 'package:gym_management_app/providers/meal_log_provider.dart';
import 'package:gym_management_app/providers/gym_config_provider.dart';
import 'package:gym_management_app/providers/admin_dashboard_provider.dart';

// Services and Routes
import 'data/local/hive_service.dart';
import 'services/local_notification_service.dart';
import 'services/notification_scheduler_service.dart';
import 'routes/app_router.dart';
import 'themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await HiveService.init();
  try {
    await LocalNotificationService.init();
    print('✅ Local Notification Service initialized');
  } catch (e) {
    print('❌ Failed to initialize Local Notification Service: $e');
  }
  
  final authProvider = AuthProvider();
  await authProvider.loadPersistedUserFromToken();
  
  final syncService = SyncService();
  syncService.init();
  
  runApp(GymApp(authProvider: authProvider));
}

class GymApp extends StatelessWidget {
  const GymApp({super.key, required this.authProvider});
  final AuthProvider authProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => PlanProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => DietPlanProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => MealReminderProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutPlanProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutLogProvider()),
        ChangeNotifierProvider(create: (_) => BodyProgressProvider()),
        ChangeNotifierProvider(create: (_) => MealLogProvider()),
        ChangeNotifierProvider(create: (_) => TrainerProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
        ChangeNotifierProvider(create: (_) => AiAssistantProvider()),
        ChangeNotifierProvider(create: (_) => TimelineProvider()),
        ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
        ChangeNotifierProvider(create: (_) => GymConfigProvider()..loadConfig()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()..fetchNotifications()),
      ],
      child: Builder(
        builder: (newContext) {
          // Now newContext is a descendant of MultiProvider
          WidgetsBinding.instance.addPostFrameCallback((_) {
            NotificationSchedulerService.runDailyChecks(newContext);
          });

          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              // Match system bars to the active theme so the chrome doesn't
              // flash white during theme switches.
              SystemChrome.setSystemUIOverlayStyle(
                AppTheme.overlayStyleFor(context),
              );
              return MaterialApp.router(
                title: 'Gym Management',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.themeMode,
                routerConfig: appRouter,
              );
            },
          );
        },
      ),
    );
  }
}