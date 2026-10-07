import 'package:flutter/material.dart';
import 'package:gym_management_app/data/models/goal_model.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/goal_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../../themes/app_spacing.dart';
import '../../widgets/goal_progress_card.dart';
import '../../widgets/premium_filter_chip.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  bool _isLoading = true;
  String _filter = 'active'; // active, completed, all

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    try {
      final goalProvider = context.read<GoalProvider>();
      final auth = context.read<AuthProvider>();
      final memberId = auth.currentUser?.linkedMemberId ?? '';

      await goalProvider.refreshGoals();
      debugPrint(
          'Loaded ${goalProvider.getActiveGoals(memberId).length} active goals');
    } catch (e) {
      debugPrint('Error loading goals: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final goalProvider = context.watch<GoalProvider>();
    final memberId = auth.currentUser?.linkedMemberId ?? '';

    // Get goals based on filter
    List<GoalModel> goals;
    if (_filter == 'active') {
      goals = goalProvider.getActiveGoals(memberId);
    } else if (_filter == 'completed') {
      goals = goalProvider.getCompletedGoals(memberId);
    } else {
      goals = goalProvider.getAllGoalsForMember(memberId);
    }

    // Calculate stats
    final activeGoals = goalProvider.getActiveGoals(memberId);
    final completedGoals = goalProvider.getCompletedGoals(memberId);
    final totalGoals = activeGoals.length + completedGoals.length;

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: context.background,
        elevation: 0,
        title: Text(
          'My Goals',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: context.textPrimary),
        actions: const [
          SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-edit-goal'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'New Goal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: context.colors.primary),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Loading goals…',
                    style: TextStyle(color: context.textSecondary),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Filter strip
                SizedBox(
                  height: 44,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                    child: Row(
                      children: const [
                        ('active', 'Active'),
                        ('completed', 'Completed'),
                        ('all', 'All Goals'),
                      ].map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.xs),
                          child: PremiumFilterChip(
                            label: entry.$2,
                            isSelected: _filter == entry.$1,
                            onTap: () => setState(() => _filter = entry.$1),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // Stats Summary
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg,
                      AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
                  child: Row(
                    children: [
                      _buildStatCard(
                          'Active',
                          activeGoals.length.toString(),
                          AppColors.warning,
                          Icons.flag_outlined),
                      const SizedBox(width: AppSpacing.sm),
                      _buildStatCard(
                          'Completed',
                          completedGoals.length.toString(),
                          AppColors.success,
                          Icons.check_circle_outline),
                      const SizedBox(width: AppSpacing.sm),
                      _buildStatCard(
                          'Total',
                          totalGoals.toString(),
                          AppColors.primary,
                          Icons.list_alt_rounded),
                    ],
                  ),
                ),
                // Goals List
                Expanded(
                  child: goals.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                              AppSpacing.lg,
                              0,
                              AppSpacing.lg,
                              AppSpacing.xxl),
                          itemCount: goals.length,
                          itemBuilder: (context, index) {
                            final goal = goals[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: GoalProgressCard(
                                goal: goal,
                                showUpdateButton: true,
                                onEdit: () => context.push(
                                  '/add-edit-goal?goalId=${goal.id}',
                                ),
                                // NEW: members can only delete their own
                                // goals; canDeleteGoal enforces that.
                                onDelete: goalProvider.canDeleteGoal(
                                  goal,
                                  actor: auth.currentUser,
                                )
                                    ? () => goalProvider.deleteGoal(
                                          goal.id,
                                          context,
                                        )
                                    : null,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.border),
          boxShadow: AppShadows.of(context).elevation1,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: context.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isCompletedFilter = _filter == 'completed';
    return Center(
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
                isCompletedFilter
                    ? Icons.emoji_events_outlined
                    : Icons.flag_outlined,
                size: 44,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isCompletedFilter ? 'No completed goals yet' : 'No active goals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isCompletedFilter
                  ? 'Keep working towards your goals! 💪'
                  : 'Create your first goal! 🎯',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}