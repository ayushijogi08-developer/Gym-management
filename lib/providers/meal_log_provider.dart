import 'package:flutter/material.dart';
import 'package:gym_management_app/services/goal_recalc_hook.dart';
import 'package:provider/provider.dart';
import '../data/models/meal_log_model.dart';
import '../data/repositories/meal_log_repository.dart';
import 'timeline_provider.dart';

class MealLogProvider extends ChangeNotifier {
  final MealLogRepository _repo = MealLogRepository();

  // ADD THIS: Getter for all logs
  List<MealLogModel> get allLogs => _repo.getAll();

  List<MealLogModel> getForDate(String memberId, DateTime date) {
    return _repo.getForDate(memberId, date);
  }

  // NEW: Check if meal is completed today
  bool isMealCompleted(String memberId, String dietPlanId, String mealType, DateTime date) {
    final logs = getForDate(memberId, date);
    return logs.any((log) =>
        log.mealType == mealType &&
        log.status == 'completed');
  }

  Future<void> markMealCompleted(
    String memberId,
    String dietPlanId,
    String mealType,
    DateTime date,
    BuildContext context,
  ) async {
    final log = MealLogModel(
      id: '${memberId}_${date.toIso8601String().split('T')[0]}_$mealType',
      memberId: memberId,
      dietPlanId: dietPlanId,
      mealType: mealType,
      date: date,
      status: 'completed',
      loggedAt: DateTime.now(),
    );

    await _repo.addOrUpdate(log);

    context.read<TimelineProvider>().logEvent(
      memberId: memberId,
      eventType: 'diet_completed',
      title: 'Meal Logged',
      subtitle: mealType,
      iconAsset: 'assets/icons/diet.png',
    );

    notifyListeners();

    // AUTOMATIC GOAL UPDATES
    // Fan out to diet-log goals via the centralized post-save
    // hook. The hook handles context building and milestone
    // emission.
    await GoalRecalcHook.instance.onMetricSourceSaved(
      memberId: memberId,
      source: MetricSource.meal,
      context: context,
    );
  }

  Future<void> resetMeal(String logId) async {
    try {
      print("Attempting to reset meal: $logId");
      await _repo.delete(logId);
      print("Meal reset successfully");
      notifyListeners();
    } catch (e) {
      print("Error resetting meal: $e");
    }
  }

  int getCompletedCount(String memberId, DateTime date) {
    return getForDate(memberId, date)
        .where((log) => log.status == 'completed')
        .length;
  }

  Future<void> markMealSkipped(
    String memberId,
    String dietPlanId,
    String mealType,
    DateTime date,
  ) async {
    final log = MealLogModel(
      id: '${memberId}_${date.toIso8601String().split('T')[0]}_$mealType',
      memberId: memberId,
      dietPlanId: dietPlanId,
      mealType: mealType,
      date: date,
      status: 'skipped',
      loggedAt: DateTime.now(),
    );
    await _repo.addOrUpdate(log);
    notifyListeners();
  }
}