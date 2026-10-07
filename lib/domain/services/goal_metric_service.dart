import 'package:gym_management_app/data/enums/goal_enums.dart';
import 'package:gym_management_app/data/models/body_progress_model.dart';
import 'package:gym_management_app/data/models/goal_model.dart';
import 'package:gym_management_app/domain/services/goal_metric_context.dart';

/// Pure logic that decides how a goal's source data (body-progress,
/// workout logs, attendance, meal logs) maps onto a goal and how
/// automatic-tracking goals update their progress.
///
/// Lives outside the widget/provider layer so it can be unit-tested
/// without Hive. Mutates [GoalModel] in place but does NOT persist —
/// the caller (typically [GoalProvider]) is responsible for writing
/// back to Hive and the API.
///
/// The 10 supported metric kinds ([GoalMetricKind]) are mapped to
/// strategy classes via [_calculators]. Each strategy computes the
/// raw `currentValue` from the [GoalMetricContext]; the common
/// `_applyValue` helper handles direction math, clamping,
/// regression handling, and status transitions.
class GoalMetricService {
  GoalMetricService._();

  // ─── Strategy table ────────────────────────────────────────────────────

  /// Picks the right calculator for a goal. Falls back to the
  /// legacy weight/muscle/bodyfat path when [GoalModel.metricKind]
  /// is empty (legacy records).
  static MetricCalculator? _calculatorFor(GoalModel goal) {
    final kind = goal.resolvedMetricKind;
    if (kind.isEmpty) return null;
    switch (kind) {
      case GoalMetricKind.weightLoss:
        return _WeightCalculator(useMuscleMass: false);
      case GoalMetricKind.weightGain:
        return _WeightCalculator(useMuscleMass: false);
      case GoalMetricKind.muscleGain:
        return _WeightCalculator(useMuscleMass: true);
      case GoalMetricKind.bodyFatLoss:
      case GoalMetricKind.bodyFatGain:
        return _BodyFatCalculator();
      case GoalMetricKind.measurement:
        return _MeasurementCalculator();
      case GoalMetricKind.workoutCount:
        return _WorkoutCountCalculator();
      case GoalMetricKind.workoutStreak:
        return _WorkoutStreakCalculator();
      case GoalMetricKind.attendance:
        return _AttendanceCalculator();
      case GoalMetricKind.waterLogs:
        return _WaterLogsCalculator();
      case GoalMetricKind.dietLogs:
        return _DietLogsCalculator();
      default:
        return null;
    }
  }

  /// Look up the source-of-truth value for a goal. Returns null
  /// when no source has a usable value (e.g. no body-progress entry
  /// for the metric, or the wrong unit).
  static double? pickLatestValue(
    GoalModel goal,
    GoalMetricContext ctx,
  ) {
    final calc = _calculatorFor(goal);
    return calc?.compute(goal, ctx);
  }

  /// Backward-compat overload for call sites that only have a
  /// body-progress history (the legacy Phase 1 API).
  static double? pickLatestValueLegacy(
    GoalModel goal,
    List<BodyProgressModel> historyDesc,
  ) {
    return pickLatestValue(
      goal,
      GoalMetricContext(
        memberId: goal.memberId,
        bodyProgressDesc: historyDesc,
        workoutLogs: const [],
        attendance: const [],
        mealLogs: const [],
      ),
    );
  }

  /// Runs the goal's automatic calculator and applies the result.
  /// Returns true if anything changed (currentValue, percentage,
  /// status, or completedAt).
  static bool applyAutomatic(GoalModel goal, GoalMetricContext ctx) {
    if (goal.trackingMode != GoalTrackingMode.automatic) return false;
    final calc = _calculatorFor(goal);
    if (calc == null) return false;
    final value = calc.compute(goal, ctx);
    if (value == null) return false;
    return _applyValue(goal, value);
  }

  /// Backward-compat overload for call sites that only know about
  /// the body-progress history.
  static bool applyAutomaticLegacy(
    GoalModel goal,
    List<BodyProgressModel> historyDesc,
  ) {
    return applyAutomatic(
      goal,
      GoalMetricContext(
        memberId: goal.memberId,
        bodyProgressDesc: historyDesc,
        workoutLogs: const [],
        attendance: const [],
        mealLogs: const [],
      ),
    );
  }

  /// Manual update path. Updates currentValue to a user-supplied
  /// number and recomputes derived fields. Used by the manual
  /// update dialog and by tests that drive the engine directly.
  static bool applyManual(GoalModel goal, double value) {
    return _applyValue(goal, value);
  }

