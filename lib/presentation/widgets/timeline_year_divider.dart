import 'package:flutter/material.dart';

class TimelineYearDivider extends StatelessWidget {
  final String year;

  const TimelineYearDivider({super.key, required this.year});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Colors.white24)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(year, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70)),
          ),
          const Expanded(child: Divider(color: Colors.white24)),
        ],
      ),
    );
  }
}