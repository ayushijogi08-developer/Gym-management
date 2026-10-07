import 'package:flutter/material.dart';
import 'package:gym_management_app/presentation/widgets/glass_container.dart';
import '../../../data/models/timeline_event_model.dart';
import '../../../themes/app_colors.dart';

class TimelineEntryTile extends StatelessWidget {
  final TimelineEventModel event;

  const TimelineEntryTile({super.key, required this.event});

  IconData _getIconForEventType(String eventType) {
    switch (eventType) {
      case 'workout_completed':
      case 'workout_session':
        return Icons.fitness_center;
      case 'measurement':
        return Icons.monitor_weight;
      case 'goal_created':
        return Icons.flag;
      case 'goal_completed':
        return Icons.emoji_events;
      case 'achievement':
        return Icons.star;
      case 'attendance':
        return Icons.check_circle;
      default:
        return Icons.timeline;
    }
  }

  Color _getColorForEventType(String eventType) {
    switch (eventType) {
      case 'workout_completed':
      case 'workout_session':
        return Colors.orange;
      case 'measurement':
        return Colors.blue;
      case 'goal_created':
        return Colors.purple;
      case 'goal_completed':
        return Colors.amber;
      case 'achievement':
        return Colors.green;
      case 'attendance':
        return Colors.teal;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconForEventType(event.eventType);
    final color = _getColorForEventType(event.eventType);

    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (event.subtitle != null && event.subtitle!.isNotEmpty)
                    Text(
                      event.subtitle!,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(event.date),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            if (event.thumbnailPath != null && event.thumbnailPath!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  event.thumbnailPath!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.white.withValues(alpha: 0.1),
                      child: const Icon(Icons.image_not_supported, color: Colors.white54),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(date.year, date.month, date.day);
    
    if (eventDate == today) {
      return 'Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (eventDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}