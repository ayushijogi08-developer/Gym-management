class AchievementDefinition {
  final String key;
  final String title;
  final String description;
  final String iconAsset;

  const AchievementDefinition({
    required this.key,
    required this.title,
    required this.description,
    required this.iconAsset,
  });
}

class AchievementCatalog {
  static const List<AchievementDefinition> all = [
    // Workout Achievements
    AchievementDefinition(
      key: 'first_workout',
      title: 'First Workout',
      description: 'Completed your first workout session',
      iconAsset: '🏋️',
    ),
    AchievementDefinition(
      key: 'streak_7',
      title: 'Week Warrior',
      description: '7-day workout streak',
      iconAsset: '🔥',
    ),
    AchievementDefinition(
      key: 'streak_30',
      title: 'Consistency King',
      description: '30-day workout streak',
      iconAsset: '👑',
    ),
    AchievementDefinition(
      key: 'streak_100',
      title: 'Century Streak',
      description: '100-day workout streak',
      iconAsset: '⭐',
    ),
    
    // Weight Loss Achievements
    AchievementDefinition(
      key: 'lost_5kg',
      title: '5kg Down',
      description: 'Lost 5kg body weight',
      iconAsset: '⚖️',
    ),
    AchievementDefinition(
      key: 'lost_10kg',
      title: '10kg Down',
      description: 'Lost 10kg body weight',
      iconAsset: '🏆',
    ),
    
    // Muscle Gain Achievements
    AchievementDefinition(
      key: 'gained_2kg_muscle',
      title: 'Muscle Gain',
      description: 'Gained 2kg muscle mass',
      iconAsset: '💪',
    ),
    AchievementDefinition(
      key: 'gained_5kg_muscle',
      title: 'Muscle Builder',
      description: 'Gained 5kg muscle mass',
      iconAsset: '💪',
    ),
    
    // Attendance Achievements
    AchievementDefinition(
      key: 'visits_50',
      title: 'Gym Regular',
      description: '50 gym visits',
      iconAsset: '🏟️',
    ),
    AchievementDefinition(
      key: 'visits_100',
      title: 'Century Club',
      description: '100 gym visits',
      iconAsset: '🏆',
    ),
    AchievementDefinition(
      key: '10_day_streak',
      title: '10 Day Streak',
      description: '10 consecutive days of gym visits',
      iconAsset: '🔥',
    ),
    
    // Goal Achievements
    AchievementDefinition(
      key: 'goal_completed',
      title: 'Goal Crusher',
      description: 'Completed a personal goal',
      iconAsset: '🎯',
    ),
  ];

  static AchievementDefinition? getByKey(String key) {
    try {
      return all.firstWhere((a) => a.key == key);
    } catch (e) {
      return null;
    }
  }

  static List<String> getAllKeys() {
    return all.map((a) => a.key).toList();
  }
}