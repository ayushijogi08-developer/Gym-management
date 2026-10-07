import 'package:flutter/material.dart';

class CompletionProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String title;
  final String subtitle;
  final Color progressColor;

  const CompletionProgressBar({
    super.key,
    required this.progress,
    required this.title,
    required this.subtitle,
    this.progressColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('${(progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey.withValues(alpha: 0.3),
            color: progressColor,
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}