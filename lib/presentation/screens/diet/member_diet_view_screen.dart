import 'package:flutter/material.dart';
import 'package:gym_management_app/data/models/diet_plan_model.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/meal_log_provider.dart';
import '../../../providers/diet_plan_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../../themes/app_spacing.dart';
import '../../widgets/glass_container.dart';

class MemberDietViewScreen extends StatefulWidget {
  const MemberDietViewScreen({super.key});

  @override
  State<MemberDietViewScreen> createState() => _MemberDietViewScreenState();
}

class _MemberDietViewScreenState extends State<MemberDietViewScreen> {
  bool _isLoading = true;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadDietPlan();
  }

  Future<void> _loadDietPlan() async {
    if (_hasLoaded) return;
    final auth = context.read<AuthProvider>();
    final dietProvider = context.read<DietPlanProvider>();
    final memberId = auth.currentUser?.linkedMemberId ?? '';

    if (memberId.isNotEmpty) {
      await dietProvider.refreshForMember(memberId);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dietProvider = context.watch<DietPlanProvider>();
    final memberId = auth.currentUser?.linkedMemberId ?? '';
    final plan = dietProvider.getActiveForMember(memberId);

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: context.colors.primary),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Loading diet plan…',
                style: TextStyle(color: context.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (plan == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.surfaceAlt,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.no_food_outlined,
                    size: 44,
                    color: context.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No Diet Plan Assigned',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Contact your trainer to get a diet plan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${plan.category} Diet Plan',
          style: TextStyle(color: context.textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (plan.endDate != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                        color:
                            AppColors.primary.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    'Valid till ${plan.endDate!.day}/${plan.endDate!.month}/${plan.endDate!.year}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: context.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.border),
              ),
              child: TabBar(
                tabs: const [
                  Tab(text: 'Today'),
                  Tab(text: 'Weekly'),
                  Tab(text: 'Monthly'),
                ],
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: context.textSecondary,
                dividerColor: Colors.transparent,
                indicatorPadding: const EdgeInsets.all(4),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTodayView(plan, memberId),
                  _buildWeeklyView(plan, memberId),
                  _buildMonthlyView(plan, memberId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TODAY VIEW ====================
  Widget _buildTodayView(DietPlanModel plan, String memberId) {
    final today = DateTime.now();

    return Consumer<MealLogProvider>(
      builder: (context, logProvider, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: plan.meals.length,
          itemBuilder: (context, index) {
            final meal = plan.meals[index];
            final isCompleted = logProvider.isMealCompleted(
              memberId,
              plan.id,
              meal.mealType,
              today,
            );

            return GlassContainer(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // Meal Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getMealIcon(meal.mealType),
                      color: isCompleted
                          ? AppColors.success
                          : AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Meal Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.mealType,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          meal.mealName,
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            _buildChip(
                                '${meal.calories.toInt()} kcal',
                                AppColors.warning),
                            _buildChip(
                                '${meal.protein.toInt()}g protein',
                                AppColors.success),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Status Button
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color:
                            AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: AppColors.success
                                .withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: AppColors.success, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Done',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Flexible(
                      fit: FlexFit.loose,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => logProvider.markMealSkipped(
                                memberId, plan.id, meal.mealType, today),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.warning,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              minimumSize: const Size(0, 32),
                            ),
                            child: const Text(
                              'Skip',
                              style: TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 2),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () => logProvider.markMealCompleted(
                                memberId,
                                plan.id,
                                meal.mealType,
                                today,
                                context),
                            child: const Text(
                              'Complete',
                              style: TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==================== WEEKLY VIEW ====================
  Widget _buildWeeklyView(DietPlanModel plan, String memberId) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return Consumer<MealLogProvider>(
      builder: (context, logProvider, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            final isToday = day.year == now.year &&
                day.month == now.month &&
                day.day == now.day;

            // Get meals completed for this day
            final dayLogs = logProvider.getForDate(memberId, day);
            final completedMeals =
                dayLogs.where((log) => log.status == 'completed').length;
            final totalMeals = plan.meals.length;
            final progress =
                totalMeals > 0 ? completedMeals / totalMeals : 0.0;

            return GlassContainer(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : context.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: isToday
                          ? Border.all(
                              color: AppColors.primary, width: 2)
                          : Border.all(color: context.border),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getDayName(day.weekday),
                            style: TextStyle(
                              color: isToday
                                  ? AppColors.primary
                                  : context.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            day.day.toString(),
                            style: TextStyle(
                              color: isToday
                                  ? AppColors.primary
                                  : context.textPrimary,
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _getDayNameFull(day.weekday),
                              style: TextStyle(
                                color: isToday
                                    ? AppColors.primary
                                    : context.textPrimary,
                                fontWeight: isToday
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            if (isToday) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius:
                                      BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'Today',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor:
                                      context.surfaceAlt,
                                  color: progress >= 1.0
                                      ? AppColors.success
                                      : AppColors.primary,
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: TextStyle(
                                color: context.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$completedMeals / $totalMeals meals completed',
                          style: TextStyle(
                            color: context.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==================== MONTHLY VIEW ====================
  Widget _buildMonthlyView(DietPlanModel plan, String memberId) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday;

    return Consumer<MealLogProvider>(
      builder: (context, logProvider, child) {
        // Get all days with completed meals
        final allLogs = logProvider.allLogs;
        final completedDays = allLogs
            .where((log) =>
                log.memberId == memberId &&
                log.status == 'completed' &&
                log.date.year == now.year &&
                log.date.month == now.month)
            .map((log) => log.date.day)
            .toSet();

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Month Header
            GlassContainer(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_getMonthName(now.month)} ${now.year}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildMonthStat(
                    '${completedDays.length}',
                    'Days Done',
                    AppColors.success,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildMonthStat(
                    '${plan.meals.length * completedDays.length}',
                    'Total Meals',
                    AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Day Grid
            GlassContainer(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  // Weekday Headers
                  Row(
                    children: [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun'
                    ]
                        .map((day) => Expanded(
                              child: Center(
                                child: Text(
                                  day,
                                  style: TextStyle(
                                    color: context.textMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Calendar Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1,
                    ),
                    itemCount: 42,
                    itemBuilder: (context, index) {
                      final day = index - startWeekday + 2;
                      if (day < 1 || day > daysInMonth) {
                        return const SizedBox.shrink();
                      }

                      final isToday = day == now.day;
                      final isCompleted = completedDays.contains(day);

                      return Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.success.withValues(alpha: 0.12)
                              : isToday
                                  ? AppColors.primary
                                      .withValues(alpha: 0.12)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isToday
                              ? Border.all(
                                  color: AppColors.primary, width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                day.toString(),
                                style: TextStyle(
                                  color: isCompleted
                                      ? AppColors.success
                                      : isToday
                                          ? AppColors.primary
                                          : context.textSecondary,
                                  fontWeight: isToday || isCompleted
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                              if (isCompleted)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.success,
                                  size: 11,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Legend
            GlassContainer(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLegendItem(AppColors.success, 'Completed'),
                  _buildLegendItem(AppColors.primary, 'Today'),
                  _buildLegendItem(context.surfaceAlt, 'Missed'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ==================== HELPER METHODS ====================

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast_rounded;
      case 'morning snack':
        return Icons.cookie_rounded;
      case 'lunch':
        return Icons.lunch_dining_rounded;
      case 'evening snack':
        return Icons.cookie_rounded;
      case 'pre workout':
        return Icons.fitness_center_rounded;
      case 'post workout':
        return Icons.fitness_center_rounded;
      case 'dinner':
        return Icons.dinner_dining_rounded;
      case 'bedtime':
        return Icons.nightlight_round;
      default:
        return Icons.restaurant_rounded;
    }
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMonthStat(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: context.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: color, width: 1),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: context.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getDayName(int weekday) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[weekday - 1];
  }

  String _getDayNameFull(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}