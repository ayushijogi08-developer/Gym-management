import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gym_management_app/presentation/widgets/reports/report_date_range_selector.dart';
import 'package:gym_management_app/services/report_service.dart';
import 'package:gym_management_app/themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';

class RevenueReportScreen extends StatefulWidget {
  const RevenueReportScreen({super.key});

  @override
  State<RevenueReportScreen> createState() => _RevenueReportScreenState();
}

class _RevenueReportScreenState extends State<RevenueReportScreen> {
  DateTimeRange _currentRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;
  List<FlSpot> _chartSpots = [];

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
        'revenue',
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
      print('❌ Error fetching revenue report: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _prepareChartData(Map<String, dynamic> data) {
    final dailyData = data['dailyData'] as List? ?? [];

    if (dailyData.isNotEmpty) {
      _chartSpots = [];
      for (int i = 0; i < dailyData.length; i++) {
        final item = dailyData[i] as Map<String, dynamic>;
        final amount = (item['amount'] ?? 0).toDouble();
        _chartSpots.add(FlSpot(i.toDouble(), amount));
      }
    } else {
      // No daily data was returned for the selected range — show an empty
      // series. The chart UI below renders an empty-state label when this
      // happens, instead of fabricating fake revenue.
      _chartSpots = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data ??
        {
          'totalRevenue': 0,
          'totalRefunds': 0,
          'transactionCount': 0,
          'byMethod': []
        };
    final scheme = Theme.of(context).colorScheme;
    final successColor = scheme.tertiary;
    final errorColor = scheme.error;
    // Use muted text tones so chart axes / dim labels stay readable in both
    // light and dark palettes.
    final chartText = context.textSecondary;
    final chartGrid = context.surfaceAlt;

    return Scaffold(
      appBar: AppBar(title: const Text('Revenue Report')),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Range Selector
                      ReportDateRangeSelector(
                        selectedRange: _currentRange,
                        onRangeChanged: (newRange) {
                          setState(() => _currentRange = newRange);
                          _fetchReport();
                        },
                      ),
                      const SizedBox(height: 16),

                      // Summary Cards
                      Row(
                        children: [
                          Expanded(
                            child: GlassContainer(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text('Total Revenue',
                                        style:
                                            TextStyle(color: chartText)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${(data['totalRevenue'] ?? 0).toInt()}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: successColor,
                                      ),
                                    ),
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
                                    Text('Transactions',
                                        style:
                                            TextStyle(color: chartText)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${data['transactionCount'] ?? 0}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: scheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Refunds
                      if ((data['totalRefunds'] ?? 0) > 0)
                        GlassContainer(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Refunds',
                                    style: TextStyle(color: chartText)),
                                Text(
                                  '₹${(data['totalRefunds'] ?? 0).toInt()}',
                                  style: TextStyle(
                                    color: errorColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Payment Method Breakdown
                      if ((data['byMethod'] as List).isNotEmpty) ...[
                        Text(
                          'Payment Methods',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        ...(data['byMethod'] as List).map((method) => GlassContainer(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _capitalizeMethod(method['method']),
                                      style: TextStyle(color: chartText),
                                    ),
                                    Text(
                                      '₹${(method['amount'] ?? 0).toInt()}',
                                      style: TextStyle(
                                        color: context.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                        const SizedBox(height: 24),
                      ],

                      // Revenue Trend Chart
                      Text(
                        'Revenue Trend',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      if (_chartSpots.isEmpty)
                        GlassContainer(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Icon(Icons.show_chart, color: chartText),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'No revenue recorded in this date range',
                                    style: TextStyle(color: chartText),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 250,
                          child: LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                spots: _chartSpots,
                                isCurved: true,
                                color: successColor,
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: successColor.withValues(alpha: 0.12),
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
                                        value.toInt() < _chartSpots.length) {
                                      return Text(
                                        'Day ${value.toInt() + 1}',
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
                                      '₹${value.toInt()}',
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
                    ],
                  ),
                ),
    );
  }

  String _capitalizeMethod(String method) {
    switch (method) {
      case 'cash':
        return 'Cash';
      case 'card':
        return 'Card';
      case 'upi':
        return 'UPI';
      case 'netBanking':
        return 'Net Banking';
      case 'wallet':
        return 'Wallet';
      default:
        return method.toUpperCase();
    }
  }
}
