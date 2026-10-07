import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_management_app/presentation/widgets/notification_bell_icon.dart';
import 'package:gym_management_app/providers/gym_config_provider.dart';
import 'package:provider/provider.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/payment_provider.dart';
import '../../../providers/attendance_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/theme_toggle_button.dart';

class SuperAdminDashboardContent extends StatefulWidget {
  const SuperAdminDashboardContent({super.key});

  @override
  State<SuperAdminDashboardContent> createState() => _SuperAdminDashboardContentState();
}

class _SuperAdminDashboardContentState extends State<SuperAdminDashboardContent> {
  bool _isLoading = true;
  int _totalMembers = 0;
  int _activeMembers = 0;
  double _totalRevenue = 0;
  int _todayAttendance = 0;


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

 final gymConfigProvider = context.read<GymConfigProvider>();

      // 2. ADD THIS: Load the actual branches
      await gymConfigProvider.loadConfig(forceRefresh: true);


      await memberProvider.loadMembers();
      final members = memberProvider.members;
      _totalMembers = members.length;
      _activeMembers = members.where((m) => m.membershipStatus == 'active').length;

      await paymentProvider.fetchPayments();
      final allPayments = paymentProvider.allPayments;
      _totalRevenue = allPayments.fold(0.0, (sum, p) => sum + p.amount);

