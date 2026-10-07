import 'package:flutter/material.dart';
import '../../data/models/plan_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_design_tokens.dart';
import 'glass_container.dart';

class PlanCard extends StatelessWidget {
  final PlanModel plan;
  final VoidCallback? onTap;
  final VoidCallback? onToggleStatus;

  const PlanCard({
    super.key,
    required this.plan,
    this.onTap,
    this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    plan.planName,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Switch(
                  value: plan.status == 'active',
                  activeThumbColor: AppColors.success,
                  onChanged: (_) => onToggleStatus?.call(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                plan.durationType,
                style: TextStyle(
                  color: context.accentMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (plan.discountPercent != null && plan.discountPercent! > 0)
                  Text(
                    '₹${plan.price}',
                    style: TextStyle(
                      color: context.textSecondary,
                      decoration: TextDecoration.lineThrough,
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(width: 8),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    '₹${plan.finalPrice}',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
              ],
            ),
            if (plan.isPTIncluded)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'PT Included',
                    style: TextStyle(
                      color: context.accentMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: plan.facilitiesIncluded.map((f) => Chip(
                    label: Text(
                      f,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.textSecondary,
                      ),
                    ),
                    backgroundColor: context.surfaceSunken,
                    padding: EdgeInsets.zero,
                  )).toList(),
            ),
           
          ],
        ),
      ),
    );
  }
}