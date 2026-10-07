import 'package:flutter/material.dart';
import 'package:gym_management_app/data/models/diet_plan_model.dart';
import 'package:provider/provider.dart';
import '../../../providers/meal_reminder_provider.dart';
import '../../../providers/diet_plan_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/glass_tile.dart';
import '../../../data/models/meal_reminder_model.dart';
import '../../../services/local_notification_service.dart';

class ReminderScheduleScreen extends StatefulWidget {
  final String memberId;
  const ReminderScheduleScreen({super.key, required this.memberId});

  @override
  State<ReminderScheduleScreen> createState() => _ReminderScheduleScreenState();
}

class _ReminderScheduleScreenState extends State<ReminderScheduleScreen> {
  final Map<String, String> _scheduledTimes = {};
  final Map<String, bool> _enabled = {};
  bool _isSaving = false;
  bool _isLoading = true;
  DietPlanModel? _plan;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final dietProvider = context.read<DietPlanProvider>();
    final plan = dietProvider.getActiveForMember(widget.memberId);
    
    if (mounted) {
      setState(() {
        _plan = plan;
        _isLoading = false;
        
        // Initialize times if plan exists
        if (plan != null && _scheduledTimes.isEmpty) {
          for (var meal in plan.meals) {
            _scheduledTimes[meal.mealType] = _getDefaultTime(meal.mealType);
            _enabled[meal.mealType] = true;
          }
        }
      });
    }
  }

  // Helper method for default times - MOVED TO CLASS LEVEL
  String _getDefaultTime(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return '08:00';
      case 'morning snack':
        return '10:30';
      case 'lunch':
        return '13:00';
      case 'evening snack':
        return '16:30';
      case 'pre workout':
        return '07:00';
      case 'post workout':
        return '09:00';
      case 'dinner':
        return '20:00';
      case 'bedtime':
        return '22:00';
      default:
        return '12:00';
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.background,
        appBar: AppBar(title: const Text('Schedule Reminders')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (plan == null) {
      return Scaffold(
        backgroundColor: context.background,
        appBar: AppBar(title: const Text('Schedule Reminders')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant_menu, size: 64, color: context.textSecondary),
              const SizedBox(height: 16),
              Text(
                'No active diet plan',
                style: TextStyle(color: context.textPrimary, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Please assign a diet plan first',
                style: TextStyle(color: context.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        title: const Text('Schedule Reminders'),
        backgroundColor: context.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: context.surface,
                  title: Text('Meal Reminders', style: TextStyle(color: context.textPrimary)),
                  content: Text(
                    'Set reminders for your meals. You will receive notifications at the scheduled times.\n\n'
                    '🔔 ON - Reminder is active\n'
                    '🔕 OFF - Reminder is disabled',
                    style: TextStyle(color: context.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: plan.meals.length,
        itemBuilder: (context, index) {
          final meal = plan.meals[index];
          final currentTime = _scheduledTimes[meal.mealType] ?? _getDefaultTime(meal.mealType);
          final isEnabled = _enabled[meal.mealType] ?? true;

          return GlassTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getMealIcon(meal.mealType),
                color: AppColors.primary,
                size: 22,
              ),
            ),
            title: Text(
              meal.mealType,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.mealName,
                  style: TextStyle(color: context.textSecondary),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: context.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      currentTime,
                      style: TextStyle(color: context.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Switch(
              value: isEnabled,
              onChanged: (val) => setState(() => _enabled[meal.mealType] = val),
              activeThumbColor: AppColors.primary,
            ),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _parseTime(currentTime),
              );
              if (time != null) {
                setState(() {
                  _scheduledTimes[meal.mealType] = 
                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                });
              }
            },
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(plan.id),
    );
  }

  Widget _buildBottomBar(String dietPlanId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // TEST BUTTON
          GradientButton(
            label: '🔔 Test Notification Now',
            isLoading: _isSaving,
            onPressed: () async {
              // Get first enabled meal
              final firstMeal = _scheduledTimes.keys.firstWhere(
                (key) => _enabled[key] == true,
                orElse: () => _scheduledTimes.keys.first,
              );
              
              final reminder = MealReminderModel(
                id: 'test_${DateTime.now().millisecondsSinceEpoch}',
                memberId: widget.memberId,
                dietPlanId: dietPlanId,
                mealType: firstMeal,
                scheduledTime: _scheduledTimes[firstMeal] ?? '08:00',
                customMessage: '🔔 Test reminder! Time for $firstMeal 🍽️',
                isEnabled: true,
                repeatDaily: true,
              );
              
              await LocalNotificationService.showMealReminder(
                reminder.customMessage ?? 'Time for $firstMeal!',
                firstMeal,
                reminder.id,
              );
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Test notification sent! Check your notifications.'),
                    backgroundColor: AppColors.success,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          GradientButton(
            label: '💾 Save & Schedule Reminders',
            isLoading: _isSaving,
            onPressed: _saveReminders,
          ),
        ],
      ),
    );
  }

  Future<void> _saveReminders() async {
    setState(() => _isSaving = true);

    try {
      final reminderProvider = context.read<MealReminderProvider>();
      
      int scheduledCount = 0;
      for (var entry in _scheduledTimes.entries) {
        final mealType = entry.key;
        final time = entry.value;
        final isEnabled = _enabled[mealType] ?? true;

        final reminder = MealReminderModel(
          id: '${widget.memberId}_${mealType}_${DateTime.now().millisecondsSinceEpoch}',
          memberId: widget.memberId,
          dietPlanId: '', // Will be set from diet plan
          mealType: mealType,
          scheduledTime: time,
          customMessage: 'Time for $mealType! 🍽️',
          isEnabled: isEnabled,
          repeatDaily: true,
        );

        await reminderProvider.saveReminder(reminder, mealType);
        scheduledCount++;
      }

      // Check pending notifications
      final pending = await LocalNotificationService.getPendingNotifications();
      print('📊 Total pending notifications: ${pending.length}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $scheduledCount reminders scheduled successfully!'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('❌ Error saving reminders: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'morning snack':
        return Icons.cookie;
      case 'lunch':
        return Icons.lunch_dining;
      case 'evening snack':
        return Icons.cookie;
      case 'pre workout':
        return Icons.fitness_center;
      case 'post workout':
        return Icons.fitness_center;
      case 'dinner':
        return Icons.dinner_dining;
      case 'bedtime':
        return Icons.nightlife;
      case 'protein shake':
        return Icons.local_drink;
      default:
        return Icons.restaurant;
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}