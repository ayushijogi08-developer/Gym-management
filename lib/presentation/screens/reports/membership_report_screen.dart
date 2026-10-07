import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/plan_model.dart';
import '../../../providers/plan_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../../services/report_service.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';

class MembershipReportScreen extends StatefulWidget {
  const MembershipReportScreen({super.key});

  @override
  State<MembershipReportScreen> createState() => _MembershipReportScreenState();
}

class _MembershipReportScreenState extends State<MembershipReportScreen> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    setState(() => _isLoading = true);
    try {
      final data = await ReportService.fetchReport(
        'membership',
        DateTime.now().subtract(const Duration(days: 30)),
        DateTime.now(),
      );
      setState(() => _data = data);
    } catch (e) {
      debugPrint('Error loading membership report: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Computes plan-distribution pie sections from the live providers.
  /// Returns null when the gym has no active subscriptions yet so we can
  /// render an empty-state instead of fake numbers.
  List<_PlanSlice>? _computePlanSlices(BuildContext context) {
    final subs = context.watch<SubscriptionProvider>().getAll();
    final plans = context.watch<PlanProvider>().plans;

    final active = subs.where((s) => s.status == 'active').toList();
    if (active.isEmpty) return null;

    final byPlan = <String, int>{};
    for (final s in active) {
      byPlan[s.planId] = (byPlan[s.planId] ?? 0) + 1;
    }

    // Sort by count desc, take top 3, merge the rest into "Other".
    final sortedEntries = byPlan.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top =
        sortedEntries.take(3).map((e) {
          PlanModel? plan;
          for (final p in plans) {
            if (p.id == e.key) {
              plan = p;
              break;
            }
          }
          return _PlanSlice(
            label: plan?.planName ?? 'Plan ${e.key}',
            count: e.value,
          );
        }).toList();

    if (sortedEntries.length > 3) {
      final otherCount = sortedEntries
          .skip(3)
          .fold<int>(0, (sum, entry) => sum + entry.value);
      if (otherCount > 0) {
        top.add(_PlanSlice(label: 'Other', count: otherCount));
      }
    }
    return top;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Membership Report')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GlassContainer(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'Active Members',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${_data?['activeMembers'] ?? context.watch<SubscriptionProvider>().getAll().where((s) => s.status == 'active').length}',
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Plan Distribution',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      final slices = _computePlanSlices(context);
                      if (slices == null) {
                        return GlassContainer(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Icon(Icons.pie_chart_outline,
                                    color: context.textSecondary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'No active subscriptions yet — distribution will appear once members join.',
                                    style: TextStyle(color: context.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      final total = slices.fold<int>(
                          0, (sum, slice) => sum + slice.count);
                      final colors = <Color>[
                        scheme.tertiary,
                        scheme.primary,
                        context.accent,
                        context.success,
                        context.warning,
                        context.info,
                      ];
                      return Column(
                        children: [
                          SizedBox(
                            height: 250,
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  for (var i = 0; i < slices.length; i++)
                                    PieChartSectionData(
                                      value: slices[i].count.toDouble(),
                                      color: colors[i % colors.length],
                                      title: '${((slices[i].count / total) * 100).toStringAsFixed(0)}%',
                                      titleStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      radius: 80,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...slices.map(
                            (slice) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: colors[
                                          slices.indexOf(slice) %
                                              colors.length],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      slice.label,
                                      style: TextStyle(
                                          color: context.textPrimary),
                                    ),
                                  ),
                                  Text(
                                    '${slice.count} members',
                                    style: TextStyle(
                                        color: context.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class _PlanSlice {
  final String label;
  final int count;
  const _PlanSlice({required this.label, required this.count});
}
