import 'package:flutter/material.dart';
import 'package:gym_management_app/domain/entities/user_role.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/goal_provider.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../../themes/app_spacing.dart';
import '../../widgets/goal_progress_card.dart';

class AllMemberGoalsScreen extends StatefulWidget {
  const AllMemberGoalsScreen({super.key});

  @override
  State<AllMemberGoalsScreen> createState() => _AllMemberGoalsScreenState();
}

class _AllMemberGoalsScreenState extends State<AllMemberGoalsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MemberProvider>().loadMembers();
      context.read<GoalProvider>().refreshGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final goalProvider = context.watch<GoalProvider>();
    final memberProvider = context.watch<MemberProvider>();

    final isTrainer = auth.currentRole == UserRole.trainer;
    final trainerId = auth.currentUser?.linkedTrainerId;

    // Filter members
    var members = isTrainer
        ? memberProvider.members
            .where((m) => m.assignedTrainerId == trainerId)
            .toList()
        : memberProvider.members;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      members = members
          .where((m) => m.fullName.toLowerCase().contains(query))
          .toList();
    }

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: context.background,
        elevation: 0,
        title: Text(
          'All Member Goals',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: context.textPrimary),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: context.textPrimary),
            tooltip: 'Add Goal',
            onPressed: () => context.push('/add-edit-goal'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(color: context.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search by member name...',
                hintStyle: TextStyle(color: context.textSecondary, fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded,
                    color: context.textSecondary, size: 20),
                filled: true,
                fillColor: context.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: context.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: context.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      BorderSide(color: context.colors.primary, width: 1.5),
                ),
              ),
            ),
          ),

          Expanded(
            child: members.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final goals = goalProvider.getActiveGoals(member.id);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.sm),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    member.fullName.isNotEmpty
                                        ? member.fullName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    member.fullName,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle_outline_rounded,
                                    color: AppColors.primary,
                                  ),
                                  tooltip: 'Add Goal for ${member.fullName}',
                                  onPressed: () => context.push(
                                    '/add-edit-goal?memberId=${member.id}',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (goals.isEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.lg),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: context.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: context.border),
                                ),
                                child: Text(
                                  'No active goals',
                                  style: TextStyle(
                                    color: context.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...goals.map(
                              (goal) => Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppSpacing.sm),
                                child: GoalProgressCard(
                                  goal: goal,
                                  onEdit: () => context.push(
                                    '/add-edit-goal?goalId=${goal.id}',
                                  ),
                                  // NEW: delete handler — gated by
                                  // canDeleteGoal so non-admins can't
                                  // wipe member goals from this screen.
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
                              ),
                            ),
                          Divider(height: 32, color: context.border),
                        ],
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
                color: context.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_outlined,
                size: 36,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No members found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different name.'
                  : 'No members are assigned yet.',
              style: TextStyle(
                fontSize: 13,
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}