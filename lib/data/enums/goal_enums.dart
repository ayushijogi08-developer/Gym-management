/// String constants for Goal field values.
///
/// These are stored as raw strings in Hive and MongoDB (rather than Dart
/// enums) so existing records keep round-tripping. The constants give
/// callers a single source of truth and prevent typos.
library;

/// The metric family that drives an automatic goal.
///
/// Each kind maps to a specific data source (body-progress entry,
/// workout log, attendance record, meal log) and a unit convention.
/// The calculation engine uses `metricKind` to pick the right
/// strategy. The user-facing `GoalType` (weightLoss / muscleGain / …
/// / other) stays separate — it's the classification shown on the
/// goal card, while `metricKind` is what the engine computes.
class GoalMetricKind {
  GoalMetricKind._();

  static const String weightLoss = 'weight_loss';
  static const String weightGain = 'weight_gain';
  static const String muscleGain = 'muscle_gain';
  static const String bodyFatLoss = 'body_fat_loss';
  static const String bodyFatGain = 'body_fat_gain';

  /// Body-measurement goal (waist, chest, arm, etc.). The specific
  /// field is chosen by the `unit` — see [GoalUnit.measurementField].
  static const String measurement = 'measurement';

  /// Total completed workout sessions since `goal.startDate`.
  static const String workoutCount = 'workout_count';

  /// Current consecutive workout-day streak (today-based).
  static const String workoutStreak = 'workout_streak';

  /// Total attendance check-ins since `goal.startDate`.
  static const String attendance = 'attendance';

  /// Sum of water-litres entries since `goal.startDate`.
  static const String waterLogs = 'water_logs';

  /// Total completed meal-log entries since `goal.startDate`.
  static const String dietLogs = 'diet_logs';

  static const List<String> all = [
    weightLoss,
    weightGain,
    muscleGain,
    bodyFatLoss,
    bodyFatGain,
    measurement,
    workoutCount,
    workoutStreak,
    attendance,
    waterLogs,
    dietLogs,
  ];

  /// Human-readable label for the metric family. Used by the goal
  /// creation form so the dropdown can stay readable.
  static String label(String value) {
    switch (value) {
      case weightLoss:
        return 'Weight Loss';
      case weightGain:
        return 'Weight Gain';
      case muscleGain:
        return 'Muscle Gain';
      case bodyFatLoss:
        return 'Body Fat Reduction';
      case bodyFatGain:
        return 'Body Fat Increase';
      case measurement:
        return 'Body Measurement';
      case workoutCount:
        return 'Workout Sessions';
      case workoutStreak:
        return 'Workout Streak';
      case attendance:
        return 'Gym Attendance';
      case waterLogs:
        return 'Water Intake';
      case dietLogs:
        return 'Diet Log';
      default:
        return value;
    }
  }
}

/// The kind of goal the member is working toward. Free-form for the
/// "other" case; otherwise one of the canonical training categories.
class GoalType {
  GoalType._();

  static const String weightLoss = 'weight_loss';
  static const String muscleGain = 'muscle_gain';
  static const String strength = 'strength';
  static const String endurance = 'endurance';
  static const String other = 'other';

  static const List<String> all = [
    weightLoss,
    muscleGain,
    strength,
    endurance,
    other,
  ];

  static String label(String value) {
    switch (value) {
      case weightLoss:
        return 'Weight Loss';
      case muscleGain:
        return 'Muscle Gain';
      case strength:
        return 'Strength';
      case endurance:
        return 'Endurance';
      case other:
        return 'Other';
      default:
        return value;
    }
  }
}

/// The lifecycle status of a goal. `active` is the implicit default for
/// legacy records that don't carry a status.
class GoalStatus {
  GoalStatus._();

  static const String active = 'active';
  static const String completed = 'completed';
  static const String paused = 'paused';
  static const String cancelled = 'cancelled';
  static const String expired = 'expired';

  /// Legacy status value used by pre-refactor records. We accept it on
  /// read but treat it as `paused` for filtering.
  static const String archived = 'archived';

  static const List<String> all = [
    active,
    completed,
    paused,
    cancelled,
    expired,
  ];

