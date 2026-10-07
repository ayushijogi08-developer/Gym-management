import 'package:hive/hive.dart';

part 'body_progress_model.g.dart';

@HiveType(typeId: 14)
class BodyProgressModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String memberId;

  @HiveField(2)
  String? loggedByTrainerId;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  double weightKg;

  @HiveField(5)
  double heightCm;

  @HiveField(6)
  double? bodyFatPercent;

  @HiveField(7)
  double? muscleMassKg;

  @HiveField(8)
  double? chestCm;
  @HiveField(9)
  double? waistCm;
  @HiveField(10)
  double? hipCm;
  @HiveField(11)
  double? shoulderCm;
  @HiveField(12)
  double? armCm;
  @HiveField(13)
  double? thighCm;
  @HiveField(14)
  double? calfCm;
  @HiveField(15)
  double? neckCm;

  @HiveField(16)
  String? frontPhotoPath;
  @HiveField(17)
  String? sidePhotoPath;
  @HiveField(18)
  String? backPhotoPath;

  @HiveField(19)
  String? notes;

  // ─── Additive schema (20..21) ───────────────────────────────────────────

  /// Optional direct link to a goal this entry is associated with (used
  /// for manual-mode goals that the user wants to track against a single
  /// entry). Null for legacy records.
  @HiveField(20)
  String? goalId;

  /// When true, automatic-tracking goals that match this entry's unit
  /// will pick up the value the next time the metric engine runs.
  /// Default false; the form sets it based on a user-controlled checkbox.
  @HiveField(21)
  bool autoApplyToGoals;

  // ─── Additive schema (22) ───────────────────────────────────────────────

  /// Optional hydration entry attached to this body-progress log.
  /// Used by automatic water-intake goals ([GoalMetricKind.waterLogs])
  /// to sum litres consumed since the goal's startDate. Null for
  /// records that don't track hydration.
  @HiveField(22)
  double? waterLitres;

  BodyProgressModel({
    required this.id,
    required this.memberId,
    this.loggedByTrainerId,
    required this.date,
    required this.weightKg,
    required this.heightCm,
    this.bodyFatPercent,
    this.muscleMassKg,
    this.chestCm,
    this.waistCm,
    this.hipCm,
    this.shoulderCm,
    this.armCm,
    this.thighCm,
    this.calfCm,
    this.neckCm,
    this.frontPhotoPath,
    this.sidePhotoPath,
    this.backPhotoPath,
    this.notes,
    this.goalId,
    this.autoApplyToGoals = false,
    this.waterLitres,
  });

  double? get bmi {
    if (heightCm == 0) return null;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'loggedByTrainerId': loggedByTrainerId,
      'date': date.toIso8601String(),
      'weightKg': weightKg,
      'heightCm': heightCm,
      'bodyFatPercent': bodyFatPercent,
      'muscleMassKg': muscleMassKg,
      'chestCm': chestCm,
      'waistCm': waistCm,
      'hipCm': hipCm,
      'shoulderCm': shoulderCm,
      'armCm': armCm,
      'thighCm': thighCm,
      'calfCm': calfCm,
      'neckCm': neckCm,
      'frontPhotoPath': frontPhotoPath,
      'sidePhotoPath': sidePhotoPath,
      'backPhotoPath': backPhotoPath,
      'notes': notes,
      'goalId': goalId,
      'autoApplyToGoals': autoApplyToGoals,
      'waterLitres': waterLitres,
    };
  }

  // --- ADDED: For Restore (Import) ---
  factory BodyProgressModel.fromJson(Map<String, dynamic> json) {
    return BodyProgressModel(
      id: json['_id'] ?? json['id'] ?? '',
      memberId: json['memberId'],
      loggedByTrainerId: json['loggedByTrainerId'],
      date: DateTime.parse(json['date']),
      weightKg: (json['weightKg'] as num).toDouble(),
      heightCm: (json['heightCm'] as num).toDouble(),
      bodyFatPercent: (json['bodyFatPercent'] as num?)?.toDouble(),
      muscleMassKg: (json['muscleMassKg'] as num?)?.toDouble(),
      chestCm: (json['chestCm'] as num?)?.toDouble(),
      waistCm: (json['waistCm'] as num?)?.toDouble(),
      hipCm: (json['hipCm'] as num?)?.toDouble(),
      shoulderCm: (json['shoulderCm'] as num?)?.toDouble(),
      armCm: (json['armCm'] as num?)?.toDouble(),
      thighCm: (json['thighCm'] as num?)?.toDouble(),
      calfCm: (json['calfCm'] as num?)?.toDouble(),
      neckCm: (json['neckCm'] as num?)?.toDouble(),
      frontPhotoPath: json['frontPhotoPath'],
      sidePhotoPath: json['sidePhotoPath'],
      backPhotoPath: json['backPhotoPath'],
      notes: json['notes'],
      goalId: json['goalId'],
      autoApplyToGoals: json['autoApplyToGoals'] ?? false,
      waterLitres: (json['waterLitres'] as num?)?.toDouble(),
    );
  }
}