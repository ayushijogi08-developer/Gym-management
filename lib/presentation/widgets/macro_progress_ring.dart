import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class MacroProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String label;
  final String value;
  final Color color;

  const MacroProgressRing({
    super.key,
    required this.progress,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularPercentIndicator(
          radius: 45,
          lineWidth: 10,
          percent: progress.clamp(0.0, 1.0),
          center: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          progressColor: color,
          backgroundColor: Colors.grey.withValues(alpha: 0.3),
          circularStrokeCap: CircularStrokeCap.round,
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}