  /// Returns true if a goal in this status counts as "still in progress"
  /// for the purposes of listing, dashboard tiles, and auto-tracking.
  static bool isOpen(String status) =>
      status == active || status == archived;
}

/// Whether the goal's `currentValue` is driven by the user manually
/// updating it, or by an automatic pipeline that reads from body
/// progress entries.
class GoalTrackingMode {
  GoalTrackingMode._();

  static const String manual = 'manual';
  static const String automatic = 'automatic';

  /// Legacy compat — the original (kg/lbs + %) check. Used by the
  /// add/edit screen and the old call sites that only know about
  /// body-progress metrics. New code should prefer
  /// [isAutomaticForMetricKind] which understands all 10 metric
  /// families.
  static bool isAutomaticMetric(String unit, String goalType) {
    switch (unit) {
      case 'kg':
      case 'lbs':
        // Both weight-loss and muscle-gain goals that use kg/lbs can
        // auto-track. weight_loss -> weightKg, muscle_gain -> muscleMassKg.
        return goalType == GoalType.weightLoss ||
            goalType == GoalType.muscleGain;
      case '%':
        // Body-fat percentage.
        return goalType == GoalType.weightLoss;
      default:
        return false;
    }
  }

  /// True for metric kinds that have a working automatic source.
  /// Every kind in [GoalMetricKind.all] is supported, so this is
  /// effectively a guard against an unknown future value.
  static bool isAutomaticForMetricKind(String metricKind) {
    return GoalMetricKind.all.contains(metricKind);
  }

  /// True when the goal's unit is appropriate for the supplied metric
  /// kind. Used by the add/edit form to gate the Automatic toggle.
  static bool unitMatchesMetricKind(String unit, String metricKind) {
    switch (metricKind) {
      case GoalMetricKind.weightLoss:
      case GoalMetricKind.weightGain:
        return unit == GoalUnit.kg || unit == GoalUnit.lbs;
      case GoalMetricKind.muscleGain:
        return unit == GoalUnit.kg || unit == GoalUnit.lbs;
      case GoalMetricKind.bodyFatLoss:
      case GoalMetricKind.bodyFatGain:
        return unit == GoalUnit.percent;
      case GoalMetricKind.measurement:
        return GoalUnit.isMeasurement(unit);
      case GoalMetricKind.workoutCount:
        return unit == GoalUnit.sessions;
      case GoalMetricKind.workoutStreak:
        return unit == GoalUnit.days;
      case GoalMetricKind.attendance:
        return unit == GoalUnit.visits;
      case GoalMetricKind.waterLogs:
        return unit == GoalUnit.litres;
      case GoalMetricKind.dietLogs:
        return unit == GoalUnit.meals;
      default:
        return false;
    }
  }

  /// The default unit for a metric kind — used to auto-narrow the
  /// unit dropdown when the user picks a new metric.
  static String defaultUnitForMetricKind(String metricKind) {
    switch (metricKind) {
      case GoalMetricKind.weightLoss:
      case GoalMetricKind.weightGain:
      case GoalMetricKind.muscleGain:
        return GoalUnit.kg;
      case GoalMetricKind.bodyFatLoss:
      case GoalMetricKind.bodyFatGain:
        return GoalUnit.percent;
      case GoalMetricKind.measurement:
        return GoalUnit.waistCm;
      case GoalMetricKind.workoutCount:
        return GoalUnit.sessions;
      case GoalMetricKind.workoutStreak:
        return GoalUnit.days;
      case GoalMetricKind.attendance:
        return GoalUnit.visits;
      case GoalMetricKind.waterLogs:
        return GoalUnit.litres;
      case GoalMetricKind.dietLogs:
        return GoalUnit.meals;
      default:
        return GoalUnit.other;
    }
  }

