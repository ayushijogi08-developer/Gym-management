import 'package:hive/hive.dart';
import 'package:gym_management_app/data/enums/goal_enums.dart';
import 'package:gym_management_app/data/models/goal_milestone_model.dart';

part 'goal_model.g.dart';

/// A member's goal. Goals can be tracked manually (user types the
/// current value) or automatically (the current value is derived from
/// the latest body-progress entry that matches the goal's metric).
///
/// Field 0..12 are the original schema. Fields 13..18 are additive —
/// older records load fine because Hive only writes fields it knows
/// about and reads default missing indices to their constructor defaults.
@HiveType(typeId: 15)
class GoalModel extends HiveObject {
  // ─── Original schema (do not renumber) ─────────────────────────────────

  @HiveField(0)
  String id;

  @HiveField(1)
  String memberId;

  @HiveField(2)
  String goalType; // weight_loss | muscle_gain | strength | endurance | other

  @HiveField(3)
  String goalTitle;

  @HiveField(4)
  double targetValue;

  @HiveField(5)
  double currentValue;

  @HiveField(6)
  String unit; // kg | lbs | reps | minutes | km | % | other

  @HiveField(7)
  DateTime startDate;

  @HiveField(8)
  DateTime? targetDate;

  @HiveField(9)
  String priority; // High / Medium / Low

  @HiveField(10)
  String status; // active | completed | paused | cancelled | expired | archived

  @HiveField(11)
  String? trainerNotes;

  @HiveField(12)
  String? memberNotes;

  // ─── Additive schema (13..18) ───────────────────────────────────────────

  /// 'manual' (default) or 'automatic'. Automatic goals read their
  /// currentValue from the latest matching BodyProgressModel entry.
  @HiveField(13)
  String trackingMode;

  /// The starting value when the goal was created. For weight-loss goals
  /// this is the member's weight at goal creation time; for muscle-gain
  /// it's the muscle mass; for body-fat goals it's the body-fat %.
  /// Defaults to 0.0 for legacy records.
  @HiveField(14)
  double startingValue;

  /// Cached `targetValue - currentValue` for fast display. Recomputed
  /// every time [progressPercentage] is updated. Not used as the source
  /// of truth — derived values should always prefer the formula.
  @HiveField(15)
  double remainingValue;

  /// Cached progress percentage (0–100). Recomputed when currentValue
  /// changes. Use [progressPercentage] getter as the source of truth;
  /// this field exists only to persist the snapshot across sessions.
  @HiveField(16)
  double progressPercentage;

  /// Timestamp the goal was first marked completed. Null until then.
  @HiveField(17)
  DateTime? completedAt;

  /// Sub-target milestones attached to this goal (25/50/75/100 by
  /// default). Empty list for legacy records.
  @HiveField(18)
  List<GoalMilestoneModel> milestones;

  // ─── Additive schema (19..20) ───────────────────────────────────────────

  /// Unified free-form notes about the goal. Mirrors the `notes` field on
  /// the MongoDB schema. Older records only carry [trainerNotes] /
  /// [memberNotes]; new records should populate [notes] directly. The
  /// [notes] getter below resolves in priority order (notes → trainerNotes
  /// → memberNotes) so callers can rely on a single accessor.
  @HiveField(19)
  String? notes;

  /// The metric family that drives automatic progress. Defaults to
  /// empty string for legacy records; [resolvedMetricKind] infers a
  /// sensible value from [goalType] + [unit] when this is empty so
  /// older goals still work with the new engine.
  @HiveField(20)
  String metricKind;

  GoalModel({
    required this.id,
    required this.memberId,
    required this.goalType,
    required this.goalTitle,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
    required this.startDate,
    this.targetDate,
    this.priority = GoalPriority.medium,
    this.status = GoalStatus.active,
    this.trainerNotes,
    this.memberNotes,
    this.trackingMode = GoalTrackingMode.manual,
    this.startingValue = 0.0,
    this.remainingValue = 0.0,
    this.progressPercentage = 0.0,
    this.completedAt,
    List<GoalMilestoneModel>? milestones,
    this.notes,
    this.metricKind = '',
  }) : milestones = milestones ?? <GoalMilestoneModel>[];

  // ─── Computed values ───────────────────────────────────────────────────

  /// True when the goal's progress has reached 99% or more.
  bool get isCompleted => progressPercentage >= 99.0;

  /// True when the goal is still being worked on (active or the legacy
  /// 'archived' status that the old code treated as still-open).
  bool get isOpen => GoalStatus.isOpen(status);

  /// Direction-aware progress calculation. Handles both increase
  /// (muscle gain, strength) and decrease (weight loss) goals by
  /// checking which side of `startingValue` the `targetValue` lies.
  ///
  /// Returns a value in the inclusive range [0, 100].
  double get progressPercent {
    // No movement possible if target == start.
    if (targetValue == startingValue) {
      return currentValue == startingValue ? 100.0 : 0.0;
    }
    final total = (targetValue - startingValue).abs();
    final moved = (currentValue - startingValue).abs();
    if (total == 0) return 0.0;
    return ((moved / total) * 100).clamp(0.0, 100.0);
  }