  /// Recomputes progress without changing currentValue. Useful when
  /// the user edits goals (target value, starting value) and we
  /// need the percentage/remaining/status to catch up.
  static bool recompute(GoalModel goal) {
    return _applyValue(goal, goal.currentValue);
  }

  // ─── Core apply logic ──────────────────────────────────────────────────

  /// Applies a single numeric value to the goal and recomputes
  /// derived fields. Direction-aware, regression-tolerant, and
  /// handles the active↔completed transition both ways.
  static bool _applyValue(GoalModel goal, double value) {
    final previous = goal.currentValue;
    final previousStatus = goal.status;
    final previousCompletedAt = goal.completedAt;

    goal.currentValue = value;
    goal.progressPercentage = clampedProgress(goal);
    goal.remainingValue = (goal.targetValue - goal.currentValue).abs();

    if (goal.isCompleted && goal.status != GoalStatus.completed) {
      goal.status = GoalStatus.completed;
      goal.completedAt = DateTime.now();
    } else if (!goal.isCompleted && goal.status == GoalStatus.completed) {
      // Reopened (e.g., user corrected a measurement). Clear the
      // completion stamp so the dashboard doesn't show a stale
      // celebration.
      goal.status = GoalStatus.active;
      goal.completedAt = null;
    }

    return previous != goal.currentValue ||
        previousStatus != goal.status ||
        previousCompletedAt != goal.completedAt;
  }

  /// Direction-aware progress percentage clamped to [0, 100]. Used
  /// by both the live engine and the round-trip unit tests.
  ///
  /// - For *increase* goals (startingValue < targetValue) progress
  ///   rises as currentValue moves from start toward target.
  /// - For *decrease* goals (startingValue > targetValue) progress
  ///   rises as currentValue moves from start down toward target.
  /// - If the user overshoots (passes the target) the value clamps
  ///   to 100 so the UI never shows > 100%.
  /// - If the user regresses (moves back toward startingValue) the
  ///   value falls below 100% but stays >= 0%.
  static double clampedProgress(GoalModel goal) {
    final total = (goal.targetValue - goal.startingValue).abs();
    if (total == 0) {
      return goal.currentValue == goal.startingValue ? 100.0 : 0.0;
    }
    final moved = (goal.currentValue - goal.startingValue).abs();
    return ((moved / total) * 100).clamp(0.0, 100.0);
  }

  /// Drops the cached `currentValue` from a goal so the next
  /// automatic run picks up the latest source. Used by callers
  /// that want to force a re-compute without supplying a value.
  static void invalidate(GoalModel goal) {
    goal.currentValue = 0.0;
    goal.progressPercentage = 0.0;
    goal.remainingValue = (goal.targetValue - goal.currentValue).abs();
  }
}

// ─── Strategy contracts ──────────────────────────────────────────────────

/// A metric calculator. Returns the raw currentValue for a goal or
/// null when the source has no usable data.
abstract class MetricCalculator {
  double? compute(GoalModel goal, GoalMetricContext ctx);
}

// ─── Body-progress calculators ───────────────────────────────────────────

/// Reads weightKg or muscleMassKg from the latest body-progress
/// entry. The field is chosen by the goal's `metricKind`:
/// `muscleGain` reads muscleMassKg, everything else reads weightKg.
class _WeightCalculator implements MetricCalculator {
  final bool useMuscleMass;
  _WeightCalculator({required this.useMuscleMass});

  @override
  double? compute(GoalModel goal, GoalMetricContext ctx) {
    if (ctx.bodyProgressDesc.isEmpty) return null;
    for (final entry in ctx.bodyProgressDesc) {
      if (useMuscleMass) {
        final v = entry.muscleMassKg;
        if (v != null) return v;
      } else {
        final v = entry.weightKg;
        if (v != 0) return v; // 0 is a sentinel for "no entry"
      }
    }
    return null;
  }
}

/// Reads bodyFatPercent from the latest body-progress entry.
class _BodyFatCalculator implements MetricCalculator {
  @override
  double? compute(GoalModel goal, GoalMetricContext ctx) {
    if (ctx.bodyProgressDesc.isEmpty) return null;
    for (final entry in ctx.bodyProgressDesc) {
      final v = entry.bodyFatPercent;
      if (v != null) return v;
    }
    return null;
  }
}

