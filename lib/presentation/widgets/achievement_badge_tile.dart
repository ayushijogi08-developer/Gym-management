import 'package:flutter/material.dart';
import 'package:gym_management_app/data/models/achievement_model.dart';
import 'glass_container.dart';

class AchievementBadgeTile extends StatelessWidget {
  final AchievementModel achievement;
  final VoidCallback? onTap;

  const AchievementBadgeTile({
    super.key,
    required this.achievement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Badge Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: achievement.isSeen 
                  ? Colors.white.withValues(alpha: 0.1) 
                  : Colors.amber.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: achievement.isSeen 
                    ? Colors.white.withValues(alpha: 0.3) 
                    : Colors.amber,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                achievement.iconAsset.isNotEmpty 
                    ? achievement.iconAsset 
                    : '🏆',
                style: const TextStyle(fontSize: 30),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            achievement.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Description
          Text(
            achievement.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Date
          Text(
            'Earned: ${achievement.earnedDate.toString().split(' ')[0]}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
            ),
          ),
          if (!achievement.isSeen) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber, width: 1),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}