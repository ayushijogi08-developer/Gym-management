import 'package:flutter/material.dart';
import '../../../data/models/meal_model.dart';
import 'glass_container.dart';

class MealCard extends StatelessWidget {
  final MealModel meal;
  final VoidCallback? onMarkCompleted;
  final VoidCallback? onSkip;

  const MealCard({
    super.key,
    required this.meal,
    this.onMarkCompleted,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(meal.mealType, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(meal.mealName, style: const TextStyle(fontSize: 16)),
            Text('${meal.calories.toInt()} kcal • ${meal.protein.toInt()}g Protein'),
            const SizedBox(height: 12),
            Row(
              children: [
                if (onMarkCompleted != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onMarkCompleted,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Completed'),
                    ),
                  ),
                const SizedBox(width: 8),
                if (onSkip != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onSkip,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      child: const Text('Skip'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}