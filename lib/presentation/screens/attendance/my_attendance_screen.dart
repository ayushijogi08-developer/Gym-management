import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/attendance_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../themes/app_design_tokens.dart';
import '../../../themes/app_spacing.dart';
import '../../widgets/attendance/attendance_calendar_view.dart';
import '../../widgets/attendance/attendance_stat_strip.dart';

class MyAttendanceScreen extends StatefulWidget {
  final String memberId;

  const MyAttendanceScreen({
    super.key,
    required this.memberId,
  });

  @override
  State<MyAttendanceScreen> createState() => _MyAttendanceScreenState();
}

class _MyAttendanceScreenState extends State<MyAttendanceScreen> {
  String _viewMode = 'Calendar';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();

    final memberId = auth.currentUser?.linkedMemberId ?? '';

    final totalVisits = attendanceProvider.totalVisits(memberId);
    final currentStreak = attendanceProvider.currentStreak(memberId);
    final longestStreak = attendanceProvider.longestStreak(memberId);
    final missedThisMonth =
        attendanceProvider.daysWithoutVisitThisMonth(memberId);

    return Scaffold(
      appBar: AppBar(title: const Text('My Attendance')),
      body: Column(
        children: [
          AttendanceStatStrip(
            totalVisits: totalVisits,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            missedDaysThisMonth: missedThisMonth,
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'Calendar',
                  label: Text('Calendar'),
                  icon: Icon(Icons.calendar_today_rounded),
                ),
                ButtonSegment(
                  value: 'Monthly',
                  label: Text('Monthly'),
                  icon: Icon(Icons.calendar_view_month_rounded),
                ),
                ButtonSegment(
                  value: 'Weekly',
                  label: Text('Weekly'),
                  icon: Icon(Icons.calendar_view_week_rounded),
                ),
              ],
              selected: {_viewMode},
              onSelectionChanged: (set) =>
                  setState(() => _viewMode = set.first),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _viewMode == 'Calendar'
                ? AttendanceCalendarView(
                    memberId: memberId,
                    attendanceProvider: attendanceProvider,
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: context.surfaceAlt,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.calendar_month_outlined,
                              size: 36,
                              color: context.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            '$_viewMode view',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Coming soon',
                            style: TextStyle(
                                fontSize: 13, color: context.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
