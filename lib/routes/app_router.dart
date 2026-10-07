import 'package:go_router/go_router.dart';
import 'package:gym_management_app/data/models/gym_config_model.dart';
import 'package:gym_management_app/data/models/member_model.dart';
import 'package:gym_management_app/presentation/screens/achievements/achievements_screen.dart';
import 'package:gym_management_app/presentation/screens/ai_assistant/ai_chat_screen.dart';
import 'package:gym_management_app/presentation/screens/attendance/my_attendance_screen.dart';
import 'package:gym_management_app/presentation/screens/auth/change_password_screen.dart';
import 'package:gym_management_app/presentation/screens/dashboard/member_dashboard_home.dart';
// Import only diet_plan_list_screen.dart (no conflict now)
import 'package:gym_management_app/presentation/screens/diet/diet_plan_list_screen.dart';
import 'package:gym_management_app/presentation/screens/diet/member_diet_view_screen.dart';
import 'package:gym_management_app/presentation/screens/goals/add_edit_goal_screen.dart';
import 'package:gym_management_app/presentation/screens/goals/all_member_goals_screen.dart';
import 'package:gym_management_app/presentation/screens/goals/goals_screen.dart';
import 'package:gym_management_app/presentation/screens/meal_reminders/all_reminders_overview_screen.dart';
import 'package:gym_management_app/presentation/screens/meal_reminders/reminder_schedule_screen.dart';
import 'package:gym_management_app/presentation/screens/meal_reminders/reminder_settings_screen.dart';
import 'package:gym_management_app/presentation/screens/members/add_edit_member_screen.dart';
import 'package:gym_management_app/presentation/screens/members/member_list_screen.dart';
import 'package:gym_management_app/presentation/screens/members/member_password_reset_screen.dart';
import 'package:gym_management_app/presentation/screens/notifications/notification_settings_screen.dart';
import 'package:gym_management_app/presentation/screens/notifications/notifications_screen.dart';
import 'package:gym_management_app/presentation/screens/payments/invoice_preview_screen.dart';
import 'package:gym_management_app/presentation/screens/payments/payment_list_screen.dart';
import 'package:gym_management_app/presentation/screens/payments/record_payment_screen.dart';
import 'package:gym_management_app/presentation/screens/plans/plan_list_screen.dart';
import 'package:gym_management_app/presentation/screens/progress/add_progress_entry_screen.dart';
import 'package:gym_management_app/presentation/screens/progress/body_progress_screen.dart';
import 'package:gym_management_app/presentation/screens/progress/progress_charts_screen.dart';
import 'package:gym_management_app/presentation/screens/progress/progress_comparison_screen.dart';
import 'package:gym_management_app/presentation/screens/qr/qr_reveal_screen.dart';
import 'package:gym_management_app/presentation/screens/qr/qr_scanner_screen.dart';
import 'package:gym_management_app/presentation/screens/reports/attendance_report_screen.dart';
import 'package:gym_management_app/presentation/screens/reports/growth_report_screen.dart';
import 'package:gym_management_app/presentation/screens/reports/membership_report_screen.dart';
import 'package:gym_management_app/presentation/screens/reports/reports_screen.dart';
import 'package:gym_management_app/presentation/screens/reports/revenue_report_screen.dart';
import 'package:gym_management_app/presentation/screens/search/global_search_screen.dart';
import 'package:gym_management_app/presentation/screens/settings/account_settings_screen.dart';
import 'package:gym_management_app/presentation/screens/settings/admin_management_screen.dart';
import 'package:gym_management_app/presentation/screens/settings/admin_user_management_screen.dart';
import 'package:gym_management_app/presentation/screens/settings/backup_restore_screen.dart';
import 'package:gym_management_app/presentation/screens/settings/branch_detail_screen.dart';
import 'package:gym_management_app/presentation/screens/settings/branch_management_screen.dart';
import 'package:gym_management_app/presentation/screens/settings/gym_details_screen.dart';
import 'package:gym_management_app/presentation/screens/settings/roles_permissions_screen.dart';
import 'package:gym_management_app/presentation/screens/settings/settings_screen.dart';
import 'package:gym_management_app/presentation/screens/settings/tax_currency_screen.dart';
import 'package:gym_management_app/presentation/screens/settings/theme_settings_screen.dart';
import 'package:gym_management_app/presentation/screens/settings/working_hours_screen.dart';
import 'package:gym_management_app/presentation/screens/timeline/personal_timeline_screen.dart';
import 'package:gym_management_app/presentation/screens/trainers/trainer_list_screen.dart';
import 'package:gym_management_app/presentation/screens/workouts/add_edit_workout_plan_screen.dart';
import 'package:gym_management_app/presentation/screens/workouts/member_workout_view_screen.dart';
import 'package:gym_management_app/presentation/screens/workouts/my_workout_history_screen.dart';
import 'package:gym_management_app/presentation/screens/workouts/workout_plan_list_screen.dart';
import 'package:gym_management_app/providers/auth_provider.dart';
import 'package:gym_management_app/providers/payment_provider.dart';
import 'package:provider/provider.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/dashboard/role_based_dashboard.dart';
import 'app_routes.dart';
import 'diet_plan_route.dart'; // Import the wrapper
import '../presentation/screens/attendance/admin_attendance_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  redirect: (context, state) async {
    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = authProvider.isLoggedIn;
    final isLoggingIn = state.matchedLocation == AppRoutes.login;
    final isSplash = state.matchedLocation == AppRoutes.splash;

    if (!isLoggedIn && !isLoggingIn && !isSplash) {
      return AppRoutes.login;
    }

    if (isLoggedIn && (isLoggingIn || isSplash)) {
      return AppRoutes.dashboard;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.changePassword,
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) => const RoleBasedDashboard(),
    ),
    GoRoute(
      path: AppRoutes.members,
      builder: (context, state) => const MemberListScreen(),
    ),
    GoRoute(
      path: '/payments',
      builder: (context, state) => const PaymentListScreen(),
    ),
    GoRoute(
      path: '/record-payment',
      builder: (context, state) => const RecordPaymentScreen(),
    ),
    GoRoute(
      path: '/invoice/:paymentId',
      builder: (context, state) {
        final paymentId = state.pathParameters['paymentId']!;
        final payment = context.read<PaymentProvider>().allPayments.firstWhere(
          (p) => p.id == paymentId,
          orElse: () => throw Exception('Payment not found'),
        );
        return InvoicePreviewScreen(payment: payment);
      },
    ),
    GoRoute(
      path: '/diet-plans',
      builder: (context, state) => const DietPlanListScreen(),
    ),
    GoRoute(
      path: '/add-edit-diet-plan',
      builder: buildAddEditDietPlanRoute,
    ),
    GoRoute(
      path: '/my-diet',
      builder: (context, state) => const MemberDietViewScreen(),
    ),
    GoRoute(
      path: '/add-edit-member',
      builder: (context, state) {
        final member = state.extra as MemberModel?; 
        return AddEditMemberScreen(existingMember: member);
      },
    ),
    GoRoute(
      path: '/reminder-schedule',
      builder: (context, state) => ReminderScheduleScreen(
        memberId: state.uri.queryParameters['memberId'] ?? ''
      ),
    ),
    GoRoute(
      path: '/reminder-settings',
      builder: (context, state) => const ReminderSettingsScreen(),
    ),
    GoRoute(
      path: '/all-reminders',
      builder: (context, state) => const AllRemindersOverviewScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.plans,
      builder: (context, state) => const PlanListScreen(),
    ),
    GoRoute(
      path: '/trainers',
      builder: (context, state) => const TrainerListScreen(),
    ),
    GoRoute(
      path: '/workout-plans',
      builder: (context, state) => const WorkoutPlanListScreen(),
    ),
    GoRoute(
      path: '/add-edit-workout-plan', 
      builder: (context, state) => AddEditWorkoutPlanScreen(
        planId: state.uri.queryParameters['planId']
      ),
    ),
    GoRoute(path: '/my-workout', builder: (_, _) => const MemberWorkoutViewScreen()),
    GoRoute(path: '/body-progress', builder: (_, _) => const BodyProgressScreen()),
    GoRoute(path: '/add-progress-entry', builder: (_, _) => const AddProgressEntryScreen()),
    GoRoute(path: '/progress-comparison', builder: (_, _) => const ProgressComparisonScreen()),
    GoRoute(path: '/progress-charts', builder: (_, _) => const ProgressChartsScreen()),
    GoRoute(path: '/member-dashboard', builder: (_, _) => const MemberDashboardHome()),
    GoRoute(path: '/workout-history', builder: (_, _) => const MyWorkoutHistoryScreen()),
    GoRoute(path: '/goals', builder: (_, _) => const GoalsScreen()),
    GoRoute(
      path: '/add-edit-goal',
      builder: (context, state) {
        final goalId = state.uri.queryParameters['goalId'];
        final memberId = state.uri.queryParameters['memberId'];
        return AddEditGoalScreen(
          goalId: goalId,
          memberId: memberId,
        );
      },
    ),
    GoRoute(path: '/achievements', builder: (_, _) => const AchievementsScreen()),
    GoRoute(
      path: '/all-member-goals',
      builder: (context, state) => const AllMemberGoalsScreen(),
    ),
    GoRoute(path: '/ai-chat', builder: (_, _) => const AiChatScreen()),
    GoRoute(
      path: '/my-attendance',
      builder: (context, state) {
        final memberId = state.uri.queryParameters['memberId'] ?? '';
        return MyAttendanceScreen(memberId: memberId);
      },
    ),
    GoRoute(
      path: '/ai-assistant',
      builder: (context, state) => const AiChatScreen(),
    ),
    GoRoute(path: '/personal-timeline', builder: (_, _) => const PersonalTimelineScreen()),
    GoRoute(path: '/notifications', builder: (_, _) => const NotificationsScreen()),
    GoRoute(
      path: '/notification-settings',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
    GoRoute(path: '/reports', builder: (_, _) => const ReportsScreen()),
    GoRoute(path: '/revenue-report', builder: (_, _) => const RevenueReportScreen()),
    GoRoute(path: '/attendance-report', builder: (_, _) => const AttendanceReportScreen()),
    GoRoute(path: '/membership-report', builder: (_, _) => const MembershipReportScreen()),
    GoRoute(path: '/growth-report', builder: (_, _) => const GrowthReportScreen()),
    GoRoute(path: '/gym-details', builder: (_, _) => const GymDetailsScreen()),
    GoRoute(path: '/working-hours', builder: (_, _) => const WorkingHoursScreen()),
    GoRoute(path: '/branch-management', builder: (_, _) => const BranchManagementScreen()),
    GoRoute(path: '/branch-detail', builder: (context, state) {
      final branch = state.extra as BranchModel;
      return BranchDetailScreen(branch: branch);
    }),
    GoRoute(path: '/tax-currency', builder: (_, _) => const TaxCurrencyScreen()),
    GoRoute(path: '/theme-settings', builder: (_, _) => const ThemeSettingsScreen()),
    GoRoute(path: '/roles-permissions', builder: (_, _) => const RolesPermissionsScreen()),
    GoRoute(path: '/account-settings', builder: (_, _) => const AccountSettingsScreen()),
    GoRoute(
      path: '/global-search',
      builder: (context, state) => const GlobalSearchScreen(),
    ),
    GoRoute(
      path: '/backup-restore',
      builder: (context, state) => const BackupRestoreScreen(),
    ),
    GoRoute(
      path: '/admin-management',
      builder: (context, state) => const AdminManagementScreen(),
    ),
    GoRoute(
      path: '/admin-user-management',
      builder: (context, state) => const AdminUserManagementScreen(),
    ),
    GoRoute(
      path: '/qr-reveal',
      builder: (context, state) => const QRRevealScreen(),
    ),
    GoRoute(
      path: '/qr-scanner',
      builder: (context, state) => const QRScannerScreen(),
    ),
    GoRoute(
      path: '/reset-member-password',
      builder: (context, state) {
        final memberId = state.uri.queryParameters['memberId'] ?? '';
        return MemberPasswordResetScreen(memberId: memberId);
      },
    ),
    GoRoute(
      path: '/admin-attendance',
      builder: (context, state) => const AdminAttendanceScreen(),
    ),
    GoRoute(
      path: AppRoutes.renewMembership,
      builder: (context, state) {
        final memberId = state.uri.queryParameters['memberId'];
        return RecordPaymentScreen(preselectedMemberId: memberId);
      },
    ),
  ],
);