import 'package:flutter/material.dart';
import 'package:gym_management_app/data/models/meal_reminder_model.dart';
import 'package:provider/provider.dart';
import '../../../providers/meal_reminder_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/glass_tile.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  bool masterEnabled = true;
  int waterInterval = 2;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final auth = context.read<AuthProvider>();
    final reminderProvider = context.read<MealReminderProvider>();
    final memberId = auth.currentUser?.linkedMemberId ?? '';

    if (memberId.isNotEmpty) {
      await reminderProvider.fetchForMember(memberId);
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final reminderProvider = context.watch<MealReminderProvider>();
    final memberId = auth.currentUser?.linkedMemberId ?? '';
    
    final memberReminders = reminderProvider.getAllForMember(memberId);

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        title: const Text('Reminder Settings'),
        backgroundColor: context.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReminders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Master Enable/Disable
                Material(
                  color: Colors.transparent,
                  child: GlassContainer(
                    child: SwitchListTile(
                      title: Text(
                        'Enable All Meal Reminders',
                        style: TextStyle(color: context.textPrimary),
                      ),
                      subtitle: Text(
                        'Turn on/off all meal reminders',
                        style: TextStyle(color: context.textSecondary),
                      ),
                      value: masterEnabled,
                      onChanged: (v) {
                        setState(() => masterEnabled = v);
                        // Toggle all reminders
                        for (var reminder in memberReminders) {
                          reminderProvider.toggleReminder(reminder.id, v);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Water Reminder
                Material(
                  color: Colors.transparent,
                  child: GlassContainer(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            'Water Reminder Interval',
                            style: TextStyle(color: context.textPrimary),
                          ),
                          subtitle: Text(
                            'Every $waterInterval hours',
                            style: TextStyle(color: context.textSecondary),
                          ),
                          leading: const Icon(
                            Icons.water_drop,
                            color: AppColors.info,
                          ),
                        ),
                        Slider(
                          value: waterInterval.toDouble(),
                          min: 1,
                          max: 4,
                          divisions: 3,
                          label: '$waterInterval hours',
                          onChanged: (v) => setState(() => waterInterval = v.toInt()),
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Individual Meal Reminders
                Text(
                  'Individual Meal Reminders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Toggle individual meal reminders on/off',
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),

                if (memberReminders.isEmpty)
                  GlassContainer(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_off,
                            size: 40,
                            color: context.textSecondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No meal reminders set',
                            style: TextStyle(color: context.textSecondary),
                          ),
                          Text(
                            'Go to Schedule Reminders to set them up',
                            style: TextStyle(color: context.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...memberReminders.map((reminder) => Material(
                    color: Colors.transparent,
                    child: GlassTile(
                      leading: Icon(
                        reminder.isEnabled
                            ? Icons.notifications_active
                            : Icons.notifications_off,
                        color: reminder.isEnabled
                            ? AppColors.success
                            : context.textSecondary,
                        size: 24,
                      ),
                      title: Text(
                        reminder.mealType,
                        style: TextStyle(
                          color: context.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reminder.customMessage ?? 'Meal reminder',
                            style: TextStyle(color: context.textSecondary),
                          ),
                          Text(
                            '⏰ ${reminder.scheduledTime}',
                            style: TextStyle(color: context.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: Switch(
                        value: reminder.isEnabled,
                        onChanged: (value) {
                          reminderProvider.toggleReminder(reminder.id, value);
                        },
                        activeThumbColor: AppColors.primary,
                      ),
                      onTap: () {
                        // Show edit dialog
                        _showEditReminderDialog(context, reminder);
                      },
                    ),
                  )),
              ],
            ),
    );
  }

  void _showEditReminderDialog(BuildContext context, MealReminderModel reminder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surface,
        title: Text(
          'Edit Reminder',
          style: TextStyle(color: context.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meal: ${reminder.mealType}',
              style: TextStyle(color: context.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Time: ${reminder.scheduledTime}',
              style: TextStyle(color: context.textSecondary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Enabled: ',
                  style: TextStyle(color: context.textSecondary),
                ),
                Switch(
                  value: reminder.isEnabled,
                  onChanged: (value) {
                    // Update the reminder
                    context.read<MealReminderProvider>().toggleReminder(reminder.id, value);
                    Navigator.pop(ctx);
                  },
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              // Delete reminder
              context.read<MealReminderProvider>().deleteReminder(reminder.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reminder deleted'),
                  backgroundColor: AppColors.danger,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}