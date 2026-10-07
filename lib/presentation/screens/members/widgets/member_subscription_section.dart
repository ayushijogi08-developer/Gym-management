import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/subscription_model.dart';
import '../../../../data/models/plan_model.dart';
import '../../../../providers/subscription_provider.dart';
import '../../../../providers/plan_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../utils/subscription_status_helper.dart';
import '../../../../themes/app_colors.dart';
import '../../../../themes/app_design_tokens.dart';

class MemberSubscriptionSection extends StatelessWidget {
  final String memberId;
  final bool isEditMode; // true when editing existing member

  const MemberSubscriptionSection({
    super.key,
    required this.memberId,
    this.isEditMode = true,
  });

  @override
  Widget build(BuildContext context) {
    final subProvider = context.watch<SubscriptionProvider>();
    final planProvider = context.watch<PlanProvider>();
    final auth = context.watch<AuthProvider>();

    final activeSub = subProvider.getActiveForMember(memberId);
    final status = SubscriptionStatusHelper.computeStatus(activeSub);
    final canManageSubs = auth.hasPermission('canManageSubscriptions'); // Define in permissions.dart

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Membership & Subscription',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.textPrimary),
        ),
        const SizedBox(height: 12),

        if (activeSub != null) ...[
          _buildCurrentSubscriptionCard(context, activeSub, status, planProvider),
          const SizedBox(height: 16),
        ] else ...[
          Card(
            color: AppColors.danger.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('No Active Subscription', style: TextStyle(color: AppColors.danger)),
            ),
          ),
        ],

        if (canManageSubs && isEditMode) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showPlanSelector(context, memberId, planProvider, subProvider, isUpgrade: false),
                icon: const Icon(Icons.refresh),
                label: const Text('Renew'),
              ),
              ElevatedButton.icon(
                onPressed: () => _showPlanSelector(context, memberId, planProvider, subProvider, isUpgrade: true),
                icon: const Icon(Icons.upgrade),
                label: const Text('Upgrade'),
              ),
              if (activeSub?.status == 'active')
                ElevatedButton.icon(
                  onPressed: () => subProvider.pauseSubscription(memberId),
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                ),
              if (activeSub?.status == 'paused')
                ElevatedButton.icon(
                  onPressed: () => subProvider.resumeSubscription(memberId),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Resume'),
                ),
              ElevatedButton.icon(
                onPressed: () => _confirmCancel(context, memberId, subProvider),
                icon: const Icon(Icons.cancel),
                label: const Text('Cancel'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              ),
            ],
          ),
        ],
      ],
    );
  }

 Widget _buildCurrentSubscriptionCard(BuildContext context, SubscriptionModel sub, String status, PlanProvider planProvider) {
    // CHANGE: Use planProvider.plans if that is your getter, or check your PlanProvider.dart
    final plan = planProvider.plans.firstWhere((p) => p.id == sub.planId, orElse: () => PlanModel(id: '', planName: 'Unknown', durationType: '', durationInDays: 0, price: 0));

    return Card(
      color: context.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Corrected to use planName
                Expanded(
                  child: Text(
                    plan.planName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  fit: FlexFit.loose,
                  child: Chip(
                    label: Text(
                      status.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPlanSelector(BuildContext context, String memberId, PlanProvider planProvider, SubscriptionProvider subProvider, {required bool isUpgrade}) {
    // Simple dialog with plan list
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isUpgrade ? 'Upgrade Plan' : 'Select Plan'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: planProvider.plans.length,
            itemBuilder: (ctx, i) {
              final plan = planProvider.plans[i];
              return ListTile(
                title: Text(plan.planName),
                subtitle: Text('₹${plan.price} • ${plan.durationInDays} days'),
                onTap: () {
                  if (isUpgrade) {
                    subProvider.upgradeSubscription(memberId, plan.id, plan,context);
                  } else {
                    subProvider.purchaseSubscription(memberId, plan.id, plan, context);
                  }
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context, String memberId, SubscriptionProvider subProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Subscription?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
          TextButton(
            onPressed: () {
              subProvider.cancelSubscription(memberId);
              Navigator.pop(ctx);
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}