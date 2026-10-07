import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gym_management_app/services/report_service.dart';
import 'package:gym_management_app/themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';

class GrowthReportScreen extends StatefulWidget {
  const GrowthReportScreen({super.key});

  @override
  State<GrowthReportScreen> createState() => _GrowthReportScreenState();
}

class _GrowthReportScreenState extends State<GrowthReportScreen> {
  final DateTimeRange _currentRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 90)),
    end: DateTime.now(),
  );

  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;
  List<FlSpot> _chartSpots = [];
  int _totalNewMembers = 0;

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ReportService.fetchReport(
        'growth',
        _currentRange.start,
        _currentRange.end,
      );
      setState(() {
        _data = data;
        _prepareChartData(data);
      });
    } catch (e) {
      setState(() => _error = e.toString());
      // ignore: avoid_print
      print('❌ Error fetching growth report: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _prepareChartData(Map<String, dynamic> data) {
    final monthlyGrowth = data['monthlyGrowth'] as List? ?? [];

    _totalNewMembers = 0;
    for (var item in monthlyGrowth) {
      final map = item as Map<String, dynamic>;
      _totalNewMembers += (map['count'] ?? 0) as int;
    }

    if (monthlyGrowth.isNotEmpty) {
      _chartSpots = [];
      for (int i = 0; i < monthlyGrowth.length; i++) {
        final item = monthlyGrowth[i] as Map<String, dynamic>;
        final count = (item['count'] ?? 0).toDouble();
        _chartSpots.add(FlSpot(i.toDouble(), count));
      }
    } else {
      _chartSpots = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data ?? {'monthlyGrowth': []};
    final monthlyGrowth = data['monthlyGrowth'] as List? ?? [];
    final scheme = Theme.of(context).colorScheme;
    final chartText = context.textSecondary;
    final chartGrid = context.surfaceAlt;

    // Calculate growth percentage
    double growthPercent = 0;
    String growthLabel = 'No Data';

    if (monthlyGrowth.isNotEmpty && monthlyGrowth.length > 1) {
      final firstItem = monthlyGrowth.first as Map<String, dynamic>;
      final lastItem = monthlyGrowth.last as Map<String, dynamic>;
      final first = (firstItem['count'] ?? 0) as num;
      final last = (lastItem['count'] ?? 0) as num;

      if (first > 0) {
        growthPercent = ((last - first) / first * 100);
        growthLabel = 'Growth Rate';
      } else if (last > 0) {
        growthPercent = 100;
        growthLabel = 'Growth Rate';
      } else {
        growthLabel = 'No Growth Data';
      }
    } else if (monthlyGrowth.length == 1) {
      final item = monthlyGrowth.first as Map<String, dynamic>;
      final count = (item['count'] ?? 0) as num;
      if (count > 0) {
        growthLabel = 'Started with $count members';
        growthPercent = 0;
      } else {
        growthLabel = 'No members added';
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Growth Report')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: scheme.error),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading report',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(color: chartText),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchReport,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Growth Summary Cards
                      Row(
                        children: [
                          Expanded(
                            child: GlassContainer(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text('Total Growth',
                                        style: TextStyle(
                                            color: context.textSecondary)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '+$_totalNewMembers',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: scheme.tertiary,
                                      ),
                                    ),
                                    Text('New Members',
                                        style: TextStyle(
                                            color: context.textMuted)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GlassContainer(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text(
                                      monthlyGrowth.isNotEmpty
                                          ? '${monthlyGrowth.length} Months'
                                          : 'No Data',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: scheme.primary,
                                      ),
                                    ),
                                    Text('Period Tracked',
                                        style: TextStyle(
                                            color: context.textMuted)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      GlassContainer(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                growthPercent >= 0 &&
                                        monthlyGrowth.length > 1
                                    ? '+${growthPercent.toStringAsFixed(1)}%'
                                    : monthlyGrowth.length == 1 &&
                                            _totalNewMembers > 0
                                        ? '$_totalNewMembers new'
                                        : 'No Data',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: growthPercent >= 0
                                      ? scheme.tertiary
                                      : scheme.error,
                                ),
                              ),
                              Text(
                                growthLabel,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: context.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (_chartSpots.isNotEmpty) ...[
                        Text(
                          'Member Growth Trend',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 280,
                          child: LineChart(
                            LineChartData(
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _chartSpots,
                                  isCurved: true,
                                  color: context.accent,
                                  barWidth: 3,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color:
                                        context.accent.withValues(alpha: 0.12),
                                  ),
                                ),
                              ],
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: _chartSpots.length <= 10,
                                    reservedSize: 30,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      if (_chartSpots.isNotEmpty &&
                                          value.toInt() <
                                              _chartSpots.length) {
                                        final index = value.toInt();
                                        final monthlyGrowthData =
                                            monthlyGrowth[index]
                                                as Map<String, dynamic>;
                                        final label =
                                            monthlyGrowthData['_id'] ??
                                                'Month ${index + 1}';
                                        return Text(
                                          label.length > 7
                                              ? '${label.substring(0, 7)}...'
                                              : label,
                                          style: TextStyle(
                                              color: chartText, fontSize: 10),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: TextStyle(
                                            color: chartText, fontSize: 10),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawHorizontalLine: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: chartGrid,
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(color: chartGrid),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Monthly Breakdown List
                      if (monthlyGrowth.isNotEmpty)
                        GlassContainer(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Monthly Breakdown',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                ...monthlyGrowth.map((item) {
                                  final map = item as Map<String, dynamic>;
                                  final count = map['count'] ?? 0;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          map['_id'] ?? 'Unknown',
                                          style: TextStyle(
                                              color: context.textSecondary),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: count > 0
                                                ? context.accent
                                                    .withValues(alpha: 0.16)
                                                : context.surfaceAlt,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '${count > 0 ? '+' : ''}$count new members',
                                            style: TextStyle(
                                              color: count > 0
                                                  ? context.accent
                                                  : context.textMuted,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}
