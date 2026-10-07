import 'package:flutter/material.dart';
import 'package:gym_management_app/data/models/meal_reminder_model.dart';
import 'package:gym_management_app/providers/meal_reminder_provider.dart';
import 'package:gym_management_app/providers/member_provider.dart';
import 'package:gym_management_app/themes/app_colors.dart';
import 'package:gym_management_app/themes/app_design_tokens.dart';
import 'package:provider/provider.dart';
import '../../widgets/glass_tile.dart';

class AllRemindersOverviewScreen extends StatelessWidget {
  const AllRemindersOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(title: const Text('All Reminders')),
      body: Consumer<MealReminderProvider>(
        builder: (context, provider, _) {
          final reminders = provider.reminders;

          if (reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: context.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    'No reminders found',
                    style: TextStyle(color: context.textPrimary, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Members need to set up their meal reminders',
                    style: TextStyle(color: context.textSecondary),
                  ),
                ],
              ),
            );
          }

          // Group reminders by memberId
          final grouped = <String, List<MealReminderModel>>{};
          for (final r in reminders) {
            grouped.putIfAbsent(r.memberId, () => []).add(r);
          }

          final memberIds = grouped.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: memberIds.length,
            itemBuilder: (context, index) {
              final memberId = memberIds[index];
              final members = context.read<MemberProvider>().members;

              String memberName = 'Unknown Member';
              try {
                final member = members.firstWhere((m) => m.id == memberId);
                memberName = member.fullName;
              } catch (e) {
                // Member not found
              }

              final memberReminders = grouped[memberId]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                    child: Text(
                      memberName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  ...memberReminders.map((reminder) =>
                    GlassTile(
                      leading: Icon(
                        reminder.isEnabled ? Icons.notifications_active : Icons.notifications_off,
                        color: reminder.isEnabled ? AppColors.success : context.textSecondary,
                        size: 24,
                      ),
                      title: Text(
                        reminder.customMessage ?? reminder.mealType,
                        style: TextStyle(color: context.textPrimary),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reminder.mealType,
                            style: TextStyle(color: context.textSecondary),
                          ),
                          Text(
                            '⏰ ${reminder.scheduledTime}',
                            style: TextStyle(color: context.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: reminder.isEnabled
                              ? AppColors.success.withValues(alpha: 0.2)
                              : AppColors.danger.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: reminder.isEnabled ? AppColors.success : AppColors.danger,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          reminder.isEnabled ? 'ON' : 'OFF',
                          style: TextStyle(
                            color: reminder.isEnabled ? AppColors.success : AppColors.danger,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      onTap: () {
                        // Show details or toggle
                      },
                    ),
                  ),
                  Divider(color: context.border, height: 32),
                ],
              );
            },
          );
        },
      ),
    );
  }
}