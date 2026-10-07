import 'package:gym_management_app/data/models/attendance_model.dart';
import 'package:gym_management_app/data/models/body_progress_model.dart';
import 'package:gym_management_app/data/models/meal_log_model.dart';
import 'package:gym_management_app/data/models/workout_log_model.dart';
import 'package:gym_management_app/providers/attendance_provider.dart';
import 'package:gym_management_app/providers/body_progress_provider.dart';
import 'package:gym_management_app/providers/meal_log_provider.dart';
import 'package:gym_management_app/providers/workout_log_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// Immutable bundle of every data source the metric engine might need
/// to compute a single goal's progress.
///
/// Built by the providers that own each source (body-progress,
/// workout logs, attendance, meal logs) and passed into
/// [GoalMetricService.applyAutomatic]. Keeping the snapshot in one
/// immutable struct means the engine can compute every metric kind
/// without having to inject provider instances — that keeps the
/// engine pure (Hive-free, provider-free) and trivially unit-testable.
///
/// The lists can be empty. The engine treats an empty source as
/// "no data" and returns null from the calculator, so the goal
/// falls back to its cached currentValue.
class GoalMetricContext {
  final String memberId;

  /// Body-progress entries sorted newest-first. Used by the weight,
  /// muscle, body-fat, measurement, and water calculators.
  final List<BodyProgressModel> bodyProgressDesc;

  /// All workout logs for the member. Used by workout-count and
  /// workout-streak calculators.
  final List<WorkoutLogModel> workoutLogs;

  /// All attendance records for the member. Used by the attendance
  /// calculator.
  final List<AttendanceModel> attendance;

  /// All meal logs for the member. Used by the diet-log calculator.
  final List<MealLogModel> mealLogs;

  const GoalMetricContext({
    required this.memberId,
    required this.bodyProgressDesc,
    required this.workoutLogs,
    required this.attendance,
    required this.mealLogs,
  });

  /// Empty context — useful for callers that only know about a
  /// single source (e.g. legacy UI passing only body-progress history).
  /// The engine will simply return null for any calculator that
  /// requires a missing source, leaving the goal's currentValue
  /// unchanged.
  factory GoalMetricContext.empty(String memberId) => GoalMetricContext(
        memberId: memberId,
        bodyProgressDesc: const [],
        workoutLogs: const [],
        attendance: const [],
        mealLogs: const [],
      );

  /// Builds a context from the four relevant providers. Pass any
  /// [BuildContext] mounted above the provider tree (typically the
  /// dashboard or the form that owns the action).
  ///
  /// Falls back to empty lists when a provider isn't in the tree —
  /// the engine treats that as no-op so the goal doesn't error out
  /// in unusual navigation states.
  factory GoalMetricContext.fromProviders(
    BuildContext context, {
    required String memberId,
  }) {
    List<BodyProgressModel> bodyProgressDesc = const [];
    List<WorkoutLogModel> workoutLogs = const [];
    List<AttendanceModel> attendance = const [];
    List<MealLogModel> mealLogs = const [];

    try {
      bodyProgressDesc =
          context.read<BodyProgressProvider>().getHistory(memberId);
    } catch (_) {}

    try {
      workoutLogs =
          context.read<WorkoutLogProvider>().allLogs
              .where((l) => l.memberId == memberId)
              .toList();
    } catch (_) {}

    try {
      attendance = context
          .read<AttendanceProvider>()
          .allAttendance
          .where((a) => a.memberId == memberId)
          .toList();
    } catch (_) {}

    try {
      mealLogs = context.read<MealLogProvider>().allLogs
          .where((l) => l.memberId == memberId)
          .toList();
    } catch (_) {}

    return GoalMetricContext(
      memberId: memberId,
      bodyProgressDesc: bodyProgressDesc,
      workoutLogs: workoutLogs,
      attendance: attendance,
      mealLogs: mealLogs,
    );
  }
}