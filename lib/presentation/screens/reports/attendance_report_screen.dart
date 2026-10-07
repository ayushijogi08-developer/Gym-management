import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gym_management_app/providers/attendance_provider.dart';
import 'package:gym_management_app/services/report_service.dart';
import 'package:gym_management_app/themes/app_design_tokens.dart';
import 'package:provider/provider.dart';
import '../../widgets/glass_container.dart';

class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  final DateTimeRange _currentRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;
  List<BarChartGroupData> _barGroups = [];
  int _totalCheckIns = 0;
  int _avgDaily = 0;
  int _daysTracked = 0;
  String _trend = 'Stable';

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
      // Try to get data from API first
      final data = await ReportService.fetchReport(
        'attendance',
        _currentRange.start,
        _currentRange.end,
      );

      // ignore: avoid_print
      print('📊 Attendance API Response: $data');

      if (data.isNotEmpty) {
        setState(() {
          _data = data;
          _prepareData(data);
        });
      } else {
        // If API returns empty, try local data
        // ignore: avoid_print
        print('⚠️ API returned empty, trying local data...');
        _loadLocalData();
      }
    } catch (e) {
      // ignore: avoid_print
      print('❌ Error fetching attendance report: $e');
      // Try local data as fallback
      _loadLocalData();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadLocalData() {
    try {
      final attendanceProvider = context.read<AttendanceProvider>();
      final allRecords = attendanceProvider.allRecords;

      // ignore: avoid_print
      print('📊 Local records count: ${allRecords.length}');

      if (allRecords.isNotEmpty) {
        // Group records by date
        final groupedData = <String, int>{};
        for (var record in allRecords) {
          final dateKey =
              '${record.timestamp.year}-${record.timestamp.month.toString().padLeft(2, '0')}-${record.timestamp.day.toString().padLeft(2, '0')}';
          groupedData[dateKey] = (groupedData[dateKey] ?? 0) + 1;
        }

        // Convert to list for chart
        final sortedKeys = groupedData.keys.toList()..sort();
        _daysTracked = sortedKeys.length;

        _barGroups = [];
        _totalCheckIns = 0;

        for (int i = 0; i < sortedKeys.length && i < 30; i++) {
          final key = sortedKeys[i];
          final count = groupedData[key] ?? 0;
          _totalCheckIns += count;

          _barGroups.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: count.toDouble(),
                  color: Theme.of(context).colorScheme.primary,
                  width: 10,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          );
        }

        // Calculate average
        _avgDaily =
            _daysTracked > 0 ? (_totalCheckIns / _daysTracked).round() : 0;

        // Calculate trend
        if (sortedKeys.length > 1) {
          final first = groupedData[sortedKeys.first] ?? 0;
          final last = groupedData[sortedKeys.last] ?? 0;
          if (last > first) {
            _trend = '📈 Increasing';
          } else if (last < first) {
            _trend = '📉 Decreasing';
          } else {
            _trend = '➡️ Stable';
          }
        }

        // ignore: avoid_print
        print('✅ Loaded $_totalCheckIns attendance records from local');
        return;
      }
    } catch (e) {
      // ignore: avoid_print
      print('❌ Error loading local data: $e');
    }

    // If no data found, show dummy data with message
    _showDummyData();
  }

  void _prepareData(Map<String, dynamic> data) {
    // Check different possible data structures
    List<dynamic> dailyData = [];

    if (data['dailyData'] != null) {
      dailyData = data['dailyData'] as List? ?? [];
    }

    if (dailyData.isNotEmpty) {
      _barGroups = [];
      _totalCheckIns = 0;

      // Sort data by date
      dailyData.sort((a, b) {
        final dateA = a is Map ? (a['_id'] ?? '').toString() : '';
        final dateB = b is Map ? (b['_id'] ?? '').toString() : '';
        return dateA.compareTo(dateB);
      });

      // Take only last 30 days
      final limitedData = dailyData.length > 30
          ? dailyData.sublist(dailyData.length - 30)
          : dailyData;
      _daysTracked = limitedData.length;

      for (int i = 0; i < limitedData.length; i++) {
        final item = limitedData[i];
        final count = _getCountFromItem(item);
        _totalCheckIns += count;

        _barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: count.toDouble(),
                color: Theme.of(context).colorScheme.primary,
                width: 10,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }

      // Calculate average
      _avgDaily =
          _daysTracked > 0 ? (_totalCheckIns / _daysTracked).round() : 0;

      // Calculate trend
      if (limitedData.length > 1) {
        final first = _getCountFromItem(limitedData.first);
        final last = _getCountFromItem(limitedData.last);
        if (last > first) {
          _trend = '📈 Increasing';
        } else if (last < first) {
          _trend = '📉 Decreasing';
        } else {
          _trend = '➡️ Stable';
        }
      }
    } else {
      _loadLocalData();
    }
  }

  int _getCountFromItem(dynamic item) {
    if (item is Map<String, dynamic>) {
      if (item.containsKey('count')) {
        return (item['count'] ?? 0) as int;
      } else if (item.containsKey('total')) {
        return (item['total'] ?? 0) as int;
      } else if (item.containsKey('value')) {
        return (item['value'] ?? 0) as int;
      }
    }
    return 0;
  }

  void _showDummyData() {
    _totalCheckIns = 0;
    _avgDaily = 0;
    _daysTracked = 0;
    _trend = 'No Data';
    _barGroups = [];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final chartText = context.textSecondary;
    final chartGrid = context.surfaceAlt;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchReport,
          ),
        ],
      ),
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
              : _totalCheckIns == 0
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.how_to_reg,
                              size: 64, color: context.textMuted),
                          const SizedBox(height: 16),
                          Text(
                            'No attendance data found',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: context.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add some check-ins to see the report',
                            style: TextStyle(color: context.textMuted),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchReport,
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Summary Stats
                          Row(
                            children: [
                              Expanded(
                                child: GlassContainer(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        Text('Total Check-ins',
                                            style: TextStyle(
                                                color: context.textSecondary)),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$_totalCheckIns',
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
                              const SizedBox(width: 12),
                              Expanded(
                                child: GlassContainer(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        Text('Avg Daily',
                                            style: TextStyle(
                                                color: context.textSecondary)),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$_avgDaily',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: scheme.tertiary,
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

                          Row(
                            children: [
                              Expanded(
                                child: GlassContainer(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        Text('Days Tracked',
                                            style: TextStyle(
                                                color: context.textSecondary)),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$_daysTracked',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: context.accent,
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
                                        Text('Trend',
                                            style: TextStyle(
                                                color: context.textSecondary)),
                                        const SizedBox(height: 4),
                                        Text(
                                          _trend,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: _trend.contains(
                                                    'Increasing')
                                                ? scheme.tertiary
                                                : _trend.contains(
                                                        'Decreasing')
                                                    ? scheme.error
                                                    : context.warning,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          if (_barGroups.isNotEmpty) ...[
                            Text(
                              'Daily Check-ins',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 250,
                              child: BarChart(
                                BarChartData(
                                  barGroups: _barGroups,
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: _barGroups.length <= 15,
                                        reservedSize: 30,
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          if (_barGroups.isNotEmpty &&
                                              value.toInt() <
                                                  _barGroups.length) {
                                            return Text(
                                              '${value.toInt() + 1}',
                                              style: TextStyle(
                                                  color: chartText,
                                                  fontSize: 10),
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
                                                color: chartText,
                                                fontSize: 10),
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
                        ],
                      ),
                    ),
    );
  }
}
