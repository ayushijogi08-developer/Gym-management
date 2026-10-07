import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/plan_provider.dart';
import '../../../themes/app_design_tokens.dart';
import '../../../themes/app_spacing.dart';
import '../../widgets/plan_card.dart';
import '../../widgets/premium_filter_chip.dart';
import 'add_edit_plan_screen.dart';
import '../../../providers/auth_provider.dart';
import '../settings/settings_screen.dart';
import 'package:gym_management_app/utils/route_helper.dart';

class PlanListScreen extends StatefulWidget {
  const PlanListScreen({super.key});

  @override
  State<PlanListScreen> createState() => _PlanListScreenState();
}

class _PlanListScreenState extends State<PlanListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanProvider>().loadPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          buildAppRoute(const SettingsScreen()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Membership Plans'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 700;
              final crossAxisCount = constraints.maxWidth >= 1100
                  ? 3
                  : (constraints.maxWidth >= 700 ? 2 : 1);

              return Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 36,
                      child: Consumer<PlanProvider>(
                        builder: (context, provider, _) {
                          return ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              for (final filter in const ['All', 'Active', 'Inactive']) ...[
                                PremiumFilterChip(
                                  label: filter,
                                  isSelected: provider.currentFilter == filter,
                                  onTap: () => provider.setFilter(filter),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Expanded(
                      child: Consumer<PlanProvider>(
                        builder: (context, provider, _) {
                          final plans = provider.plans;
                          if (plans.isEmpty) {
                            return _EmptyPlans();
                          }
                          if (crossAxisCount == 1) {
                            return ListView.separated(
                              itemCount: plans.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                final plan = plans[index];
                                return PlanCard(
                                  plan: plan,
                                  onTap: () => Navigator.of(context).push(
                                      buildAppRoute(AddEditPlanScreen(
                                          existingPlan: plan))),
                                  onToggleStatus: context
                                          .read<AuthProvider>()
                                          .hasPermission('canManagePlans')
                                      ? () => context
                                          .read<PlanProvider>()
                                          .togglePlanStatus(plan.id)
                                      : null,
                                );
                              },
                            );
                          }
                          return GridView.builder(
                            itemCount: plans.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: isWide ? 1.0 : 1.35,
                            ),
                            itemBuilder: (context, index) {
                              final plan = plans[index];
                              return PlanCard(
                                plan: plan,
                                onTap: () => Navigator.of(context).push(
                                  buildAppRoute(
                                    AddEditPlanScreen(existingPlan: plan),
                                  ),
                                ),
                                onToggleStatus: context
                                        .read<AuthProvider>()
                                        .hasPermission('canManagePlans')
                                    ? () => context
                                        .read<PlanProvider>()
                                        .togglePlanStatus(plan.id)
                                    : null,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        floatingActionButton: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (!auth.hasPermission('canManagePlans')) {
              return const SizedBox.shrink();
            }
            return FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  buildAppRoute(const AddEditPlanScreen()),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Plan'),
            );
          },
        ),
      ),
    );
  }
}

class _EmptyPlans extends StatelessWidget {
  const _EmptyPlans();

  @override
  Widget build(BuildContext context) {
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
                Icons.card_membership_outlined,
                size: 36,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No plans yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create your first membership plan to get started.',
              style: TextStyle(fontSize: 13, color: context.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}