import 'package:flutter/material.dart';
import '../../../themes/app_design_tokens.dart';
import '../glass_container.dart';

class ReportSummaryStatRow extends StatelessWidget {
  final List<Map<String, dynamic>> stats;

  const ReportSummaryStatRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Text(
                    stat['value'].toString(),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    stat['label'],
                    style: TextStyle(
                        fontSize: 12, color: context.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
