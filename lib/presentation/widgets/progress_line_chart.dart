import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../themes/app_colors.dart';

class ProgressLineChart extends StatelessWidget {
  final String title;
  final List<FlSpot> spots;

  const ProgressLineChart({super.key, required this.title, required this.spots});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: const FlTitlesData(show: true),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 3,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}