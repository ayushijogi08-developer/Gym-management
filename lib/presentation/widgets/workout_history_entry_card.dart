import 'package:flutter/material.dart';
import 'package:gym_management_app/data/models/workout_log_model.dart';
import 'glass_container.dart';

class WorkoutHistoryEntryCard extends StatelessWidget {
  final WorkoutLogModel log;
  final WorkoutLogModel? previousLog;

  const WorkoutHistoryEntryCard({
    super.key,
    required this.log,
    this.previousLog,
  });

  @override
  Widget build(BuildContext context) {
    // Format date
    final dateTime = log.date;
    final dayName = _getDayName(dateTime.weekday);
    final formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    final formattedTime = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date and status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'COMPLETED',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              // Show date and time
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.white54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$dayName, $formattedDate',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.white54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formattedTime,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Exercise name
          Text(
            log.exerciseName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // Details
          Row(
            children: [
              _buildDetailChip(
                icon: Icons.fitness_center,
                label: '${log.actualSetsCompleted ?? 0} sets',
              ),
              const SizedBox(width: 8),
              _buildDetailChip(
                icon: Icons.repeat,
                label: '${log.reps ?? 0} reps',
              ),
              if (log.weightUsedKg != null && log.weightUsedKg! > 0) ...[
                const SizedBox(width: 8),
                _buildDetailChip(
                  icon: Icons.monitor_weight,
                  label: '${log.weightUsedKg} kg',
                ),
              ],
              if (log.caloriesBurned != null && log.caloriesBurned! > 0) ...[
                const SizedBox(width: 8),
                _buildDetailChip(
                  icon: Icons.local_fire_department,
                  label: '${log.caloriesBurned} cal',
                ),
              ],
            ],
          ),

          // VS Previous
          if (previousLog != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Previous: ${previousLog!.actualSetsCompleted ?? 0} sets × ${previousLog!.reps ?? 0} reps',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white54,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}