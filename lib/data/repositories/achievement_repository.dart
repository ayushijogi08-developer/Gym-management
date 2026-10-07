import 'package:gym_management_app/data/local/hive_boxes.dart';
import 'package:gym_management_app/data/network/api_client.dart';
import 'package:gym_management_app/data/network/api_endpoints.dart';
import '../models/achievement_model.dart';
import 'base_repository.dart';

class AchievementRepository extends BaseRepository<AchievementModel> {
  AchievementRepository() : super(HiveBoxes.achievements, ApiEndpoints.achievements);

  // Get all achievements for a member from local
  List<AchievementModel> getByMemberLocal(String memberId) {
    return box.values.where((a) => a.memberId == memberId).toList();
  }

  // Check if member has earned a specific achievement
  Future<bool> hasEarned(String memberId, String key) async {
    try {
      // First check local
      final localExists = box.values.any((a) => 
        a.memberId == memberId && a.achievementKey == key);
      
      if (localExists) return true;

      // Check from API
      final response = await ApiClient.get('$endpoint/member/$memberId');
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.any((json) => json['achievementKey'] == key);
      }
      return false;
    } catch (e) {
      print('❌ Error checking achievement: $e');
      return false;
    }
  }

  // Fetch achievements from API
  Future<List<AchievementModel>> fetchByMember(String memberId) async {
    try {
      final response = await ApiClient.get('$endpoint/member/$memberId');
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        final achievements = data.map((json) => AchievementModel.fromJson(json)).toList();
        
        // Save to local
        for (var achievement in achievements) {
          await box.put(achievement.id, achievement);
        }
        
        return achievements;
      }
      return [];
    } catch (e) {
      print('❌ Error fetching achievements: $e');
      return getByMemberLocal(memberId);
    }
  }

  // Award achievement via API
  Future<AchievementModel?> awardAchievement({
    required String memberId,
    required String key,
    String? relatedGoalId,
  }) async {
    try {
      final response = await ApiClient.post(
        '$endpoint/award',
        data: {
          'memberId': memberId,
          'achievementKey': key,
          'relatedGoalId': relatedGoalId,
        },
      );

      if (response.data['success'] == true) {
        final achievement = AchievementModel.fromJson(response.data['data']);
        await box.put(achievement.id, achievement);
        return achievement;
      }
      return null;
    } catch (e) {
      print('❌ Error awarding achievement: $e');
      return null;
    }
  }

  // Mark achievement as seen
  Future<void> markSeen(String achievementId) async {
    try {
      // Look up the local achievement so we can pass its real memberId
      final achievement = box.get(achievementId);
      if (achievement == null) {
        print('⚠️ Achievement $achievementId not found locally; skipping mark-seen');
        return;
      }

      // Update on server
      await ApiClient.post(
        '$endpoint/member/${achievement.memberId}/mark-seen',
        data: {'achievementId': achievementId},
      );

      // Update locally
      achievement.isSeen = true;
      await achievement.save();
    } catch (e) {
      print('❌ Error marking achievement as seen: $e');
    }
  }
}