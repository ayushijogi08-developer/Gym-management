import 'package:flutter/material.dart';

/// Shared nav item definition used by both bottom nav (mobile) and
/// nav rail (tablet/desktop) so they never fall out of sync.
class NavItemData {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const NavItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

const List<NavItemData> mainNavItems = [
  NavItemData(
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard_rounded,
    label: 'Dashboard',
  ),
  NavItemData(
    icon: Icons.people_outline,
    selectedIcon: Icons.people_rounded,
    label: 'Members',
  ),
  NavItemData(
    icon: Icons.qr_code_scanner_outlined,
    selectedIcon: Icons.qr_code_scanner_rounded,
    label: 'Scanner',
  ),
  NavItemData(
    icon: Icons.calendar_today_outlined,
    selectedIcon: Icons.calendar_today_rounded,
    label: 'Attendance',
  ),
  NavItemData(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
    label: 'Settings',
  ),
];