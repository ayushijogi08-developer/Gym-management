import 'package:hive/hive.dart';

part 'goal_milestone_model.g.dart';

/// A milestone on a goal at a fixed percentage (25/50/75/100 by default).
///
/// Milestones are stored as a sub-list on the owning [GoalModel] so they
/// travel with the record across Hive and MongoDB sync. A milestone is
/// `achievedAt` once the goal's progressPercentage passes its threshold,
/// and `celebrated` once the user has seen the celebration UI for it.
@HiveType(typeId: 23)
class GoalMilestoneModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String goalId;

  @HiveField(2)
  double threshold; // 25.0 / 50.0 / 75.0 / 100.0

  @HiveField(3)
  String label; // e.g. "Quarter way!", "Halfway there!", "Almost done!", "Goal achieved!"

  @HiveField(4)
  DateTime? achievedAt;

  @HiveField(5)
  bool celebrated;

  GoalMilestoneModel({
    required this.id,
    required this.goalId,
    required this.threshold,
    required this.label,
    this.achievedAt,
    this.celebrated = false,
  });

  /// True once the threshold has been crossed.
  bool get isAchieved => achievedAt != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'threshold': threshold,
      'label': label,
      'achievedAt': achievedAt?.toIso8601String(),
      'celebrated': celebrated,
    };
  }

  factory GoalMilestoneModel.fromJson(Map<String, dynamic> json) {
    return GoalMilestoneModel(
      id: json['id']?.toString() ?? '',
      goalId: json['goalId']?.toString() ?? '',
      threshold: (json['threshold'] as num?)?.toDouble() ?? 0.0,
      label: json['label']?.toString() ?? '',
      achievedAt: json['achievedAt'] != null
          ? DateTime.tryParse(json['achievedAt'].toString())
          : null,
      celebrated: json['celebrated'] ?? false,
    );
  }

  /// Default four-step milestone set used by automatic goals.
  static List<GoalMilestoneModel> defaultsFor(String goalId) {
    return [
      GoalMilestoneModel(
        id: '${goalId}_m25',
        goalId: goalId,
        threshold: 25.0,
        label: 'Quarter way!',
      ),
      GoalMilestoneModel(
        id: '${goalId}_m50',
        goalId: goalId,
        threshold: 50.0,
        label: 'Halfway there!',
      ),
      GoalMilestoneModel(
        id: '${goalId}_m75',
        goalId: goalId,
        threshold: 75.0,
        label: 'Almost done!',
      ),
      GoalMilestoneModel(
        id: '${goalId}_m100',
        goalId: goalId,
        threshold: 100.0,
        label: 'Goal achieved!',
      ),
    ];
  }
}