      _todayAttendance = attendanceProvider.todaysAttendance.length;
    } catch (e) {
      debugPrint('Error loading super admin data: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: context.background,
        elevation: 0,
        title: Text(
          'Super Admin Portal',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 0.3, color: context.textPrimary),
        ),
        actions: [
          IconButton(icon: Icon(Icons.refresh_rounded), onPressed: _loadData),
          IconButton(icon: Icon(Icons.search), onPressed: () => context.push('/global-search')),
          const NotificationBellIcon(),
          const ThemeToggleButton(),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ---------- HEADER ----------
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 4,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Super Admin Dashboard',
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                        color: context.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Global Overview — All Branches',
                                      style: TextStyle(color: context.textSecondary, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // ---------- KEY METRICS ----------
                          const _SectionTitle('Key Metrics', icon: Icons.bar_chart_rounded),
                          const SizedBox(height: 14),
                          LayoutBuilder(builder: (context, constraints) {
                            final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                            final ratio = constraints.maxWidth > 600 ? 1.75 : 1.3;

                            return GridView.count(
                              crossAxisCount: crossAxisCount,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: ratio,
                              children: [
                                _PremiumStatCard(
                                  label: 'Total Branches',
                                 value: context.read<GymConfigProvider>().config?.branches.length.toString() ?? '0',
                                  icon: Icons.business_rounded,
                                  color: AppColors.primary,
                                ),
                                _PremiumStatCard(
                                  label: 'Active Members',
                                  value: _activeMembers.toString(),
                                  icon: Icons.groups_rounded,
                                  color: AppColors.accent,
                                ),
                                _PremiumStatCard(
                                  label: 'Total Revenue',
                                  value: '₹${_totalRevenue.toStringAsFixed(0)}',
                                  icon: Icons.account_balance_wallet_rounded,
                                  color: AppColors.success,
                                ),
                                _PremiumStatCard(
                                  label: "Today's Attendance",
                                  value: _todayAttendance.toString(),
                                  icon: Icons.how_to_reg_rounded,
                                  color: AppColors.secondary,
                                ),
                              ],
                            );
                          }),
                          const SizedBox(height: 32),

                          // ---------- MANAGEMENT SHORTCUTS ----------
                          const _SectionTitle('Management Shortcuts', icon: Icons.grid_view_rounded),
                          const SizedBox(height: 14),
                          LayoutBuilder(builder: (context, constraints) {
                            final crossAxisCount =
                                constraints.maxWidth >= 1100 ? 4 : (constraints.maxWidth >= 700 ? 3 : 2);
                            // Loosened so the icon + 2-line subtitle
                            // have enough vertical room on narrow screens.
                            final ratio = constraints.maxWidth >= 1100
                                ? 1.5
                                : (constraints.maxWidth >= 700 ? 1.3 : 1.05);

                            return GridView.count(
                              crossAxisCount: crossAxisCount,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: ratio,
                              children: [
                                _ManagementCard(
                                  icon: Icons.people_outline_rounded,
                                  iconColor: const Color(0xFF3B82F6),
                                  title: 'User Management',
                                  subtitle: 'Manage all users & permissions',
                                  onTap: () => context.push('/admin-user-management'),
                                ),
                                _ManagementCard(
                                  icon: Icons.flag_rounded,
                                  iconColor: const Color(0xFFA855F7),
                                  title: 'Member Goals',
                                  subtitle: 'Track progress & goals',
                                  onTap: () => context.push('/all-member-goals'),
                                ),
                                _ManagementCard(
                                  icon: Icons.analytics_rounded,
                                  iconColor: const Color(0xFF14B8A6),
                                  title: 'Reports',
                                  subtitle: 'Revenue & growth analytics',
                                  onTap: () => context.push('/reports'),
                                ),
                                _ManagementCard(
                                  icon: Icons.restaurant_menu_rounded,
                                  iconColor: const Color(0xFFFB923C),
                                  title: 'Diet Plans',
                                  subtitle: 'Configure diet programs',
                                  onTap: () => context.push('/diet-plans'),
                                ),
                                _ManagementCard(
                                  icon: Icons.how_to_reg_rounded,
                                  iconColor: const Color(0xFF2DD4BF),
                                  title: 'Attendance',
                                  subtitle: 'Daily check-ins overview',
                                  onTap: () => context.push('/admin-attendance'),
                                ),
                              ],
                            );
                          }),
                          const SizedBox(height: 32),

                          // ---------- BRANCH OVERVIEW ----------
                          const _SectionTitle('Branch Overview', icon: Icons.store_rounded),
                          const SizedBox(height: 14),
                          _buildInfoCard(
                            totalMembers: _totalMembers,
                            activeMembers: _activeMembers,
                            revenue: _totalRevenue,
                          ),
                          const SizedBox(height: 24),

                          // ---------- ADMIN TOOLS ----------
                          const _SectionTitle('Admin Tools', icon: Icons.admin_panel_settings_rounded),
                          const SizedBox(height: 14),
                          _buildNavigationTile(
                            context,
                            icon: Icons.admin_panel_settings_rounded,
                            title: 'Admin Management',
                            subtitle: 'Manage other admins',
                            route: '/admin-management',
                          ),
                          const SizedBox(height: 12),
                          _buildNavigationTile(
                            context,
                            icon: Icons.people_outline_rounded,
                            title: 'User Management',
                            subtitle: 'Manage all users and permissions',
                            route: '/admin-user-management',
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInfoCard({
    required int totalMembers,
    required int activeMembers,
    required double revenue,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child: _branchStat('Total Members', totalMembers.toString(), Icons.people_rounded, AppColors.primary),
          ),
          Container(width: 1, height: 40, color: context.border),
          Expanded(
            child: _branchStat('Active', activeMembers.toString(), Icons.verified_rounded, AppColors.success),
          ),
          Container(width: 1, height: 40, color: context.border),
          Expanded(
            child: _branchStat('Revenue', '₹${revenue.toStringAsFixed(0)}', Icons.payments_rounded, AppColors.accent),
          ),
        ],
      ),
    );
  }

  Widget _branchStat(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 6),
        FittedBox(
          child: Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textPrimary),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 10.5, color: context.textSecondary),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildNavigationTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push(route),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: context.textSecondary, fontSize: 11.5, height: 1.3),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: context.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- SECTION TITLE ----------
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle(this.title, {required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.textPrimary, letterSpacing: 0.2),
        ),
      ],
    );
  }
}

// ---------- PREMIUM STAT CARD ----------
class _PremiumStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _PremiumStatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 14, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.3, color: context.textPrimary),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: context.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- MANAGEMENT CARD ----------
class _ManagementCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ManagementCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 1),
                  boxShadow: [
                    BoxShadow(color: iconColor.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Icon(icon, size: 24, color: iconColor),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 13, color: context.textSecondary),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: context.textSecondary, fontSize: 11, height: 1.3),
          ),
        ],
      ),
    );
  }
}