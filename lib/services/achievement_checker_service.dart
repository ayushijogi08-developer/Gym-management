import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/workout_log_provider.dart';
import '../providers/attendance_provider.dart';

class AchievementCheckerService {
  // Check after completing a workout
  static Future<void> checkAfterWorkoutLog(BuildContext context, String memberId) async {
    if (memberId.isEmpty) return;
    
    final achievementProvider = context.read<AchievementProvider>();
    final workoutLogProvider = context.read<WorkoutLogProvider>();

    // First workout
    await achievementProvider.awardAchievement(
      context: context,
      memberId: memberId,
      key: 'first_workout',
    );

    // Check streak achievements
    final streak = workoutLogProvider.currentStreak(memberId);
    if (streak >= 7) {
      await achievementProvider.awardAchievement(
        context: context,
        memberId: memberId,
        key: 'streak_7',
      );
    }
    if (streak >= 30) {
      await achievementProvider.awardAchievement(
        context: context,
        memberId: memberId,
        key: 'streak_30',
      );
    }
    if (streak >= 100) {
      await achievementProvider.awardAchievement(
        context: context,
        memberId: memberId,
        key: 'streak_100',
      );
    }
  }

  // Check after body progress update
  static Future<void> checkAfterBodyProgress(
    BuildContext context,
    String memberId,
    double currentWeight,
    double startingWeight,
  ) async {
    if (memberId.isEmpty) return;
    
    final achievementProvider = context.read<AchievementProvider>();
    
    final weightLost = startingWeight - currentWeight;
    final muscleGained = currentWeight - startingWeight;

    // Weight loss achievements
    if (weightLost >= 5) {
      await achievementProvider.awardAchievement(
        context: context,
        memberId: memberId,
        key: 'lost_5kg',
      );
    }
    if (weightLost >= 10) {
      await achievementProvider.awardAchievement(
        context: context,
        memberId: memberId,
        key: 'lost_10kg',
      );
    }

    // Muscle gain achievements (simplified - in reality you'd track muscle %)
    if (muscleGained >= 2) {
      await achievementProvider.awardAchievement(
        context: context,
        memberId: memberId,
        key: 'gained_2kg_muscle',
      );
    }
    if (muscleGained >= 5) {
      await achievementProvider.awardAchievement(
        context: context,
        memberId: memberId,
        key: 'gained_5kg_muscle',
      );
    }
  }

  // Check after attendance
  static Future<void> checkAfterAttendance(BuildContext context, String memberId) async {
    if (memberId.isEmpty) return;
    
    final achievementProvider = context.read<AchievementProvider>();
    final attendanceProvider = context.read<AttendanceProvider>();
    
    final totalVisits = attendanceProvider.totalVisits(memberId);
    final streak = attendanceProvider.currentStreak(memberId);
    
    // Visit count achievements
    if (totalVisits >= 50) {
      await achievementProvider.awardAchievement(
        context: context,
        memberId: memberId,
        key: 'visits_50',
      );
    }
    if (totalVisits >= 100) {
      await achievementProvider.awardAchievement(
        context: context,
        memberId: memberId,
        key: 'visits_100',
      );
    }

    // Streak achievements
    if (streak >= 10) {
      await achievementProvider.awardAchievement(
        context: context,
        memberId: memberId,
        key: '10_day_streak',
      );
    }
  }

  // Check after goal completion
  static Future<void> checkAfterGoalCompletion(
    BuildContext context,
    String memberId,
    String goalId,
  ) async {
    if (memberId.isEmpty) return;
    
    final achievementProvider = context.read<AchievementProvider>();
    
    await achievementProvider.awardAchievement(
      context: context,
      memberId: memberId,
      key: 'goal_completed',
      relatedGoalId: goalId,
    );
  }
}