/// Reads a measurement field (waist, chest, arm, etc.) from the
/// latest body-progress entry. The field is chosen by the goal's
/// unit via [GoalUnit.measurementField].
class _MeasurementCalculator implements MetricCalculator {
  @override
  double? compute(GoalModel goal, GoalMetricContext ctx) {
    if (ctx.bodyProgressDesc.isEmpty) return null;
    final field = GoalUnit.measurementField(goal.unit);
    if (field == null) return null;
    for (final entry in ctx.bodyProgressDesc) {
      final v = _readField(entry, field);
      if (v != null) return v;
    }
    return null;
  }

  double? _readField(BodyProgressModel entry, String field) {
    switch (field) {
      case 'waistCm':
        return entry.waistCm;
      case 'chestCm':
        return entry.chestCm;
      case 'armCm':
        return entry.armCm;
      case 'hipCm':
        return entry.hipCm;
      case 'shoulderCm':
        return entry.shoulderCm;
      case 'thighCm':
        return entry.thighCm;
      case 'calfCm':
        return entry.calfCm;
      case 'neckCm':
        return entry.neckCm;
      default:
        return null;
    }
  }
}

// ─── Workout-log calculators ─────────────────────────────────────────────

/// Counts completed workout sessions since `goal.startDate`.
class _WorkoutCountCalculator implements MetricCalculator {
  @override
  double? compute(GoalModel goal, GoalMetricContext ctx) {
    if (ctx.workoutLogs.isEmpty) return 0.0;
    final since = goal.startDate;
    final count = ctx.workoutLogs.where((l) =>
        l.memberId == goal.memberId &&
        l.status == 'completed' &&
        !l.date.isBefore(since)).length;
    return count.toDouble();
  }
}

/// Counts the current consecutive-workout-day streak. Independent
/// of `goal.startDate` — a streak is a property of the user's
/// recent activity, not a window from the goal's start.
class _WorkoutStreakCalculator implements MetricCalculator {
  @override
  double? compute(GoalModel goal, GoalMetricContext ctx) {
    if (ctx.workoutLogs.isEmpty) return 0.0;
    final dates = ctx.workoutLogs
        .where((l) => l.memberId == goal.memberId && l.status == 'completed')
        .map((l) => DateTime(l.date.year, l.date.month, l.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    if (dates.isEmpty) return 0.0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    DateTime check = dates.contains(todayDate)
        ? todayDate
        : todayDate.subtract(const Duration(days: 1));

    int streak = 0;
    while (dates.contains(check)) {
      streak++;
      check = check.subtract(const Duration(days: 1));
    }
    return streak.toDouble();
  }
}

// ─── Attendance calculator ───────────────────────────────────────────────

/// Counts attendance check-ins since `goal.startDate`.
class _AttendanceCalculator implements MetricCalculator {
  @override
  double? compute(GoalModel goal, GoalMetricContext ctx) {
    if (ctx.attendance.isEmpty) return 0.0;
    final since = goal.startDate;
    final count = ctx.attendance.where((a) =>
        a.memberId == goal.memberId &&
        !a.timestamp.isBefore(since)).length;
    return count.toDouble();
  }
}

// ─── Diet-log + water-log calculators ────────────────────────────────────

/// Counts completed meal-log entries since `goal.startDate`.
class _DietLogsCalculator implements MetricCalculator {
  @override
  double? compute(GoalModel goal, GoalMetricContext ctx) {
    if (ctx.mealLogs.isEmpty) return 0.0;
    final since = goal.startDate;
    final count = ctx.mealLogs.where((l) =>
        l.memberId == goal.memberId &&
        l.status == 'completed' &&
        !l.date.isBefore(since)).length;
    return count.toDouble();
  }
}

/// Sums waterLitres from body-progress entries since
/// `goal.startDate`. Entries without a water value are skipped.
class _WaterLogsCalculator implements MetricCalculator {
  @override
  double? compute(GoalModel goal, GoalMetricContext ctx) {
    if (ctx.bodyProgressDesc.isEmpty) return 0.0;
    final since = goal.startDate;
    double sum = 0.0;
    bool foundAny = false;
    for (final entry in ctx.bodyProgressDesc) {
      if (entry.date.isBefore(since)) continue;
      final v = entry.waterLitres;
      if (v == null) continue;
      sum += v;
      foundAny = true;
    }
    return foundAny ? sum : 0.0;
  }
}

// ─── Public smoke-test helpers (no DB needed) ────────────────────────────

/// Quick lookup so callers can check whether a goal has a working
/// automatic source without instantiating the strategies directly.
bool isAutomaticCompatible(GoalModel goal) {
  if (goal.unit.isEmpty) return false;
  final kind = goal.resolvedMetricKind;
  if (kind.isEmpty) return false;
  return GoalTrackingMode.unitMatchesMetricKind(goal.unit, kind);
}
