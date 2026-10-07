import 'package:flutter/material.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';

class GoalProgressMiniCard extends StatelessWidget {
  const GoalProgressMiniCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Goal',
              style: TextStyle(fontSize: 16, color: context.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              'Lose 5kg',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.6,
              backgroundColor: context.border.withValues(alpha: 0.4),
              color: Colors.purple,
            ),
            const SizedBox(height: 6),
            Text(
              '3kg lost • 2kg to go',
              style: TextStyle(fontSize: 12, color: context.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}