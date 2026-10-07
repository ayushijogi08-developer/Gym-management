import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/data/enums/goal_enums.dart';
import 'package:gym_management_app/data/models/attendance_model.dart';
import 'package:gym_management_app/data/models/body_progress_model.dart';
import 'package:gym_management_app/data/models/goal_model.dart';
import 'package:gym_management_app/data/models/meal_log_model.dart';
import 'package:gym_management_app/data/models/workout_log_model.dart';
import 'package:gym_management_app/domain/services/goal_metric_context.dart';
import 'package:gym_management_app/domain/services/goal_metric_service.dart';

GoalModel _makeGoal({
  String id = 'g1',
  String memberId = 'm1',
  String metricKind = '',
  String unit = GoalUnit.kg,
  String goalType = GoalType.weightLoss,
  double startingValue = 0.0,
  double targetValue = 0.0,
  double currentValue = 0.0,
  double progressPercentage = 0.0,
  String status = GoalStatus.active,
  DateTime? startDate,
  String trackingMode = GoalTrackingMode.automatic,
}) {
  return GoalModel(
    id: id,
    memberId: memberId,
    goalType: goalType,
    goalTitle: 'Test Goal',
    targetValue: targetValue,
    currentValue: currentValue,
    unit: unit,
    startDate: startDate ?? DateTime.now().subtract(const Duration(days: 30)),
    trackingMode: trackingMode,
    startingValue: startingValue,
    progressPercentage: progressPercentage,
    status: status,
    metricKind: metricKind,
  );
}

BodyProgressModel _entry({
  required DateTime date,
  double weightKg = 0.0,
  double? bodyFatPercent,
  double? muscleMassKg,
  double? waistCm,
  double? chestCm,
  double? waterLitres,
}) {
  return BodyProgressModel(
    id: 'bp-${date.toIso8601String()}',
    memberId: 'm1',
    date: date,
    weightKg: weightKg,
    heightCm: 175,
    bodyFatPercent: bodyFatPercent,
    muscleMassKg: muscleMassKg,
    waistCm: waistCm,
    chestCm: chestCm,
    waterLitres: waterLitres,
  );
}

WorkoutLogModel _workout({
  required DateTime date,
  String status = 'completed',
  String memberId = 'm1',
}) {
  return WorkoutLogModel(
    id: 'w-${date.toIso8601String()}',
    memberId: memberId,
    workoutPlanId: 'p1',
    exerciseName: 'Squat',
    date: date,
    status: status,
  );
}

AttendanceModel _attendance(DateTime date, {String memberId = 'm1'}) {
  return AttendanceModel(
    id: 'a-${date.toIso8601String()}',
    memberId: memberId,
    memberName: 'Member 1',
    timestamp: date,
  );
}

MealLogModel _meal({
  required DateTime date,
  String status = 'completed',
  String memberId = 'm1',
}) {
  return MealLogModel(
    id: 'meal-${date.toIso8601String()}',
    memberId: memberId,
    dietPlanId: 'd1',
    mealType: 'breakfast',
    date: date,
    status: status,
  );
}

