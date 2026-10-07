import 'package:flutter/material.dart';
import 'package:gym_management_app/domain/entities/user_role.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/nav_items.dart';
import 'admin_dashboard_content.dart';
import 'member_dashboard_content.dart';
import 'receptionist_dashboard_content.dart';
import 'super_admin_dashboard_content.dart';
import 'trainer_dashboard_content.dart';
import '../members/member_list_screen.dart';
import '../attendance/admin_attendance_screen.dart';
import '../scanner/scanner_screen.dart';
import '../settings/settings_screen.dart';

/// Responsive shell:
///
/// * ≥900px wide  → side NavigationRail (always-visible, premium feel)
/// * <900px wide  → bottom NavigationBar (thumb-friendly on phones)
///
/// Tabs are role-specific but the five items below are used by every role.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  void setSelectedIndex(int index) {
    setState(() => _selectedIndex = index);
  }

  static const _kRailBreakpoint = 900.0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.currentRole;
    final tabs = _tabsFor(role);
    final isWide = MediaQuery.of(context).size.width >= _kRailBreakpoint;

    if (isWide) {
      return _RailShell(
        tabs: tabs,
        selectedIndex: _selectedIndex,
        onSelect: (i) => setState(() => _selectedIndex = i),
      );
    }
    return _BottomNavShell(
      tabs: tabs,
      selectedIndex: _selectedIndex,
      onSelect: (i) => setState(() => _selectedIndex = i),
    );
  }

  List<_Tab> _tabsFor(UserRole role) {
    final dashboard = switch (role) {
      UserRole.superAdmin => const SuperAdminDashboardContent(),
      UserRole.admin => const AdminDashboardContent(),
      UserRole.receptionist => const ReceptionistDashboardContent(),
      UserRole.trainer => const TrainerDashboardContent(),
      UserRole.member => const MemberDashboardContent(),
    };

    return [
      _Tab(label: 'Dashboard', screen: dashboard),
      _Tab(label: 'Members', screen: const MemberListScreen()),
      _Tab(label: 'Scanner', screen: const ScannerScreen()),
      _Tab(label: 'Attendance', screen: const AdminAttendanceScreen()),
      _Tab(label: 'Settings', screen: const SettingsScreen()),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared tab model
// ─────────────────────────────────────────────────────────────────────────────

class _Tab {
  final String label;
  final Widget screen;
  const _Tab({required this.label, required this.screen});
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom nav shell (mobile / narrow)
// ─────────────────────────────────────────────────────────────────────────────

class _BottomNavShell extends StatelessWidget {
  final List<_Tab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  const _BottomNavShell({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: selectedIndex,
          children: tabs.map((t) => t.screen).toList(),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelect,
        height: 68,
        destinations: [
          for (var i = 0; i < tabs.length; i++)
            NavigationDestination(
              icon: Icon(mainNavItems[i].icon),
              selectedIcon: Icon(mainNavItems[i].selectedIcon),
              label: tabs[i].label,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Side rail shell (tablet / desktop)
// ─────────────────────────────────────────────────────────────────────────────

class _RailShell extends StatelessWidget {
  final List<_Tab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  const _RailShell({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final branding = Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fitness_center,
                color: Colors.white, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            'Gym',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onSelect,
            labelType: NavigationRailLabelType.all,
            leading: branding,
            destinations: [
              for (var i = 0; i < tabs.length; i++)
                NavigationRailDestination(
                  icon: Icon(mainNavItems[i].icon),
                  selectedIcon: Icon(mainNavItems[i].selectedIcon),
                  label: Text(tabs[i].label),
                ),
            ],
          ),
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: scheme.outline,
          ),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: tabs.map((t) => t.screen).toList(),
            ),
          ),
        ],
      ),
    );
  }
}