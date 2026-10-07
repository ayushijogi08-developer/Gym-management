import 'package:flutter/material.dart';
import '../../data/models/trainer_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_design_tokens.dart';
import '../widgets/glass_container.dart';

class TrainerCard extends StatelessWidget {
  final TrainerModel trainer;
  final VoidCallback? onTap;

  const TrainerCard({super.key, required this.trainer, this.onTap});

  @override
  Widget build(BuildContext context) {
    final workingDaysText = trainer.workingDays.isNotEmpty
        ? trainer.workingDays.join(', ')
        : 'Not set';

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: Text(
                    trainer.fullName.isNotEmpty
                        ? trainer.fullName[0].toUpperCase()
                        : 'T',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: context.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trainer.fullName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        trainer.specialization,
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trainer.status == 'active'
                        ? AppColors.success.withValues(alpha: 0.2)
                        : AppColors.danger.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    trainer.status.toUpperCase(),
                    style: TextStyle(
                      color: trainer.status == 'active'
                          ? AppColors.success
                          : AppColors.danger,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time,
                    size: 14, color: context.textSecondary),
                const SizedBox(width: 4),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    'Shift: ${trainer.shiftStart} - ${trainer.shiftEnd}',
                    style: TextStyle(
                        fontSize: 12, color: context.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
                const Spacer(),
                Icon(Icons.work_history_outlined,
                    size: 14, color: context.primary),
                const SizedBox(width: 4),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    '${trainer.experienceYears} yrs exp',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: context.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_month,
                    size: 14, color: context.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Days: $workingDaysText',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}