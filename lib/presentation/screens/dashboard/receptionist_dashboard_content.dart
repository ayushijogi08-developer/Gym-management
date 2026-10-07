import 'package:flutter/material.dart';
import 'package:gym_management_app/presentation/screens/dashboard/app_shell.dart';
import 'package:gym_management_app/presentation/widgets/notification_bell_icon.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/attendance_provider.dart';
import '../../../providers/payment_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/theme_toggle_button.dart';
import '../members/add_edit_member_screen.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/route_helper.dart';

class ReceptionistDashboardContent extends StatefulWidget {
  const ReceptionistDashboardContent({super.key});

  @override
  State<ReceptionistDashboardContent> createState() =>
      _ReceptionistDashboardContentState();
}

class _ReceptionistDashboardContentState
    extends State<ReceptionistDashboardContent> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final paymentProvider = context.read<PaymentProvider>();
    await paymentProvider.fetchPayments();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final memberProvider = context.watch<MemberProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();
    final paymentProvider = context.watch<PaymentProvider>();
    final auth = context.watch<AuthProvider>();

    final todayCheckIns = attendanceProvider.todaysAttendance.length;

    final now = DateTime.now();
    final newRegistrations = memberProvider.members.where((m) {
      return m.joiningDate.year == now.year &&
          m.joiningDate.month == now.month &&
          m.joiningDate.day == now.day;
    }).length;

    final todayPayments = paymentProvider.getTodayPayments();
    final totalTodayPayments = paymentProvider.getTodayTotal();
    final todayPaymentCount = todayPayments.length;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 600;
    final isMedium = screenWidth >= 600 && screenWidth < 900;
    final statsColumns = isSmall ? 2 : (isMedium ? 2 : 4);
    final quickCols = isSmall ? 2 : (isMedium ? 3 : 4);

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        title: const Text(
          'Receptionist Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: context.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/global-search'),
          ),
          const NotificationBellIcon(),
          const ThemeToggleButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---------- HEADER ----------
                        Row(
                          children: [
                            CircleAvatar(
                              radius: isSmall ? 24 : 28,
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.2),
                              child: Text(
                                auth.currentUser?.name.isNotEmpty == true
                                    ? auth.currentUser!.name[0].toUpperCase()
                                    : 'R',
                                style: TextStyle(
                                  fontSize: isSmall ? 20 : 24,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hi, ${auth.currentUser?.name ?? 'Receptionist'}',
                                    style: TextStyle(
                                      fontSize: isSmall ? 17 : 20,
                                      fontWeight: FontWeight.bold,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Welcome to your dashboard',
                                    style: TextStyle(
                                      color: context.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.lock_reset,
                                color: AppColors.primary,
                                size: 22,
                              ),
                              onPressed: () =>
                                  context.push(AppRoutes.changePassword),
                              tooltip: 'Change Password',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ---------- STATS ----------
                        Text(
                          'Today',
                          style: TextStyle(
                            fontSize: isSmall ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GridView.count(
                          crossAxisCount: statsColumns,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: isSmall ? 1.6 : 1.8,
                          children: [
                            _buildSmallStatCard(
                              label: "Check-ins",
                              value: todayCheckIns.toString(),
                              icon: Icons.how_to_reg,
                              iconColor: AppColors.success,
                            ),
                            _buildSmallStatCard(
                              label: "New Members",
                              value: newRegistrations.toString(),
                              icon: Icons.person_add,
                              iconColor: AppColors.primary,
                            ),
                            _buildSmallStatCard(
                              label: "Payments",
                              value: todayPaymentCount.toString(),
                              icon: Icons.payment,
                              iconColor: AppColors.accent,
                            ),
                            _buildSmallStatCard(
                              label: "Amount",
                              value: "₹${totalTodayPayments.toStringAsFixed(0)}",
                              icon: Icons.currency_rupee,
                              iconColor: AppColors.success,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ---------- QUICK ACTIONS ----------
                        Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: isSmall ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GridView.count(
                          crossAxisCount: quickCols,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: isSmall ? 1.2 : 1.4,
                          children: [
                            _quickTile(
                              icon: Icons.person_add,
                              iconColor: AppColors.primary,
                              title: 'Register Member',
                              subtitle: 'Add new member',
                              onTap: () => Navigator.push(
                                context,
                                buildAppRoute(const AddEditMemberScreen()),
                              ),
                            ),
                            _quickTile(
                              icon: Icons.qr_code_scanner,
                              iconColor: AppColors.primary,
                              title: 'Scan QR',
                              subtitle: 'Check-in',
                              onTap: () {
                                context.go(AppRoutes.dashboard);
                                Future.delayed(
                                  const Duration(milliseconds: 300),
                                  () {
                                    final shellState =
                                        context.findAncestorStateOfType<
                                            AppShellState>();
                                    shellState?.setSelectedIndex(2);
                                  },
                                );
                              },
                            ),
                            _quickTile(
                              icon: Icons.payment,
                              iconColor: AppColors.accent,
                              title: 'Record Payment',
                              subtitle: 'Collect dues',
                              onTap: () => context.push('/record-payment'),
                            ),
                            _quickTile(
                              icon: Icons.search,
                              iconColor: AppColors.primary,
                              title: 'Search Members',
                              subtitle: 'Quick lookup',
                              onTap: () => context.go(AppRoutes.members),
                            ),
                            _quickTile(
                              icon: Icons.lock_reset,
                              iconColor: Colors.amber,
                              title: 'Reset Password',
                              subtitle: 'Help with login',
                              onTap: () => context.go(AppRoutes.members),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            'Handle arrivals, payments and member support smoothly.',
                            style: TextStyle(
                              fontSize: isSmall ? 12 : 14,
                              color: context.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ✅ Custom small stat card to prevent overflow
  Widget _buildSmallStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: iconColor),
                const SizedBox(width: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GlassContainer(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: context.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}