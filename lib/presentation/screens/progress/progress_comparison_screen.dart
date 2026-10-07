import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/body_progress_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';

class ProgressComparisonScreen extends StatefulWidget {
  const ProgressComparisonScreen({super.key});

  @override
  State<ProgressComparisonScreen> createState() => _ProgressComparisonScreenState();
}

class _ProgressComparisonScreenState extends State<ProgressComparisonScreen> {
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

    final first = provider.getFirstEntry(memberId);
    final latest = provider.getLatest(memberId);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Progress Comparison')),
      body: !_initialFetchAttempted
          ? const Center(child: CircularProgressIndicator())
          : (first == null || latest == null || first.id == latest.id)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      first == null
                          ? 'No measurements yet — log at least one body progress entry to see a Day 1 vs Today comparison.'
                          : 'You only have one entry so far. Log another one to compare against your Day 1 baseline.',
                      style: TextStyle(color: context.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Day 1 vs Today',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: context.colors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _ComparisonColumn(
                                    label: 'Day 1',
                                    date: dateFormat.format(first.date),
                                    entries: const [
                                      _ComparisonMetric('Weight', 'weightKg', unit: 'kg'),
                                      _ComparisonMetric('Body Fat', 'bodyFatPercent', unit: '%'),
                                    ],
                                    source: first,
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 120,
                                  color: context.border,
                                  margin: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                Expanded(
                                  child: _ComparisonColumn(
                                    label: 'Today',
                                    date: dateFormat.format(latest.date),
                                    entries: const [
                                      _ComparisonMetric('Weight', 'weightKg', unit: 'kg'),
                                      _ComparisonMetric('Body Fat', 'bodyFatPercent', unit: '%'),
                                    ],
                                    source: latest,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _DeltaSummary(
                              first: first,
                              latest: latest,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _ComparisonMetric {
  final String label;
  final String field;
  final String unit;
  const _ComparisonMetric(this.label, this.field, {required this.unit});
}

class _ComparisonColumn extends StatelessWidget {
  final String label;
  final String date;
  final List<_ComparisonMetric> entries;
  final dynamic source; // BodyProgressModel

  const _ComparisonColumn({
    required this.label,
    required this.date,
    required this.entries,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
        Text(
          date,
          style: TextStyle(fontSize: 11, color: context.textSecondary),
        ),
        const SizedBox(height: 12),
        for (final metric in entries) ...[
          Text(
            metric.label,
            style: TextStyle(fontSize: 11, color: context.textSecondary),
          ),
          Builder(builder: (context) {
            final raw = metric.field == 'weightKg'
                ? (source.weightKg as double)
                : (source.bodyFatPercent as double?);
            final value = raw == null ? '—' : '${raw.toStringAsFixed(1)} ${metric.unit}';
            return Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _DeltaSummary extends StatelessWidget {
  final dynamic first;
  final dynamic latest;

  const _DeltaSummary({required this.first, required this.latest});

  @override
  Widget build(BuildContext context) {
    final weightDelta = (latest.weightKg as double) - (first.weightKg as double);
    final firstFat = first.bodyFatPercent as double?;
    final latestFat = latest.bodyFatPercent as double?;
    final fatDelta = (firstFat != null && latestFat != null)
        ? latestFat - firstFat
        : null;

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _DeltaChip(
          label: 'Weight Δ',
          value: '${weightDelta >= 0 ? '+' : ''}${weightDelta.toStringAsFixed(1)} kg',
          color: weightDelta == 0
              ? context.textSecondary
              : (weightDelta < 0 ? AppColors.success : AppColors.warning),
        ),
        if (fatDelta != null)
          _DeltaChip(
            label: 'Body Fat Δ',
            value: '${fatDelta >= 0 ? '+' : ''}${fatDelta.toStringAsFixed(1)}%',
            color: fatDelta == 0
                ? context.textSecondary
                : (fatDelta < 0 ? AppColors.success : AppColors.warning),
          ),
      ],
    );
  }
}

class _DeltaChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DeltaChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 11, color: context.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}