import 'package:flutter/material.dart';
import '../../../themes/app_colors.dart';
import '../../widgets/glass_container.dart';

class AttendanceStatStrip extends StatelessWidget {
  final int totalVisits;
  final int currentStreak;
  final int longestStreak;
  final int missedDaysThisMonth;

  const AttendanceStatStrip({
    super.key,
    required this.totalVisits,
    required this.currentStreak,
    required this.longestStreak,
    required this.missedDaysThisMonth,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat('Total Visits', totalVisits.toString(), Icons.calendar_today),
            _buildStat('Current Streak', '$currentStreak days', Icons.local_fire_department),
            _buildStat('Longest', '$longestStreak days', Icons.emoji_events),
            _buildStat('Missed This Month', missedDaysThisMonth.toString(), Icons.event_busy),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ],
    );
  }
}