import 'package:flutter/material.dart';
import 'package:gym_management_app/presentation/widgets/gradient_button.dart';
import 'package:gym_management_app/themes/app_colors.dart';

class CelebrationDialog extends StatelessWidget {
  final String message;

  const CelebrationDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.background,
              AppColors.background.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              '🎉 Amazing! 🎉',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Keep Going! 💪',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}