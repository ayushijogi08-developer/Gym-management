import 'package:flutter/material.dart';
import 'package:gym_management_app/data/models/diet_plan_model.dart';
import 'package:gym_management_app/domain/entities/user_role.dart';
import 'package:gym_management_app/providers/member_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/diet_plan_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../../themes/app_spacing.dart';
import '../../widgets/glass_container.dart';

class DietPlanListScreen extends StatefulWidget {
  const DietPlanListScreen({super.key});

  @override
  State<DietPlanListScreen> createState() => _DietPlanListScreenState();
}

class _DietPlanListScreenState extends State<DietPlanListScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final dietProvider = context.read<DietPlanProvider>();
      final memberProvider = context.read<MemberProvider>();

      setState(() => _isLoading = true);

      await memberProvider.loadMembers();

      String? trainerId;

      if (auth.currentRole == UserRole.trainer) {
        trainerId =
            auth.currentUser?.linkedTrainerId ?? auth.currentUser?.id ?? '';
        debugPrint("Trainer ID for filtering: '$trainerId'");
      }

      await dietProvider.refreshDietPlans(trainerId: trainerId);

      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  void _showDeleteConfirmation(BuildContext context, DietPlanModel plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.delete_outline_rounded,
            color: Theme.of(context).colorScheme.error, size: 32),
        title: const Text('Delete Diet Plan?'),
        content: Text(
          'Are you sure you want to delete "${plan.category}" for this member?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<DietPlanProvider>()
                  .deleteDietPlan(plan.id, context);
            },
            style: FilledButton.styleFrom(
              backgroundColor:
                  Theme.of(context).colorScheme.errorContainer,
              foregroundColor:
                  Theme.of(context).colorScheme.onErrorContainer,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dietProvider = context.watch<DietPlanProvider>();
    final memberProvider = context.watch<MemberProvider>();

    if (!auth.hasPermission('canEditDietPlans')) {
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
                  'You do not have permission to view diet plans',
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

    final plans = dietProvider.plans;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/dashboard');
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Diet Plans')),
        // When the keyboard appears (e.g. member-name filter input) the
        // bottom inset changes by a few px; resizing prevents sub-pixel
        // clipping at the body edge.
        resizeToAvoidBottomInset: true,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/add-edit-diet-plan'),
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Diet Plan'),
        ),
        body: SafeArea(
          // bottom: false so the FAB can still sit flush against the
          // system gesture bar without re-adding insets that have
          // already been consumed by the Scaffold.
          top: false,
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;

              return _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                              color: context.colors.primary),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Loading diet plans…',
                            style: TextStyle(color: context.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : plans.isEmpty
                      ? _buildEmptyState()
                      : SingleChildScrollView(
                          // Clip.none lets any descendant draw past its
                          // bounds by a pixel without triggering the
                          // RenderFlex overflow stripe (common with status
                          // pills whose text metrics round up).
                          clipBehavior: Clip.none,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          // Allow the scroll view to extend past the bottom
                          // edge so the FloatingActionButton does not
                          // occlude the last plan card.
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isWide ? 2 : 1,
                              // Extra bottom buffer keeps content strictly
                              // inside the cell — accounting for the 1-px
                              // status-pill border on each side and for the
                              // font-metrics rounding of TextStyle.
                              mainAxisExtent: 152,
                              crossAxisSpacing: AppSpacing.md,
                              mainAxisSpacing: AppSpacing.md,
                            ),
                            itemCount: plans.length,
                            itemBuilder: (context, index) {
                              final plan = plans[index];

                              String memberName = 'Unknown Member';
                              try {
                                final member =
                                    memberProvider.members.firstWhere(
                                  (m) => m.id == plan.memberId,
                                );
                                memberName = member.fullName;
                              } catch (_) {
                                // Member not found
                              }

                              return GlassContainer(
                                onTap: () => context.push(
                                    '/add-edit-diet-plan?planId=${plan.id}'),
                                child: Padding(
                                  // Asymmetric vertical padding removes the
                                  // 2-px discrepancy that Row baseline
                                  // alignment leaves at the bottom of the
                                  // cell.
                                  padding: const EdgeInsets.fromLTRB(
                                    AppSpacing.md,
                                    AppSpacing.sm,
                                    AppSpacing.md,
                                    AppSpacing.sm,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    // center the content vertically; relies
                                    // on Flexible so a long category name
                                    // can shrink the row instead of
                                    // overflowing the cell.
                                    children: [
                                      Flexible(
                                        fit: FlexFit.loose,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                plan.category,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: context.textPrimary,
                                                  height: 1.15,
                                                ),
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                maxLines: 1,
                                                softWrap: false,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            // Plain InkWell so the row's
                                            // height is determined by the
                                            // icon (20) plus 4-px padding,
                                            // not by IconButton's default
                                            // 48-px tap target.
                                            InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              onTap: () =>
                                                  _showDeleteConfirmation(
                                                      context, plan),
                                              child: Tooltip(
                                                message: 'Delete',
                                                child: Container(
                                                  width: 28,
                                                  height: 28,
                                                  alignment: Alignment.center,
                                                  child: Icon(
                                                    Icons
                                                        .delete_outline_rounded,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .error,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Member: $memberName',
                                        style: TextStyle(
                                            color: context.textSecondary,
                                            fontSize: 12,
                                            height: 1.25),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        softWrap: false,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${plan.meals.length} meals • ${plan.dailyCalorieTarget.toInt()} kcal',
                                        style: TextStyle(
                                            color: context.textMuted,
                                            fontSize: 12,
                                            height: 1.25),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        softWrap: false,
                                      ),
                                      const SizedBox(height: 8),
                                      // Pill is wrapped in a tiny SizedBox
                                      // sized exactly to its measured height
                                      // so it cannot push the column past
                                      // mainAxisExtent.
                                      SizedBox(
                                        height: 22,
                                        child: _buildStatusPill(plan.isActive),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
            },
          ),
        ),
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
                Icons.restaurant_menu_outlined,
                size: 36,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No diet plans yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create your first diet plan to get started.',
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

  Widget _buildStatusPill(bool isActive) {
    final color = isActive ? AppColors.success : Theme.of(context).colorScheme.error;
    return Container(
      // Padding is set to 0 vertical because the parent SizedBox already
      // constrains height; padding here would push the text baseline
      // and trigger a 1-2 px sub-pixel overflow.
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      alignment: Alignment.center,
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          height: 1.1,
        ),
      ),
    );
  }
}