void main() {
  group('clampedProgress', () {
    test('weight loss: 80→70 at 75 = 50%', () {
      final goal = _makeGoal(
        metricKind: GoalMetricKind.weightLoss,
        unit: GoalUnit.kg,
        startingValue: 80.0,
        targetValue: 70.0,
        currentValue: 80.0,
      );
      // Initial state: at startingValue, no movement yet → 0%.
      expect(GoalMetricService.clampedProgress(goal), 0.0);

      GoalMetricService.applyManual(goal, 75.0);
      expect(goal.progressPercentage, 50.0);
    });

    test('weight gain: 60→70 at 65 = 50%', () {
      final goal = _makeGoal(
        metricKind: GoalMetricKind.weightGain,
        unit: GoalUnit.kg,
        startingValue: 60.0,
        targetValue: 70.0,
      );
      GoalMetricService.applyManual(goal, 65.0);
      expect(goal.progressPercentage, 50.0);
    });

    test('body fat loss: 25→15 at 20 = 50%', () {
      final goal = _makeGoal(
        metricKind: GoalMetricKind.bodyFatLoss,
        unit: GoalUnit.percent,
        goalType: GoalType.weightLoss,
        startingValue: 25.0,
        targetValue: 15.0,
      );
      GoalMetricService.applyManual(goal, 20.0);
      expect(goal.progressPercentage, 50.0);
    });

    test('measurement (waist): 100→90 at 95 = 50%', () {
      final goal = _makeGoal(
        metricKind: GoalMetricKind.measurement,
        unit: GoalUnit.waistCm,
        startingValue: 100.0,
        targetValue: 90.0,
      );
      GoalMetricService.applyManual(goal, 95.0);
      expect(goal.progressPercentage, 50.0);
    });

    test('regression: weight loss back to 78 from 75 = 20%', () {
      final goal = _makeGoal(
        metricKind: GoalMetricKind.weightLoss,
        unit: GoalUnit.kg,
        startingValue: 80.0,
        targetValue: 70.0,
        currentValue: 75.0,
        progressPercentage: 50.0,
      );
      // Regression: currentValue=78 is 2kg off startingValue, total 10kg
      // → 20% (backsliding toward the start, still clamped to [0,100]).
      GoalMetricService.applyManual(goal, 78.0);
      expect(goal.progressPercentage, 20.0);
      expect(goal.status, GoalStatus.active);
    });

    test('overshoot: weight loss to 65 clamps to 100% + completed', () {
      final goal = _makeGoal(
        metricKind: GoalMetricKind.weightLoss,
        unit: GoalUnit.kg,
        startingValue: 80.0,
        targetValue: 70.0,
      );
      GoalMetricService.applyManual(goal, 65.0);
      expect(goal.progressPercentage, 100.0);
      expect(goal.status, GoalStatus.completed);
      expect(goal.completedAt, isNotNull);
    });

    test('reopen: completed goal corrected back to 75', () {
      final goal = _makeGoal(
        metricKind: GoalMetricKind.weightLoss,
        unit: GoalUnit.kg,
        startingValue: 80.0,
        targetValue: 70.0,
        currentValue: 65.0,
        progressPercentage: 100.0,
        status: GoalStatus.completed,
      );
      goal.completedAt = DateTime.now();
      GoalMetricService.applyManual(goal, 75.0);
      expect(goal.progressPercentage, 50.0);
      expect(goal.status, GoalStatus.active);
      expect(goal.completedAt, isNull);
    });
  });

  group('applyAutomatic — body-progress metrics', () {
    test('weight loss from latest body entry', () {
      final startDate = DateTime(2025, 1, 1);
      final goal = _makeGoal(
        metricKind: GoalMetricKind.weightLoss,
        unit: GoalUnit.kg,
        startingValue: 80.0,
        targetValue: 70.0,
        startDate: startDate,
      );
      final history = [
        _entry(date: DateTime(2025, 1, 10), weightKg: 78.0),
        _entry(date: DateTime(2025, 1, 5), weightKg: 80.0),
      ];
      final ctx = GoalMetricContext(
        memberId: 'm1',
        bodyProgressDesc: history,
        workoutLogs: const [],
        attendance: const [],
        mealLogs: const [],
      );
      final changed = GoalMetricService.applyAutomatic(goal, ctx);
      expect(changed, true);
      expect(goal.currentValue, 78.0);
      expect(goal.progressPercentage, 20.0);
    });

    test('muscle gain from muscleMassKg', () {
      final goal = _makeGoal(
        metricKind: GoalMetricKind.muscleGain,
        unit: GoalUnit.kg,
        goalType: GoalType.muscleGain,
        startingValue: 30.0,
        targetValue: 35.0,
      );
      final history = [
        _entry(date: DateTime(2025, 1, 5), muscleMassKg: 32.5),
      ];
      final ctx = GoalMetricContext(
        memberId: 'm1',
        bodyProgressDesc: history,
        workoutLogs: const [],
        attendance: const [],
        mealLogs: const [],
      );
      GoalMetricService.applyAutomatic(goal, ctx);
      expect(goal.currentValue, 32.5);
      expect(goal.progressPercentage, 50.0);
    });

    test('body fat reduction from bodyFatPercent', () {
      final goal = _makeGoal(
        metricKind: GoalMetricKind.bodyFatLoss,
        unit: GoalUnit.percent,
        startingValue: 25.0,
        targetValue: 15.0,
      );
      final history = [
        _entry(date: DateTime(2025, 1, 5), bodyFatPercent: 22.0),
      ];
      final ctx = GoalMetricContext(
        memberId: 'm1',
        bodyProgressDesc: history,
        workoutLogs: const [],
        attendance: const [],
        mealLogs: const [],
      );
      GoalMetricService.applyAutomatic(goal, ctx);
      expect(goal.currentValue, 22.0);
      expect(goal.progressPercentage, 30.0);
    });

    test('measurement (chest) from chestCm', () {
      final goal = _makeGoal(
        metricKind: GoalMetricKind.measurement,
        unit: GoalUnit.chestCm,
        startingValue: 90.0,
        targetValue: 100.0,
      );
      final history = [
        _entry(date: DateTime(2025, 1, 5), weightKg: 70, chestCm: 95.0),
      ];
      final ctx = GoalMetricContext(
        memberId: 'm1',
        bodyProgressDesc: history,
        workoutLogs: const [],
        attendance: const [],
        mealLogs: const [],
      );
      GoalMetricService.applyAutomatic(goal, ctx);
      expect(goal.currentValue, 95.0);
      expect(goal.progressPercentage, 50.0);
    });
  });

  group('applyAutomatic — count/streak metrics', () {
    test('workout count: 5 of 12 since startDate ≈ 41.67%', () {
      final start = DateTime(2025, 1, 1);
      final goal = _makeGoal(
        metricKind: GoalMetricKind.workoutCount,
        unit: GoalUnit.sessions,
        startingValue: 0.0,
        targetValue: 12.0,
        startDate: start,
      );
      final logs = [
        _workout(date: DateTime(2025, 1, 10)),
        _workout(date: DateTime(2025, 1, 11)),
        _workout(date: DateTime(2025, 1, 12)),
        _workout(date: DateTime(2025, 1, 13)),
        _workout(date: DateTime(2025, 1, 14)),
        _workout(date: DateTime(2024, 12, 31)), // before startDate
      ];
      final ctx = GoalMetricContext(
        memberId: 'm1',
        bodyProgressDesc: const [],
        workoutLogs: logs,
        attendance: const [],
        mealLogs: const [],
      );
      GoalMetricService.applyAutomatic(goal, ctx);
      expect(goal.currentValue, 5.0);
      expect((goal.progressPercentage - 41.6667).abs() < 0.01, true);
    });

    test('workout streak: 3 consecutive days = 42.86% of 7-day target', () {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final logs = [
        _workout(date: todayDate),
        _workout(date: todayDate.subtract(const Duration(days: 1))),
        _workout(date: todayDate.subtract(const Duration(days: 2))),
      ];
      final goal = _makeGoal(
        metricKind: GoalMetricKind.workoutStreak,
        unit: GoalUnit.days,
        startingValue: 0.0,
        targetValue: 7.0,
      );
      final ctx = GoalMetricContext(
        memberId: 'm1',
        bodyProgressDesc: const [],
        workoutLogs: logs,
        attendance: const [],
        mealLogs: const [],
      );
      GoalMetricService.applyAutomatic(goal, ctx);
      expect(goal.currentValue, 3.0);
      expect((goal.progressPercentage - 42.857).abs() < 0.01, true);
    });

    test('attendance: 8 of 20 since startDate = 40%', () {
      final start = DateTime(2025, 1, 1);
      final goal = _makeGoal(
        metricKind: GoalMetricKind.attendance,
        unit: GoalUnit.visits,
        startingValue: 0.0,
        targetValue: 20.0,
        startDate: start,
      );
      final attendance = <AttendanceModel>[];
      for (int i = 1; i <= 8; i++) {
        attendance.add(_attendance(DateTime(2025, 1, 1).add(Duration(days: i))));
      }
      final ctx = GoalMetricContext(
        memberId: 'm1',
        bodyProgressDesc: const [],
        workoutLogs: const [],
        attendance: attendance,
        mealLogs: const [],
      );
      GoalMetricService.applyAutomatic(goal, ctx);
      expect(goal.currentValue, 8.0);
      expect(goal.progressPercentage, 40.0);
    });
  });

  group('applyAutomatic — diet + water', () {
    test('diet log: 4 of 10 completed meals = 40%', () {
      final start = DateTime(2025, 1, 1);
      final goal = _makeGoal(
        metricKind: GoalMetricKind.dietLogs,
        unit: GoalUnit.meals,
        startingValue: 0.0,
        targetValue: 10.0,
        startDate: start,
      );
      final meals = [
        _meal(date: DateTime(2025, 1, 5), status: 'completed'),
        _meal(date: DateTime(2025, 1, 6), status: 'completed'),
        _meal(date: DateTime(2025, 1, 7), status: 'skipped'), // excluded
        _meal(date: DateTime(2025, 1, 8), status: 'completed'),
        _meal(date: DateTime(2025, 1, 9), status: 'completed'),
      ];
      final ctx = GoalMetricContext(
        memberId: 'm1',
        bodyProgressDesc: const [],
        workoutLogs: const [],
        attendance: const [],
        mealLogs: meals,
      );
      GoalMetricService.applyAutomatic(goal, ctx);
      expect(goal.currentValue, 4.0);
      expect(goal.progressPercentage, 40.0);
    });

    test('water: 5 litres summed from 3 body-progress entries', () {
      final start = DateTime(2025, 1, 1);
      final goal = _makeGoal(
        metricKind: GoalMetricKind.waterLogs,
        unit: GoalUnit.litres,
        startingValue: 0.0,
        targetValue: 8.0,
        startDate: start,
      );
      final history = [
        _entry(date: DateTime(2025, 1, 5), waterLitres: 2.0),
        _entry(date: DateTime(2025, 1, 6), waterLitres: 1.5),
        _entry(date: DateTime(2025, 1, 7), waterLitres: 1.5),
        _entry(date: DateTime(2024, 12, 31), waterLitres: 3.0), // before
      ];
      final ctx = GoalMetricContext(
        memberId: 'm1',
        bodyProgressDesc: history,
        workoutLogs: const [],
        attendance: const [],
        mealLogs: const [],
      );
      GoalMetricService.applyAutomatic(goal, ctx);
      expect(goal.currentValue, 5.0);
      expect((goal.progressPercentage - 62.5).abs() < 0.01, true);
    });
  });

  group('backward compatibility', () {
    test('legacy weight goal with empty metricKind is inferred', () {
      final goal = _makeGoal(
        metricKind: '',
        unit: GoalUnit.kg,
        goalType: GoalType.weightLoss,
        startingValue: 80.0,
        targetValue: 70.0,
      );
      expect(goal.resolvedMetricKind, GoalMetricKind.weightLoss);
    });

    test('legacy muscle goal with kg + muscleGain inferred', () {
      final goal = _makeGoal(
        metricKind: '',
        unit: GoalUnit.kg,
        goalType: GoalType.muscleGain,
        startingValue: 30.0,
        targetValue: 35.0,
      );
      expect(goal.resolvedMetricKind, GoalMetricKind.muscleGain);
    });

    test('legacy goal with measurement unit is inferred', () {
      final goal = _makeGoal(
        metricKind: '',
        unit: GoalUnit.waistCm,
        goalType: GoalType.weightLoss,
        startingValue: 100.0,
        targetValue: 90.0,
      );
      expect(goal.resolvedMetricKind, GoalMetricKind.measurement);
    });

    test('applyAutomaticLegacy still works with body-progress history', () {
      final goal = _makeGoal(
        metricKind: GoalMetricKind.weightLoss,
        unit: GoalUnit.kg,
        startingValue: 80.0,
        targetValue: 70.0,
      );
      final history = [
        _entry(date: DateTime(2025, 1, 5), weightKg: 75.0),
      ];
      GoalMetricService.applyAutomaticLegacy(goal, history);
      expect(goal.currentValue, 75.0);
      expect(goal.progressPercentage, 50.0);
    });
  });

  group('manual mode guard', () {
    test('manual goal is not touched by applyAutomatic', () {
      final goal = _makeGoal(
        metricKind: GoalMetricKind.weightLoss,
        unit: GoalUnit.kg,
        startingValue: 80.0,
        targetValue: 70.0,
        trackingMode: GoalTrackingMode.manual,
        currentValue: 78.0,
        progressPercentage: 20.0,
      );
      final history = [
        _entry(date: DateTime(2025, 1, 5), weightKg: 72.0),
      ];
      final ctx = GoalMetricContext(
        memberId: 'm1',
        bodyProgressDesc: history,
        workoutLogs: const [],
        attendance: const [],
        mealLogs: const [],
      );
      final changed = GoalMetricService.applyAutomatic(goal, ctx);
      expect(changed, false);
      expect(goal.currentValue, 78.0);
    });
  });

  group('isAutomaticCompatible', () {
    test('returns true when unit matches metric kind', () {
      final goal = _makeGoal(
        metricKind: GoalMetricKind.workoutCount,
        unit: GoalUnit.sessions,
      );
      expect(isAutomaticCompatible(goal), true);
    });

    test('returns false when unit does not match metric kind', () {
      final goal = _makeGoal(
        metricKind: GoalMetricKind.workoutCount,
        unit: GoalUnit.kg,
      );
      expect(isAutomaticCompatible(goal), false);
    });
  });
}