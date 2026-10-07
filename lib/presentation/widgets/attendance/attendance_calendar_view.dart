import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../providers/attendance_provider.dart';
import '../../../themes/app_colors.dart';

class AttendanceCalendarView extends StatelessWidget {
  final String memberId;
  final AttendanceProvider attendanceProvider;

  const AttendanceCalendarView({
    super.key,
    required this.memberId,
    required this.attendanceProvider,
  });

  @override
  Widget build(BuildContext context) {
    final focusedDay = DateTime.now();
    final checkInDays = attendanceProvider.allAttendance
        .where((a) => a.memberId == memberId)
        .map((a) => DateTime(a.timestamp.year, a.timestamp.month, a.timestamp.day))
        .toSet();

    return TableCalendar(
      firstDay: DateTime(2024),
      lastDay: DateTime.now().add(const Duration(days: 30)),
      focusedDay: focusedDay,
      calendarFormat: CalendarFormat.month,
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekendStyle: TextStyle(color: Colors.redAccent),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        markerDecoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
      ),
      eventLoader: (day) {
        return checkInDays.contains(day) ? [true] : [];
      },
    );
  }
}