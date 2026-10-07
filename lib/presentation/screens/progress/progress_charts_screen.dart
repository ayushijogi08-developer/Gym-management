import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/body_progress_provider.dart';
import '../../../themes/app_colors.dart';
import '../../widgets/progress_line_chart.dart';

class ProgressChartsScreen extends StatefulWidget {
  const ProgressChartsScreen({super.key});

  @override
  State<ProgressChartsScreen> createState() => _ProgressChartsScreenState();
}

class _ProgressChartsScreenState extends State<ProgressChartsScreen> {
  bool _initialFetchAttempted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final memberId = auth.currentUser?.linkedMemberId ?? '';
      if (memberId.isEmpty) {
        setState(() => _initialFetchAttempted = true);
        return;
      }
      await context.read<BodyProgressProvider>().fetchForMember(memberId);
      if (mounted) setState(() => _initialFetchAttempted = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<BodyProgressProvider>();
    final memberId = auth.currentUser?.linkedMemberId ?? '';

    // Build trend spots from real history (oldest → newest for the chart).
    final history = provider.getHistory(memberId);
    final sorted = [...history]..sort((a, b) => a.date.compareTo(b.date));
    final weightSpots = <FlSpot>[];
    final bodyFatSpots = <FlSpot>[];
    for (var i = 0; i < sorted.length; i++) {
      final entry = sorted[i];
      // x-axis: days since the first entry. y-axis: the metric.
      final days = i.toDouble();
      weightSpots.add(FlSpot(days, entry.weightKg));
      if (entry.bodyFatPercent != null) {
        bodyFatSpots.add(FlSpot(days, entry.bodyFatPercent!));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Progress Charts')),
      body: !_initialFetchAttempted
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No measurements yet — log a body progress entry to see trends.',
                      style: TextStyle(color: Theme.of(context).hintColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ProgressLineChart(
                      title: 'Weight Trend',
                      spots: weightSpots,
                    ),
                    const SizedBox(height: 32),
                    ProgressLineChart(
                      title: 'Body Fat % Trend',
                      spots: bodyFatSpots,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Logged ${history.length} entr${history.length == 1 ? 'y' : 'ies'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
    );
  }
}
