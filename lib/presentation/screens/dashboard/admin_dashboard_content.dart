import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_dashboard_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/notification_bell_icon.dart';
import '../../widgets/theme_toggle_button.dart';

class AdminDashboardContent extends StatefulWidget {
  const AdminDashboardContent({super.key});
  @override
  State<AdminDashboardContent> createState() => _AdminDashboardContentState();
}

class _AdminDashboardContentState extends State<AdminDashboardContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardProvider>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    int gridColumns;
    if (screenWidth < 600) {
      gridColumns = 1;
    } else if (screenWidth < 1024) {
      gridColumns = 2;
    } else {
      gridColumns = 4;
    }

    final mgmtColumns = screenWidth < 600 ? 2 : (screenWidth < 1024 ? 2 : 3);

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: context.background,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.3,
            color: context.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'Global Search',
            onPressed: () => context.push('/global-search'),
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Data',
            onPressed: provider.refresh,
          ),
          const NotificationBellIcon(),
          const ThemeToggleButton(),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: provider.refresh,
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
                    // Wrap the title + summary chip row in a horizontal
                    // scroll view so the chip never forces the title to
                    // ellipsize awkwardly on narrow screens.
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _HeaderTitle(isLoading: provider.isLoading),
                          const SizedBox(width: 12),
                          _TodaySummaryChip(
                            totalMembers: provider.totalMembersCount,
                            attendanceToday: provider.attendanceTodayCount,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ---------- KEY METRICS ----------
                    const _SectionTitle('Key Metrics', icon: Icons.bar_chart_rounded),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: gridColumns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio:
                          gridColumns == 4 ? 1.75 : (gridColumns == 2 ? 1.6 : 2.4),
                      children: [
                        _PremiumStatCard(
                          label: "Today's New Members",
                          value: provider.todaysMembersCount.toString(),
                          icon: Icons.person_add_rounded,
                          color: AppColors.primary,
                        ),
                        _PremiumStatCard(
                          label: "Active Memberships",
                          value: provider.activeMembershipsCount.toString(),
                          icon: Icons.verified_user_rounded,
                          color: AppColors.success,
                        ),
                        _PremiumStatCard(
                          label: "Total Revenue",
                          value: currencyFormatter.format(provider.totalRevenue),
                          icon: Icons.currency_rupee_rounded,
                          color: AppColors.accent,
                        ),
                        _PremiumStatCard(
                          label: "Attendance Today",
                          value: provider.attendanceTodayCount.toString(),
                          icon: Icons.how_to_reg_rounded,
                          color: AppColors.secondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ---------- MANAGEMENT SHORTCUTS ----------
                    const _SectionTitle('Management', icon: Icons.grid_view_rounded),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: mgmtColumns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      // Loosened to give the icon + 2-line subtitle enough
                      // vertical room on narrow screens. 1.05 ≈ 14px of
                      // headroom per row of 148×141 content, eliminating
                      // the 2.3px bottom RenderFlex overflow.
                      childAspectRatio: mgmtColumns == 3 ? 1.3 : 1.05,
                      children: [
                        _ManagementCard(
                          icon: Icons.people_alt_rounded,
                          iconColor: const Color(0xFF3B82F6),
                          title: 'Members & Plans',
                          subtitle: 'View and manage members',
                          onTap: () => context.push('/members'),
                        ),
                        _ManagementCard(
                          icon: Icons.restaurant_menu_rounded,
                          iconColor: AppColors.primary,
                          title: 'Diet Plans',
                          subtitle: 'Configure diet programs',
                          onTap: () => context.push('/diet-plans'),
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
                          icon: Icons.how_to_reg_rounded,
                          iconColor: const Color(0xFF2DD4BF),
                          title: 'Attendance',
                          subtitle: 'Daily check-ins overview',
                          onTap: () => context.push('/admin-attendance'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ---------- QUICK ACTIONS ----------
                    const _SectionTitle('Quick Actions', icon: Icons.bolt_rounded),
                    const SizedBox(height: 14),
                    _QuickActionsRow(screenWidth: screenWidth),
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
}

// ---------- HEADER ----------
class _HeaderTitle extends StatelessWidget {
  final bool isLoading;
  const _HeaderTitle({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      'Dashboard Overview',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: context.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isLoading) ...[
                    const SizedBox(width: 10),
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Key metrics & management tools',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodaySummaryChip extends StatelessWidget {
  final int totalMembers;
  final int attendanceToday;
  const _TodaySummaryChip({required this.totalMembers, required this.attendanceToday});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.groups_rounded, size: 16, color: context.textSecondary),
          const SizedBox(width: 8),
          Text(
            '$totalMembers · $attendanceToday today',
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
            letterSpacing: 0.2,
          ),
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
  const _PremiumStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

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
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                      color: context.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: context.textSecondary,
                  ),
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

// ---------- MANAGEMENT CARD (overflow fixed) ----------
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
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
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
            style: TextStyle(
              color: context.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- QUICK ACTIONS ----------
class _QuickActionsRow extends StatelessWidget {
  final double screenWidth;
  const _QuickActionsRow({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = screenWidth < 520 ? double.infinity : 240;
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        _GradientActionButton(
          width: buttonWidth,
          icon: Icons.payment_rounded,
          label: 'Record Payment',
          onPressed: () => context.push('/record-payment'),
        ),
        _GradientActionButton(
          width: buttonWidth,
          icon: Icons.person_add_alt_1_rounded,
          label: 'Add New Member',
          onPressed: () => context.push('/add-edit-member'),
        ),
      ],
    );
  }
}

class _GradientActionButton extends StatelessWidget {
  final double width;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const _GradientActionButton({
    required this.width,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 19),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
