import 'package:flutter/material.dart';
import 'package:gym_management_app/data/models/member_model.dart';
import 'package:gym_management_app/data/models/goal_model.dart';
import 'package:gym_management_app/presentation/widgets/notification_bell_icon.dart';
import 'package:gym_management_app/providers/meal_log_provider.dart';
import 'package:gym_management_app/providers/goal_provider.dart';
import 'package:gym_management_app/providers/payment_provider.dart';
import 'package:gym_management_app/providers/plan_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../../providers/diet_plan_provider.dart';
import '../../../providers/workout_plan_provider.dart';
import '../../../providers/workout_log_provider.dart';
import '../../../providers/body_progress_provider.dart';
import '../../../providers/attendance_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/member/membership_status_card.dart';
import '../../widgets/member/today_workout_summary_card.dart';
import '../../widgets/member/today_diet_summary_card.dart';
import '../../widgets/member/streak_badge_widget.dart';
import '../../widgets/theme_toggle_button.dart';

class MemberDashboardContent extends StatefulWidget {
  const MemberDashboardContent({super.key});

  @override
  State<MemberDashboardContent> createState() =>
      _MemberDashboardContentState();
}

class _MemberDashboardContentState extends State<MemberDashboardContent> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final memberProvider = context.read<MemberProvider>();
    final dietProvider = context.read<DietPlanProvider>();
    final workoutProvider = context.read<WorkoutPlanProvider>();
    final attendanceProvider = context.read<AttendanceProvider>();
    final goalProvider = context.read<GoalProvider>();
    final bodyProgressProvider = context.read<BodyProgressProvider>();
    final paymentProvider = context.read<PaymentProvider>();

    await paymentProvider.fetchPayments();

    final memberId = auth.currentUser?.linkedMemberId ?? '';

    if (memberId.isNotEmpty) {
      await Future.wait([
        memberProvider.loadMembers(),
        dietProvider.refreshForMember(memberId),
        workoutProvider.getByMember(memberId),
        goalProvider.refreshGoals(),
        bodyProgressProvider.fetchForMember(memberId),
        attendanceProvider.fetchForMember(memberId),
      ]);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final memberProvider = context.watch<MemberProvider>();
    final subscriptionProvider = context.watch<SubscriptionProvider>();
    final planProvider = context.watch<PlanProvider>();
    final dietProvider = context.watch<DietPlanProvider>();
    final workoutProvider = context.watch<WorkoutPlanProvider>();
    final workoutLogProvider = context.watch<WorkoutLogProvider>();
    final bodyProgressProvider = context.watch<BodyProgressProvider>();
    final goalProvider = context.watch<GoalProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();

    final memberId = auth.currentUser?.linkedMemberId ?? '';

    final member = memberProvider.members.firstWhere(
      (m) => m.id == memberId,
      orElse: () => MemberModel(
        id: memberId,
        fullName: auth.currentUser?.name ?? 'Member',
        gender: '',
        phone: '',
        email: '',
        membershipStatus: 'inactive',
        planName: 'No Plan',
        joiningDate: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(days: 30)),
      ),
    );

    final activeSubscription =
        subscriptionProvider.getActiveForMember(memberId);

    String planName = 'No Plan';
    if (activeSubscription != null) {
      final plan = planProvider.getPlanById(activeSubscription.planId);
      planName = plan?.planName ?? 'Active Plan';
    } else {
      planName = member.planName;
    }

    final activeDiet = dietProvider.getActiveForMember(memberId);
    final activeWorkout = workoutProvider.getActiveForMember(memberId);
    final latestProgress = bodyProgressProvider.getLatest(memberId);
    final activeGoals = goalProvider.getActiveGoals(memberId);

    final today = DateTime.now();
    final todayLogs = workoutLogProvider.getForDate(memberId, today);
    final completedCount =
        todayLogs.where((log) => log.status == 'completed').length;
    final totalExercises = activeWorkout?.exercises.length ?? 0;
    final workoutProgress =
        totalExercises > 0 ? completedCount / totalExercises : 0.0;

    final streak = attendanceProvider.currentStreak(memberId);

    final isActive = member.membershipStatus.toLowerCase() == 'active' ||
        activeSubscription?.status.toLowerCase() == 'active';
    final expiryDate = activeSubscription?.endDate ?? member.expiryDate;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 600;

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: context.background,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: context.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: context.textPrimary),
            onPressed: () => context.push('/global-search'),
          ),
          const NotificationBellIcon(),
          const ThemeToggleButton(),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER
                      Row(
                        children: [
                          CircleAvatar(
                            radius: isSmall ? 28 : 32,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.2),
                            child: Text(
                              member.fullName.isNotEmpty
                                  ? member.fullName[0].toUpperCase()
                                  : 'M',
                              style: TextStyle(
                                fontSize: isSmall ? 22 : 28,
                                color: context.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hi, ${member.fullName.split(' ').first}',
                                  style: TextStyle(
                                    fontSize: isSmall ? 20 : 24,
                                    fontWeight: FontWeight.bold,
                                    color: context.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  planName,
                                  style: TextStyle(
                                    color: context.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // MEMBERSHIP
                      MembershipStatusCard(
                        planName: isActive
                            ? planName.toUpperCase()
                            : 'No Active Plan',
                        expiryDate:
                            '${expiryDate.day}/${expiryDate.month}/${expiryDate.year}',
                        status: isActive ? 'active' : 'inactive',
                      ),
                      const SizedBox(height: 20),

                      // TODAY SECTION
                      Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      isSmall
                          ? Column(
                              children: [
                                _TodayWorkoutCard(
                                  memberId: memberId,
                                  totalExercises: totalExercises,
                                  completedCount: completedCount,
                                  progress: workoutProgress,
                                ),
                                const SizedBox(height: 12),
                                _TodayDietCard(
                                  memberId: memberId,
                                  activeDiet: activeDiet,
                                  today: today,
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: _TodayWorkoutCard(
                                    memberId: memberId,
                                    totalExercises: totalExercises,
                                    completedCount: completedCount,
                                    progress: workoutProgress,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _TodayDietCard(
                                    memberId: memberId,
                                    activeDiet: activeDiet,
                                    today: today,
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 20),

                      // PROGRESS SECTION
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      isSmall
                          ? Column(
                              children: [
                                _buildProgressStreak(streak),
                                const SizedBox(height: 12),
                                _buildGoalProgressCard(context, activeGoals),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: _buildProgressStreak(streak),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildGoalProgressCard(
                                    context,
                                    activeGoals,
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 16),

                      // BODY PROGRESS
                      GlassContainer(
                        onTap: () => context.push('/body-progress'),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.trending_up,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Body Progress',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: context.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      latestProgress != null
                                          ? '${latestProgress.weightKg.toStringAsFixed(1)} kg • BMI ${latestProgress.bmi?.toStringAsFixed(1) ?? '--'}'
                                          : 'No data logged yet',
                                      style: TextStyle(
                                        color: context.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  color: context.textSecondary),
                            ],
                          ),
                        ),
                      ),
                      if (activeGoals.length > 1) ...[
                        const SizedBox(height: 12),
                        _buildGoalProgressCard(context, activeGoals),
                      ],
                      const SizedBox(height: 24),

                      // SHORTCUTS
                      Text(
                        'Shortcuts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ShortcutsGrid(
                        memberId: memberId,
                        streak: streak,
                        attendanceProvider: attendanceProvider,
                        activeGoals: activeGoals,
                        isSmall: isSmall,
                      ),
                      const SizedBox(height: 28),

                      Center(
                        child: Text(
                          'Keep pushing! 💪',
                          style: TextStyle(
                            fontSize: 15,
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressStreak(int streak) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Streak',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            StreakBadgeWidget(streakDays: streak),
            const SizedBox(height: 6),
            Text(
              '$streak day streak',
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgressCard(
    BuildContext context,
    List<GoalModel> activeGoals,
  ) {
    if (activeGoals.isEmpty) {
      return GlassContainer(
        onTap: () => context.push('/goals'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.flag, color: Colors.purpleAccent, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Goals',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'No active goals. Set your first goal! 🎯',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: context.textSecondary),
            ],
          ),
        ),
      );
    }

    final goal = activeGoals.first;
    final progress = goal.progressPercentage;
    final isCompleted = goal.isCompleted;

    return GlassContainer(
      onTap: () => context.push('/goals'),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.flag,
                  color: Colors.purpleAccent,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Goals',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const Spacer(),
                Flexible(
                  fit: FlexFit.loose,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.withValues(alpha: 0.12)
                          : Colors.purpleAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCompleted ? Colors.green : Colors.purpleAccent,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isCompleted ? 'Completed' : '${progress.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: isCompleted ? Colors.green : Colors.purpleAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              goal.goalTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (progress / 100).clamp(0.0, 1.0),
                    backgroundColor: context.border.withValues(alpha: 0.4),
                    color: isCompleted ? Colors.green : Colors.purpleAccent,
                    minHeight: 5,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${goal.currentValue.toStringAsFixed(1)} / ${goal.targetValue.toStringAsFixed(1)} ${goal.unit}',
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            if (activeGoals.length > 1) ...[
              const SizedBox(height: 6),
              Text(
                '+ ${activeGoals.length - 1} more goal(s)',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TodayWorkoutCard extends StatelessWidget {
  final String memberId;
  final int totalExercises;
  final int completedCount;
  final double progress;

  const _TodayWorkoutCard({
    required this.memberId,
    required this.totalExercises,
    required this.completedCount,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: TodayWorkoutSummaryCard(
        exercisesCount: totalExercises.toString(),
        completedCount: completedCount.toString(),
        progress: progress,
        onTap: () => context.push('/my-workout'),
      ),
    );
  }
}

class _TodayDietCard extends StatelessWidget {
  final String memberId;
  final dynamic activeDiet;
  final DateTime today;

  const _TodayDietCard({
    required this.memberId,
    required this.activeDiet,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    final mealLogProvider = context.read<MealLogProvider>();
    final todayMealLogs = mealLogProvider.getForDate(memberId, today);
    final mealCompletedCount =
        todayMealLogs.where((log) => log.status == 'completed').length;
    final totalMeals = activeDiet?.meals.length ?? 8;

    return SizedBox(
      height: 140,
      child: TodayDietSummaryCard(
        mealsCompleted: mealCompletedCount.toString(),
        totalMeals: totalMeals.toString(),
        onTap: () => context.push('/my-diet'),
      ),
    );
  }
}

class _ShortcutsGrid extends StatelessWidget {
  final String memberId;
  final int streak;
  final AttendanceProvider attendanceProvider;
  final List<GoalModel> activeGoals;
  final bool isSmall;

  const _ShortcutsGrid({
    required this.memberId,
    required this.streak,
    required this.attendanceProvider,
    required this.activeGoals,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = isSmall ? 2 : 3;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: isSmall ? 1.0 : 1.1,
      children: [
        _shortcutTile(
          context,
          icon: Icons.history,
          title: 'Workout History',
          subtitle: 'Past sessions',
          color: Colors.purple,
          onTap: () => context.push('/workout-history'),
        ),
        _shortcutTile(
          context,
          icon: Icons.calendar_today,
          title: 'Attendance',
          subtitle:
              '${attendanceProvider.totalVisits(memberId)} visits • $streak day streak',
          color: Colors.teal,
          onTap: () =>
              context.push('/my-attendance?memberId=$memberId'),
        ),
        _shortcutTile(
          context,
          icon: Icons.flag,
          title: 'My Goals',
          subtitle: activeGoals.isNotEmpty
              ? '${activeGoals.length} active'
              : 'Set your goals',
          color: Colors.purpleAccent,
          onTap: () => context.push('/goals'),
        ),
        _shortcutTile(
          context,
          icon: Icons.notifications_active,
          title: 'Meal Reminders',
          subtitle: 'Schedule alerts',
          color: Colors.orange,
          onTap: () =>
              context.push('/reminder-schedule?memberId=$memberId'),
        ),
        _shortcutTile(
          context,
          icon: Icons.emoji_events,
          title: 'Achievements',
          subtitle: 'Badges & milestones',
          color: Colors.amber,
          onTap: () => context.push('/achievements'),
        ),
        _shortcutTile(
          context,
          icon: Icons.smart_toy,
          title: 'AI Assistant',
          subtitle: 'Ask fitness questions',
          color: Colors.purple,
          onTap: () => context.push('/ai-assistant'),
        ),
        if (!isSmall)
          _shortcutTile(
            context,
            icon: Icons.timeline,
            title: 'My Timeline',
            subtitle: 'Fitness journey',
            color: Colors.indigo,
            onTap: () => context.push('/personal-timeline'),
          ),
      ],
    );
  }

  Widget _shortcutTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlassContainer(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: context.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}