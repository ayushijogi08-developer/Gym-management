import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/attendance_provider.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/payment_provider.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final memberProvider = context.read<MemberProvider>();
      final paymentProvider = context.read<PaymentProvider>();
      final attendanceProvider = context.read<AttendanceProvider>();

      await Future.wait([
        memberProvider.loadMembers(),
        paymentProvider.fetchPayments(),
        attendanceProvider.fetchAllAttendance(),
      ]);
    } catch (e) {
      print('Error loading report data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final memberProvider = context.watch<MemberProvider>();
    final paymentProvider = context.watch<PaymentProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();
    final scheme = Theme.of(context).colorScheme;

    // Calculate real data
    final totalMembers = memberProvider.members.length;
    final activeMembers = memberProvider.members
        .where((m) => m.membershipStatus == 'active')
        .length;

    final totalRevenue =
        paymentProvider.allPayments.fold(0.0, (sum, p) => sum + p.amount);
    final todayPayments = paymentProvider.getTodayPayments();
    final todayRevenue = todayPayments.fold(0.0, (sum, p) => sum + p.amount);
    // todayRevenue surfaces in the growth/today card if/when added; kept for
    // parity with the original report.
    // ignore: unused_local_variable
    final _ = todayRevenue;

    final todayAttendance = attendanceProvider.allRecords.where((a) {
      final now = DateTime.now();
      return a.timestamp.year == now.year &&
          a.timestamp.month == now.month &&
          a.timestamp.day == now.day;
    }).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio:
                        constraints.maxWidth >= 700 ? 1.2 : 0.95,
                    children: [
                      _buildReportCard(
                        context,
                        title: 'Revenue',
                        subtitle: '₹${totalRevenue.toInt()} total',
                        icon: Icons.currency_rupee,
                        color: scheme.tertiary,
                        onTap: () => context.push('/revenue-report'),
                      ),
                      _buildReportCard(
                        context,
                        title: 'Attendance',
                        subtitle: '$todayAttendance check-ins today',
                        icon: Icons.calendar_today,
                        color: scheme.primary,
                        onTap: () => context.push('/attendance-report'),
                      ),
                      _buildReportCard(
                        context,
                        title: 'Membership',
                        subtitle: '$activeMembers active members',
                        icon: Icons.card_membership,
                        color: scheme.secondary,
                        onTap: () => context.push('/membership-report'),
                      ),
                      _buildReportCard(
                        context,
                        title: 'Growth',
                        subtitle: '$totalMembers total members',
                        icon: Icons.trending_up,
                        color: context.accent,
                        onTap: () => context.push('/growth-report'),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlassContainer(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