  /// Units valid for the supplied metric kind. The Unit dropdown
  /// in the form shows only this list.
  static List<String> unitsForMetricKind(String metricKind) {
    switch (metricKind) {
      case GoalMetricKind.weightLoss:
      case GoalMetricKind.weightGain:
      case GoalMetricKind.muscleGain:
        return const [GoalUnit.kg, GoalUnit.lbs];
      case GoalMetricKind.bodyFatLoss:
      case GoalMetricKind.bodyFatGain:
        return const [GoalUnit.percent];
      case GoalMetricKind.measurement:
        return const [
          GoalUnit.waistCm,
          GoalUnit.chestCm,
          GoalUnit.armCm,
          GoalUnit.hipCm,
          GoalUnit.shoulderCm,
          GoalUnit.thighCm,
          GoalUnit.calfCm,
          GoalUnit.neckCm,
        ];
      case GoalMetricKind.workoutCount:
        return const [GoalUnit.sessions];
      case GoalMetricKind.workoutStreak:
        return const [GoalUnit.days];
      case GoalMetricKind.attendance:
        return const [GoalUnit.visits];
      case GoalMetricKind.waterLogs:
        return const [GoalUnit.litres];
      case GoalMetricKind.dietLogs:
        return const [GoalUnit.meals];
      default:
        return const [GoalUnit.other];
    }
  }
}

/// Units of measurement. Free-form for the "other" case.
class GoalUnit {
  GoalUnit._();

  static const String kg = 'kg';
  static const String lbs = 'lbs';
  static const String reps = 'reps';
  static const String minutes = 'minutes';
  static const String km = 'km';
  static const String percent = '%';
  static const String other = 'other';

  // Body-measurement units. Each tag maps to a single field on
  // [BodyProgressModel] via [measurementField] below.
  static const String waistCm = 'cm_waist';
  static const String chestCm = 'cm_chest';
  static const String armCm = 'cm_arm';
  static const String hipCm = 'cm_hip';
  static const String shoulderCm = 'cm_shoulder';
  static const String thighCm = 'cm_thigh';
  static const String calfCm = 'cm_calf';
  static const String neckCm = 'cm_neck';

  // Count / streak / volume units — no body-progress field, just
  // human-readable labels for the goal card.
  static const String sessions = 'sessions';
  static const String days = 'days';
  static const String visits = 'visits';
  static const String meals = 'meals';
  static const String litres = 'litres';

  static const List<String> all = [
    kg,
    lbs,
    reps,
    minutes,
    km,
    percent,
    other,
    waistCm,
    chestCm,
    armCm,
    hipCm,
    shoulderCm,
    thighCm,
    calfCm,
    neckCm,
    sessions,
    days,
    visits,
    meals,
    litres,
  ];

  static String label(String value) {
    switch (value) {
      case kg:
        return 'kg';
      case lbs:
        return 'lbs';
      case reps:
        return 'reps';
      case minutes:
        return 'minutes';
      case km:
        return 'km';
      case percent:
        return '%';
      case other:
        return 'other';
      case waistCm:
        return 'cm (waist)';
      case chestCm:
        return 'cm (chest)';
      case armCm:
        return 'cm (arm)';
      case hipCm:
        return 'cm (hip)';
      case shoulderCm:
        return 'cm (shoulder)';
      case thighCm:
        return 'cm (thigh)';
      case calfCm:
        return 'cm (calf)';
      case neckCm:
        return 'cm (neck)';
      case sessions:
        return 'sessions';
      case days:
        return 'days';
      case visits:
        return 'visits';
      case meals:
        return 'meals';
      case litres:
        return 'litres';
      default:
        return value;
    }
  }

  /// Maps a measurement unit to the [BodyProgressModel] field name
  /// that carries the value. Returns null for non-measurement units.
  static const Map<String, String> _measurementFieldMap = {
    waistCm: 'waistCm',
    chestCm: 'chestCm',
    armCm: 'armCm',
    hipCm: 'hipCm',
    shoulderCm: 'shoulderCm',
    thighCm: 'thighCm',
    calfCm: 'calfCm',
    neckCm: 'neckCm',
  };

  static String? measurementField(String unit) => _measurementFieldMap[unit];

  /// True for measurement units (`cm_*`).
  static bool isMeasurement(String unit) =>
      _measurementFieldMap.containsKey(unit);
}

/// Priority bucket for the goal. Free-form string for Hive compatibility.
class GoalPriority {
  GoalPriority._();

  static const String high = 'High';
  static const String medium = 'Medium';
  static const String low = 'Low';

  static const List<String> all = [high, medium, low];
}
