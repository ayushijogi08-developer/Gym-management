import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/achievement_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/achievement_badge_tile.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);
    
    final auth = context.read<AuthProvider>();
    final achievementProvider = context.read<AchievementProvider>();
    final memberId = auth.currentUser?.linkedMemberId ?? '';

    if (memberId.isNotEmpty) {
      await achievementProvider.fetchForMember(memberId);
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final achievementProvider = context.watch<AchievementProvider>();

    final memberId = auth.currentUser?.linkedMemberId ?? '';
    final achievements = achievementProvider.getByMember(memberId);
    final unseen = achievementProvider.unseenCount(memberId);

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        title: const Text('Achievements'),
        actions: [
          if (unseen > 0)
            IconButton(
              icon: Badge(
                label: Text('$unseen'),
                child: const Icon(Icons.check_circle_outline),
              ),
              onPressed: () => achievementProvider.markAllSeen(memberId),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : achievements.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 80,
                        color: context.textMuted,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No achievements yet',
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Keep training to earn badges! 💪',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    return AchievementBadgeTile(
                      achievement: achievements[index],
                      onTap: () {
                        // Mark as seen when tapped
                        if (!achievements[index].isSeen) {
                          achievementProvider.markSeen(achievements[index].id);
                        }
                        // Show detail dialog
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: context.surface,
                            title: Text(
                              achievements[index].title,
                              style: TextStyle(color: context.textPrimary),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  achievements[index].iconAsset.isNotEmpty
                                      ? achievements[index].iconAsset
                                      : '🏆',
                                  style: const TextStyle(fontSize: 48),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  achievements[index].description,
                                  style: TextStyle(color: context.textSecondary),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Earned on ${achievements[index].earnedDate.toString().split(' ')[0]}',
                                  style: TextStyle(
                                    color: context.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}