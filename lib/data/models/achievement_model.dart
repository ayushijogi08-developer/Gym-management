import 'package:hive/hive.dart';

part 'achievement_model.g.dart';

@HiveType(typeId: 16)
class AchievementModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String memberId;

  @HiveField(2)
  String achievementKey;

  @HiveField(3)
  String title;

  @HiveField(4)
  String description;

  @HiveField(5)
  String iconAsset;

  @HiveField(6)
  DateTime earnedDate;

  @HiveField(7)
  String? relatedGoalId;

  @HiveField(8)
  bool isSeen;

  AchievementModel({
    required this.id,
    required this.memberId,
    required this.achievementKey,
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.earnedDate,
    this.relatedGoalId,
    this.isSeen = false,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'achievementKey': achievementKey,
      'title': title,
      'description': description,
      'iconAsset': iconAsset,
      'earnedDate': earnedDate.toIso8601String(),
      'relatedGoalId': relatedGoalId,
      'isSeen': isSeen,
    };
  }

  // --- ADDED: For Restore (Import) ---
  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'],
      memberId: json['memberId'],
      achievementKey: json['achievementKey'],
      title: json['title'],
      description: json['description'],
      iconAsset: json['iconAsset'],
      earnedDate: DateTime.parse(json['earnedDate']),
      relatedGoalId: json['relatedGoalId'],
      isSeen: json['isSeen'] ?? false,
    );
  }
}