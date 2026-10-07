import 'package:flutter/widgets.dart';
import 'package:gym_management_app/providers/timeline_provider.dart';
import 'package:gym_management_app/services/achievement_checker_service.dart';
import 'package:gym_management_app/services/goal_recalc_hook.dart';
import 'package:provider/provider.dart';
import '../data/models/workout_log_model.dart';
import '../data/repositories/workout_log_repository.dart';

class WorkoutLogProvider extends ChangeNotifier {
  final WorkoutLogRepository _repo = WorkoutLogRepository();

  List<WorkoutLogModel> _allLogs = [];

  List<WorkoutLogModel> get allLogs => _allLogs;

  // Load all logs from local storage
  void loadFromLocal() {
    _allLogs = _repo.getAll();
    notifyListeners();
  }

  // Get logs for a specific date
  List<WorkoutLogModel> getForDate(String memberId, DateTime date) {
    final logs = _repo.getForDate(memberId, date);
    print("📊 getForDate: Found ${logs.length} logs for member $memberId on $date");
    return logs;
  }

  // Get history for a date range with proper date comparison
  List<WorkoutLogModel> getHistoryForRange(String memberId, DateTime start, DateTime end) {
    final allLogs = _repo.getAll();
    print("📊 Total workout logs in local storage: ${allLogs.length}");

    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);

    final filtered = allLogs.where((log) {
      final logDate = DateTime(log.date.year, log.date.month, log.date.day);
      
      return log.memberId == memberId &&
          logDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          logDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    print("📊 getHistoryForRange: Found ${filtered.length} logs for member $memberId");
    return filtered;
  }

  // Get history for Today
  List<WorkoutLogModel> getTodayHistory(String memberId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59, 999);
    
    return getHistoryForRange(memberId, startOfDay, endOfDay);
  }

  // Get history for Yesterday
  List<WorkoutLogModel> getYesterdayHistory(String memberId) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final startOfDay = DateTime(yesterday.year, yesterday.month, yesterday.day);
    final endOfDay = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59, 999);
    
    return getHistoryForRange(memberId, startOfDay, endOfDay);
  }

  // Get history for Last Week
  List<WorkoutLogModel> getLastWeekHistory(String memberId) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 7));
    final startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
    final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);
    
    return getHistoryForRange(memberId, startOfDay, endOfDay);
  }

  // Get history for Last Month
  List<WorkoutLogModel> getLastMonthHistory(String memberId) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    final startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
    final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);
    
    return getHistoryForRange(memberId, startOfDay, endOfDay);
  }

  // Refresh logs for a member from API
  Future<void> refreshForMember(String memberId) async {
    print("🔄 refreshForMember called for $memberId");
    try {
      await _repo.fetchLogsForMember(memberId);
      _allLogs = _repo.getAll();
      notifyListeners();
      print("✅ refreshForMember completed, ${_allLogs.length} logs loaded");
    } catch (e) {
      print("❌ Error in refreshForMember: $e");
    }
  }

  // Get previous entry for an exercise
  WorkoutLogModel? getPreviousEntryForExercise(
      String memberId, String exerciseName, DateTime beforeDate) {
    final previous = _repo.getAll().where((log) =>
        log.memberId == memberId &&
        log.exerciseName == exerciseName &&
        log.date.isBefore(beforeDate)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return previous.isNotEmpty ? previous.first : null;
  }

  // Get completed count for today
  int getCompletedCountForToday(String memberId, String workoutPlanId) {
    final today = DateTime.now();
    final logs = _repo.getForDate(memberId, today)
        .where((log) => log.workoutPlanId == workoutPlanId && log.status == 'completed')
        .toList();
    return logs.length;
  }

  // ADD THIS METHOD: Calculate current streak
  int currentStreak(String memberId) {
    final logs = _repo.getAll()
        .where((log) => log.memberId == memberId && log.status == 'completed')
        .toList();

    if (logs.isEmpty) return 0;

    // Extract unique dates and sort them descending
    final workoutDates = logs.map((l) => DateTime(l.date.year, l.date.month, l.date.day)).toSet().toList();
    workoutDates.sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime checkDate = today;

    // Check if the user worked out today or yesterday
    if (workoutDates.contains(today) || workoutDates.contains(today.subtract(const Duration(days: 1)))) {
      checkDate = workoutDates.contains(today) ? today : today.subtract(const Duration(days: 1));
      
      while (workoutDates.contains(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    }

    return streak;
  }

  // Mark exercise as completed with achievement check
 Future<void> markExerciseCompleted(
  String memberId,
  String workoutPlanId,
  String exerciseName,
  DateTime date,
  BuildContext context, {
  int? actualSets,
  double? weightUsed,
  int? reps,
}) async {
  final log = WorkoutLogModel(
    id: '${memberId}_${date.toIso8601String().split('T')[0]}_$exerciseName',
    memberId: memberId,
    workoutPlanId: workoutPlanId,
    exerciseName: exerciseName,
    date: date,
    status: 'completed',
    actualSetsCompleted: actualSets ?? 3,
    weightUsedKg: weightUsed,
    reps: reps ?? 12,
    loggedAt: DateTime.now(),
  );

  await _repo.addOrUpdate(log);
  await _repo.markCompletedOnServer(log);

  // ✅ ONLY CALL THIS ONCE
  await AchievementCheckerService.checkAfterWorkoutLog(context, memberId);

  // ✅ ONLY CALL THIS ONCE
  context.read<TimelineProvider>().logEvent(
    memberId: memberId,
    eventType: 'workout_completed',
    title: 'Workout Completed',
    subtitle: exerciseName,
    iconAsset: 'assets/icons/workout.png',
  );

  _allLogs = _repo.getAll();
  notifyListeners();

  // AUTOMATIC GOAL UPDATES
  // Fan out to workout-count / workout-streak goals via the
  // centralized post-save hook. The hook handles context
  // building, goal iteration, and milestone emission.
  await GoalRecalcHook.instance.onMetricSourceSaved(
    memberId: memberId,
    source: MetricSource.workout,
    context: context,
  );
}
}