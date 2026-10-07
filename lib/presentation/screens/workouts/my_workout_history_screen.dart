import 'package:flutter/material.dart';
import 'package:gym_management_app/data/models/workout_log_model.dart';
import 'package:provider/provider.dart';
import '../../../providers/workout_log_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../themes/app_design_tokens.dart';
import '../../../themes/app_spacing.dart';
import '../../widgets/premium_filter_chip.dart';
import '../../widgets/workout_history_entry_card.dart';

class MyWorkoutHistoryScreen extends StatefulWidget {
  const MyWorkoutHistoryScreen({super.key});

  @override
  State<MyWorkoutHistoryScreen> createState() =>
      _MyWorkoutHistoryScreenState();
}

class _MyWorkoutHistoryScreenState extends State<MyWorkoutHistoryScreen> {
  String _filter = 'Today';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWorkoutHistory();
    });
  }

  Future<void> _loadWorkoutHistory() async {
    final auth = context.read<AuthProvider>();
    final logProvider = context.read<WorkoutLogProvider>();
    final memberId = auth.currentUser?.linkedMemberId ?? '';

    if (memberId.isNotEmpty) {
      await logProvider.refreshForMember(memberId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final logProvider = context.watch<WorkoutLogProvider>();

    final memberId = auth.currentUser?.linkedMemberId ?? '';

    List<WorkoutLogModel> history = [];

    switch (_filter) {
      case 'Today':
        history = logProvider.getTodayHistory(memberId);
        break;
      case 'Yesterday':
        history = logProvider.getYesterdayHistory(memberId);
        break;
      case 'Last Week':
        history = logProvider.getLastWeekHistory(memberId);
        break;
      case 'Last Month':
        history = logProvider.getLastMonthHistory(memberId);
        break;
      case 'Custom':
        history =
            logProvider.getHistoryForRange(memberId, _startDate, _endDate);
        break;
      default:
        history = logProvider.getTodayHistory(memberId);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _loadWorkoutHistory,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SizedBox(
            height: 44,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
              child: Row(
                children: const [
                  'Today',
                  'Yesterday',
                  'Last Week',
                  'Last Month',
                  'Custom'
                ].map((f) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: PremiumFilterChip(
                      label: f,
                      isSelected: _filter == f,
                      onTap: () {
                        setState(() {
                          _filter = f;
                          final now = DateTime.now();
                          if (f == 'Today') {
                            _startDate =
                                DateTime(now.year, now.month, now.day);
                            _endDate = DateTime(
                                now.year, now.month, now.day, 23, 59, 59);
                          } else if (f == 'Yesterday') {
                            final yesterday =
                                now.subtract(const Duration(days: 1));
                            _startDate = DateTime(yesterday.year,
                                yesterday.month, yesterday.day);
                            _endDate = DateTime(yesterday.year,
                                yesterday.month, yesterday.day, 23, 59, 59);
                          } else if (f == 'Last Week') {
                            _startDate = now.subtract(const Duration(days: 7));
                            _endDate = DateTime(
                                now.year, now.month, now.day, 23, 59, 59);
                          } else if (f == 'Last Month') {
                            _startDate = now.subtract(const Duration(days: 30));
                            _endDate = DateTime(
                                now.year, now.month, now.day, 23, 59, 59);
                          }
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Date Range Display for Custom filter
          if (_filter == 'Custom')
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'From: ${_startDate.toString().split(' ')[0]}',
                      style: TextStyle(color: context.textSecondary),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'To: ${_endDate.toString().split(' ')[0]}',
                      style: TextStyle(color: context.textSecondary),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today_rounded,
                        color: context.textSecondary),
                    tooltip: 'Pick date range',
                    onPressed: () async {
                      final pickedStart = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now(),
                      );
                      if (pickedStart != null && mounted) {
                        final pickedEnd = await showDatePicker(
                          context: context,
                          initialDate: _endDate,
                          firstDate: pickedStart,
                          lastDate: DateTime.now(),
                        );
                        if (pickedEnd != null && mounted) {
                          setState(() {
                            _startDate = pickedStart;
                            _endDate = pickedEnd;
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppSpacing.xs),

          // History List
          Expanded(
            child: history.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        AppSpacing.xxl),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final log = history[index];
                      final previous =
                          logProvider.getPreviousEntryForExercise(
                              memberId, log.exerciseName, log.date);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: WorkoutHistoryEntryCard(
                          log: log,
                          previousLog: previous,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fitness_center_outlined,
                size: 44,
                color: context.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No workouts logged for $_filter',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Complete a workout to see it here! 💪',
              style: TextStyle(
                fontSize: 13,
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}