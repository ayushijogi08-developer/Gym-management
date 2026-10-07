import 'package:flutter/material.dart';
import 'package:gym_management_app/data/models/member_model.dart';
import 'package:gym_management_app/providers/achievement_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../../providers/diet_plan_provider.dart';
import '../../../providers/workout_plan_provider.dart';
import '../../../providers/body_progress_provider.dart';
import '../../../providers/attendance_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/macro_progress_ring.dart';

class MemberDashboardHome extends StatelessWidget {
  const MemberDashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final memberProvider = context.watch<MemberProvider>();
    final subscriptionProvider = context.watch<SubscriptionProvider>();
    final dietProvider = context.watch<DietPlanProvider>();
    final workoutProvider = context.watch<WorkoutPlanProvider>();
    final bodyProgressProvider = context.watch<BodyProgressProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();
    final achievementProvider = context.watch<AchievementProvider>();

    final memberId = auth.currentUser?.linkedMemberId ?? '';

    final member = memberProvider.members.firstWhere(
      (m) => m.id == memberId,
      orElse: () => MemberModel(
        id: '',
        fullName: 'Member',
        gender: '',
        phone: '',
        email: '',
        membershipStatus: 'active',
        planName: 'No Plan',
        joiningDate: DateTime.now(),
        expiryDate: DateTime.now(),
      ),
    );

    final activeSubscription =
        subscriptionProvider.getActiveForMember(memberId);
    final activeDiet = dietProvider.getActiveForMember(memberId);
    final activeWorkout = workoutProvider.getActiveForMember(memberId);
    final latestProgress = bodyProgressProvider.getLatest(memberId);
    final totalVisits = attendanceProvider.totalVisits(memberId);

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : 3;

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---------- HEADER ----------
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.2),
                              child: Text(
                                member.fullName.isNotEmpty
                                    ? member.fullName[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontSize: 28,
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hi, ${member.fullName.split(' ').first}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Member ID: ${member.id.isNotEmpty ? member.id : 'N/A'}',
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
                        const SizedBox(height: 24),

                        // ---------- MEMBERSHIP STATUS ----------
                        GlassContainer(
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.green.withValues(alpha: 0.18),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.card_membership,
                                    size: 28,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        activeSubscription != null
                                            ? activeSubscription.status
                                                .toUpperCase()
                                            : 'No Active Plan',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: context.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Expires: ${member.expiryDate.toString().split(' ')[0]}',
                                        style: TextStyle(
                                          color: context.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (activeSubscription == null ||
                                    activeSubscription.status ==
                                        'expired')
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: AppColors.primary),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () => context
                                        .push('/renew-membership'),
                                    child: Text(
                                      'Renew',
                                      style:
                                          TextStyle(color: AppColors.primary),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ---------- QUICK ACCESS ----------
                        Text(
                          'Quick Access',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.05,
                          children: [
                            _buildQuickCard(
                              context,
                              icon: Icons.fitness_center,
                              title: "Today's Workout",
                              subtitle: activeWorkout != null
                                  ? "${activeWorkout.exercises.length} exercises"
                                  : "No plan assigned",
                              color: Colors.orange,
                              onTap: () =>
                                  context.push('/my-workout'),
                            ),
                            _buildQuickCard(
                              context,
                              icon: Icons.restaurant_menu,
                              title: "My Diet",
                              subtitle: activeDiet != null
                                  ? "${activeDiet.meals.length} meals"
                                  : "No plan assigned",
                              color: Colors.green,
                              onTap: () => context.push('/my-diet'),
                            ),
                            _buildQuickCard(
                              context,
                              icon: Icons.trending_up,
                              title: "Body Progress",
                              subtitle: latestProgress != null
                                  ? "${latestProgress.weightKg} kg"
                                  : "Log your stats",
                              color: Colors.blue,
                              onTap: () =>
                                  context.push('/body-progress'),
                            ),
                            _buildQuickCard(
                              context,
                              icon: Icons.qr_code,
                              title: "My QR Code",
                              subtitle: "Gym entry pass",
                              color: Colors.purple,
                              onTap: () => context.push('/qr-reveal'),
                            ),
                            _buildQuickCard(
                              context,
                              icon: Icons.calendar_today,
                              title: "Attendance",
                              subtitle: '$totalVisits visits',
                              color: Colors.teal,
                              onTap: () => context.push(
                                  '/my-attendance?memberId=$memberId'),
                            ),
                            _buildQuickCard(
                              context,
                              icon: Icons.smart_toy,
                              title: "AI Assistant",
                              subtitle: "Ask fitness questions",
                              color: Colors.purpleAccent,
                              onTap: () =>
                                  context.push('/ai-assistant'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // ---------- MONTH SUMMARY ----------
                        Text(
                          'This Month',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                          children: const [
                            MacroProgressRing(
                              progress: 0.75,
                              label: 'Workout',
                              value: '12 / 16',
                              color: Colors.orange,
                            ),
                            MacroProgressRing(
                              progress: 0.65,
                              label: 'Diet',
                              value: '18 / 28',
                              color: Colors.green,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ---------- ACHIEVEMENTS ----------
                        Consumer<AchievementProvider>(
                          builder:
                              (context, achievementProvider, _) {
                            final recentAchievements =
                                achievementProvider
                                    .getByMember(memberId)
                                    .take(3)
                                    .toList();

                            final unseenCount =
                                achievementProvider
                                    .unseenCount(memberId);

                            return GlassContainer(
                              onTap: () =>
                                  context.push('/achievements'),
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.emoji_events,
                                          color: Colors.amber,
                                          size: 26,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Achievements',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight:
                                                FontWeight.bold,
                                            color: context.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (recentAchievements.isEmpty)
                                      Text(
                                        'No achievements yet.\nKeep training!',
                                        style: TextStyle(
                                          color: context.textSecondary,
                                          fontSize: 13,
                                        ),
                                      )
                                    else
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: recentAchievements
                                            .map(
                                              (ach) => Chip(
                                                label: Text(
                                                  ach.title,
                                                  style:
                                                      TextStyle(
                                                    fontSize: 12,
                                                    color: context.textPrimary,
                                                  ),
                                                ),
                                                backgroundColor:
                                                    Colors.amber
                                                        .withValues(
                                                            alpha: 0.18),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    const SizedBox(height: 8),
                                    Text(
                                      unseenCount > 0
                                          ? '$unseenCount new'
                                          : 'All caught up',
                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),

                        Center(
                          child: Text(
                            'Stay consistent. Results will follow. 💪',
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
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickCard(
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
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: context.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
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