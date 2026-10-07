import 'package:flutter/material.dart';
import 'package:gym_management_app/data/models/member_model.dart';
import 'package:gym_management_app/domain/entities/user_role.dart';
import 'package:gym_management_app/providers/member_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/workout_plan_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../../themes/app_spacing.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/workout_category_chip.dart';

class WorkoutPlanListScreen extends StatefulWidget {
  const WorkoutPlanListScreen({super.key});

  @override
  State<WorkoutPlanListScreen> createState() => _WorkoutPlanListScreenState();
}

class _WorkoutPlanListScreenState extends State<WorkoutPlanListScreen> {
  String? selectedCategory;
  final List<String> _categories = [
    "Muscle Building",
    "Cardio",
    "Flexibility",
    "Strength"
  ];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkoutPlans();
  }

  Future<void> _loadWorkoutPlans() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final workoutProvider = context.read<WorkoutPlanProvider>();

    if (auth.currentRole == UserRole.trainer) {
      final trainerId = auth.currentUser?.linkedTrainerId ?? '';
      if (trainerId.isNotEmpty) workoutProvider.getByTrainer(trainerId);
    } else if (auth.currentRole == UserRole.member) {
      final memberId = auth.currentUser?.linkedMemberId ?? '';
      if (memberId.isNotEmpty) await workoutProvider.getByMember(memberId);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final workoutProvider = context.watch<WorkoutPlanProvider>();
    final memberProvider = context.watch<MemberProvider>();

    if (!auth.hasPermission('canEditWorkoutPlans')) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.surfaceAlt,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock_outline,
                      size: 36,
                      color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Access Denied',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'You do not have permission to view workout plans',
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

    final allPlans = workoutProvider.getAll();
    final filteredPlans = selectedCategory == null
        ? allPlans
        : allPlans.where((p) => p.category == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Plans')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-edit-workout-plan'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Workout Plan'),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: context.colors.primary),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Loading workout plans…',
                    style: TextStyle(color: context.textSecondary),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: 44,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                    child: Row(
                      children: _categories.map((cat) {
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.xs),
                          child: WorkoutCategoryChip(
                            category: cat,
                            isSelected: selectedCategory == cat,
                            onTap: () => setState(() =>
                                selectedCategory =
                                    selectedCategory == cat ? null : cat),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredPlans.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                              AppSpacing.lg,
                              0,
                              AppSpacing.lg,
                              AppSpacing.xxl),
                          itemCount: filteredPlans.length,
                          itemBuilder: (context, index) {
                            final plan = filteredPlans[index];
                            final member = memberProvider.members.firstWhere(
                              (m) => m.id == plan.memberId,
                              orElse: () => MemberModel(
                                  id: plan.memberId,
                                  fullName: 'Unknown',
                                  gender: '',
                                  phone: '',
                                  email: '',
                                  membershipStatus: '',
                                  planName: '',
                                  joiningDate: DateTime.now(),
                                  expiryDate: DateTime.now()),
                            );

                            return GlassContainer(
                              margin:
                                  const EdgeInsets.only(bottom: AppSpacing.sm),
                              onTap: () => context.push(
                                  '/add-edit-workout-plan?planId=${plan.id}'),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.all(AppSpacing.md),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          plan.category,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: context.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Member: ${member.fullName}',
                                          style: TextStyle(
                                              color: context.textSecondary,
                                              fontSize: 13),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${plan.exercises.length} exercises',
                                          style: TextStyle(
                                              color: context.textMuted,
                                              fontSize: 13),
                                        ),
                                        const SizedBox(height: AppSpacing.sm),
                                        _buildStatusPill(plan.isActive),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    right: 4,
                                    top: 4,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.delete_outline_rounded,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error,
                                      ),
                                      tooltip: 'Delete plan',
                                      onPressed: () =>
                                          _confirmDelete(context, plan.id),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fitness_center_outlined,
                size: 36,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No workout plans found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              selectedCategory == null
                  ? 'Create your first workout plan to get started.'
                  : 'No plans in "${selectedCategory!}" category yet.',
              style: TextStyle(fontSize: 13, color: context.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(bool isActive) {
    final color = isActive
        ? AppColors.success
        : Theme.of(context).colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String planId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.delete_outline_rounded,
            color: Theme.of(context).colorScheme.error, size: 32),
        title: const Text('Delete Workout Plan?'),
        content: const Text(
            'Are you sure you want to delete this workout plan? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.errorContainer,
              foregroundColor:
                  Theme.of(ctx).colorScheme.onErrorContainer,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<WorkoutPlanProvider>().deleteWorkoutPlan(planId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Plan deleted')));
      }
    }
  }
}