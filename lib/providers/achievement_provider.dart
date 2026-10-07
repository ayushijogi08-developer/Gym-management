import 'package:flutter/widgets.dart';
import 'package:gym_management_app/providers/timeline_provider.dart';
import 'package:provider/provider.dart';
import '../data/models/achievement_model.dart';
import '../data/repositories/achievement_repository.dart';
import '../utils/achievement_catalog.dart';

class AchievementProvider extends ChangeNotifier {
  final AchievementRepository _repo = AchievementRepository();
  List<AchievementModel> _achievements = [];

  List<AchievementModel> get achievements => _achievements;

  // Load from local
  void loadFromLocal() {
    _achievements = _repo.box.values.toList();
    notifyListeners();
  }

  // Get by member
  List<AchievementModel> getByMember(String memberId) {
    return _achievements.where((a) => a.memberId == memberId).toList();
  }

  // Get unseen count
  int unseenCount(String memberId) {
    return getByMember(memberId).where((a) => !a.isSeen).length;
  }

  // Fetch from API
  Future<void> fetchForMember(String memberId) async {
    try {
      final achievements = await _repo.fetchByMember(memberId);
      _achievements = achievements;
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching achievements: $e');
      _achievements = _repo.getByMemberLocal(memberId);
      notifyListeners();
    }
  }

  // Award achievement
  Future<void> awardAchievement({
    required BuildContext context,
    required String memberId,
    required String key,
    String? relatedGoalId,
  }) async {
    // Check if already earned locally
    final alreadyEarned = _achievements.any(
      (a) => a.memberId == memberId && a.achievementKey == key
    );
    
    if (alreadyEarned) return;

    final def = AchievementCatalog.getByKey(key);
    if (def == null) {
      print('❌ Achievement definition not found: $key');
      return;
    }

    try {
      final achievement = await _repo.awardAchievement(
        memberId: memberId,
        key: key,
        relatedGoalId: relatedGoalId,
      );

      if (achievement != null) {
        _achievements.insert(0, achievement);
        notifyListeners();

        // Log to timeline
        context.read<TimelineProvider>().logEvent(
          memberId: memberId,
          eventType: 'achievement',
          title: def.title,
          subtitle: def.description,
          iconAsset: def.iconAsset,
        );

        print('🏆 Achievement awarded: ${def.title}');
      }
    } catch (e) {
      print('❌ Error awarding achievement: $e');
    }
  }

  // Mark as seen
  Future<void> markSeen(String id) async {
    try {
      await _repo.markSeen(id);
      
      final index = _achievements.indexWhere((a) => a.id == id);
      if (index != -1) {
        _achievements[index].isSeen = true;
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error marking achievement as seen: $e');
    }
  }

  // Mark all as seen
  Future<void> markAllSeen(String memberId) async {
    final unseen = getByMember(memberId).where((a) => !a.isSeen).toList();
    for (var achievement in unseen) {
      await markSeen(achievement.id);
    }
  }
}