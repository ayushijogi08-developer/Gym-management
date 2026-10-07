import 'package:flutter/material.dart';
import '../../widgets/glass_container.dart';

class TrainerMessageCard extends StatelessWidget {
  const TrainerMessageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Message from Trainer', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('"Great job last week! Let\'s focus on increasing protein intake."', 
                style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}