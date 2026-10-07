import 'package:flutter/material.dart';
import 'package:gym_management_app/data/models/exercise_model.dart';
import 'package:gym_management_app/themes/app_colors.dart';
import 'glass_container.dart';

class ExerciseCard extends StatefulWidget {
  final ExerciseModel exercise;
  final VoidCallback onMarkCompleted;
  final bool isCompleted;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onMarkCompleted,
    this.isCompleted = false,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.isCompleted;
  }

  @override
  void didUpdateWidget(ExerciseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCompleted != widget.isCompleted) {
      setState(() {
        _isCompleted = widget.isCompleted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise Name & Status
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.exercise.exerciseName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _isCompleted 
                      ? Colors.green.withValues(alpha: 0.2) 
                      : Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isCompleted ? Colors.green : Colors.orange,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isCompleted ? Icons.check_circle : Icons.pending,
                      color: _isCompleted ? Colors.green : Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isCompleted ? 'COMPLETED' : 'PENDING',
                      style: TextStyle(
                        color: _isCompleted ? Colors.green : Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Exercise Details
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildDetailChip(Icons.fitness_center, '${widget.exercise.sets} sets'),
              _buildDetailChip(Icons.repeat, '${widget.exercise.reps} reps'),
              _buildDetailChip(Icons.timer, '${widget.exercise.restTimeSeconds}s rest'),
              // FIXED: Using Icons.flag which is definitely available
              _buildDetailChip(Icons.flag, widget.exercise.targetMuscle),
            ],
          ),
          const SizedBox(height: 12),
          
          // Mark Complete Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isCompleted ? null : widget.onMarkCompleted,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isCompleted ? Colors.green : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isCompleted ? Icons.check_circle : Icons.play_arrow,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isCompleted ? 'COMPLETED ✓' : 'MARK COMPLETED',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
          const SizedBox(width: 6),
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
}