  /// Direction-aware remaining value: how much further the user needs
  /// to go to hit the target. Always non-negative.
  double get computedRemainingValue {
    return (targetValue - currentValue).abs();
  }

  /// Unified notes accessor. New records should populate [notes]
  /// directly; for legacy records that only carry the role-split fields,
  /// this returns the trainer note (preferred) or the member note as a
  /// fallback so display surfaces never show null when content exists.
  String? get notesResolved {
    if (notes != null && notes!.isNotEmpty) return notes;
    if (trainerNotes != null && trainerNotes!.isNotEmpty) return trainerNotes;
    if (memberNotes != null && memberNotes!.isNotEmpty) return memberNotes;
    return null;
  }

  /// Convenience for the unit-aware weight/muscle check used by the
  /// automatic tracking pipeline. Now understands all 10 metric
  /// families (see [resolvedMetricKind]); legacy records that don't
  /// have a metricKind set fall back to the unit/goalType heuristic.
  bool get isAutomaticallyTrackable {
    if (trackingMode != GoalTrackingMode.automatic) return false;
    final kind = resolvedMetricKind;
    if (kind.isEmpty) return false;
    return GoalTrackingMode.unitMatchesMetricKind(unit, kind);
  }

  /// Returns the metric kind that drives this goal's automatic
  /// progress. Falls back to inferring from [goalType] + [unit] for
  /// legacy records created before [metricKind] was a stored field.
  /// Returns an empty string when no inference is possible.
  String get resolvedMetricKind {
    if (metricKind.isNotEmpty) return metricKind;
    return _inferMetricKind(goalType, unit);
  }

  /// Heuristic inference used for legacy records. Mirrors the legacy
  /// check inside [GoalTrackingMode.isAutomaticMetric] so old rows
  /// still map to the right calculator.
  static String _inferMetricKind(String goalType, String unit) {
    switch (unit) {
      case 'kg':
      case 'lbs':
        if (goalType == GoalType.muscleGain) return GoalMetricKind.muscleGain;
        return GoalMetricKind.weightLoss; // most common; weightGain
                                          // is a new opt-in.
      case '%':
        return GoalMetricKind.bodyFatLoss;
      default:
        if (GoalUnit.isMeasurement(unit)) return GoalMetricKind.measurement;
        return '';
    }
  }

  // ─── JSON serialization ────────────────────────────────────────────────

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'goalType': goalType,
      'goalTitle': goalTitle,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'unit': unit,
      'startDate': startDate.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'priority': priority,
      'status': status,
      'trainerNotes': trainerNotes,
      'memberNotes': memberNotes,
      'trackingMode': trackingMode,
      'startingValue': startingValue,
      'remainingValue': remainingValue,
      'progressPercentage': progressPercentage,
      'completedAt': completedAt?.toIso8601String(),
      'milestones': milestones.map((m) => m.toJson()).toList(),
      'notes': notes,
      'metricKind': metricKind,
    };
  }

  // --- ADDED: For Restore (Import) ---
  factory GoalModel.fromJson(Map<String, dynamic> json) {
    // Extract the ID safely whether it's a String (from local) or a Map (from API)
    String memberIdString;
    final mId = json['memberId'];
    if (mId is Map) {
      memberIdString = mId['_id'] ?? '';
    } else {
      memberIdString = mId?.toString() ?? '';
    }

    final milestonesRaw = json['milestones'];
    final milestones = <GoalMilestoneModel>[];
    if (milestonesRaw is List) {
      for (final item in milestonesRaw) {
        if (item is Map<String, dynamic>) {
          milestones.add(GoalMilestoneModel.fromJson(item));
        } else if (item is Map) {
          milestones.add(GoalMilestoneModel.fromJson(
              Map<String, dynamic>.from(item)));
        }
      }
    }

    return GoalModel(
      id: json['_id'] ?? json['id'] ?? '',
      memberId: memberIdString,
      goalType: json['goalType'] ?? GoalType.other,
      goalTitle: json['goalTitle'] ?? '',
      targetValue: (json['targetValue'] as num?)?.toDouble() ?? 0.0,
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'])
          : null,
      priority: json['priority'] ?? GoalPriority.medium,
      status: json['status'] ?? GoalStatus.active,
      trainerNotes: json['trainerNotes'],
      memberNotes: json['memberNotes'],
      trackingMode: json['trackingMode'] ?? GoalTrackingMode.manual,
      startingValue: (json['startingValue'] as num?)?.toDouble() ?? 0.0,
      remainingValue: (json['remainingValue'] as num?)?.toDouble() ?? 0.0,
      progressPercentage:
          (json['progressPercentage'] as num?)?.toDouble() ?? 0.0,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
      milestones: milestones,
      notes: json['notes']?.toString(),
      metricKind: json['metricKind']?.toString() ?? '',
    );
  }
}