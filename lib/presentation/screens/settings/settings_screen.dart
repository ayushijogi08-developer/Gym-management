import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_management_app/domain/entities/user_role.dart';
import 'package:gym_management_app/routes/app_routes.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isReceptionist = auth.currentRole == UserRole.receptionist;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassContainer(
            child: Column(
              children: [
                // Only show management options if NOT a receptionist
                if (!isReceptionist) ...[
                  _SettingsTile(
                    icon: Icons.card_membership,
                    title: 'Membership Plans',
                    subtitle: 'Manage plans & pricing',
                    onTap: () => context.push('/plans'),
                  ),
                  Divider(color: context.border),
                  _SettingsTile(
                    icon: Icons.fitness_center,
                    title: 'Manage Trainers',
                    subtitle: 'Add & assign trainers',
                    onTap: () => context.push('/trainers'),
                  ),
                ],

                if (auth.hasPermission('canCollectPayments')) ...[
                  Divider(color: context.border),
                  _SettingsTile(
                    icon: Icons.payment,
                    title: 'Payments',
                    subtitle: 'View and manage payments',
                    onTap: () => context.push('/payments'),
                  ),
                ],
                ListTile(
                  leading: Icon(Icons.lock_reset,
                      color: scheme.tertiary),
                  title: const Text('Change Password'),
                  subtitle: const Text('Update your login password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.changePassword),
                ),

                // Super Admin only (Permissions check)
                if (auth.hasPermission('canManageAdmins') &&
                    !isReceptionist) ...[
                  Divider(color: context.border),
                  _SettingsTile(
                    icon: Icons.admin_panel_settings,
                    title: 'Admin Management',
                    subtitle: 'Manage other admins',
                    onTap: () => context.push('/admin-management'),
                  ),
                ],
                if (auth.currentRole == UserRole.superAdmin) ...[
                  Divider(color: context.border),
                  _SettingsTile(
                    icon: Icons.store_outlined,
                    title: 'Branch Management',
                    subtitle: 'Add, edit, or remove branches',
                    onTap: () => context.push('/branch-management'),
                  ),
                ],
                if (!isReceptionist) ...[
                  Divider(color: context.border),
                  _SettingsTile(
                    icon: Icons.backup_outlined,
                    title: 'Backup & Restore',
                    subtitle: 'Export or restore all gym data',
                    onTap: () => context.push('/backup-restore'),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 32),

          // LOGOUT SECTION
          GlassContainer(
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                leading: Icon(Icons.logout_rounded, color: scheme.error),
                title: Text(
                  'Logout',
                  style: TextStyle(
                      color: scheme.error, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Sign out of your account',
                  style: TextStyle(color: context.textSecondary),
                ),
                onTap: () => _confirmLogout(context),
              ),
            ),
          ),

          const SizedBox(height: 40),
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: context.textMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout?'),
        content: const Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
              _performLogout(context);
            },
            child: Text('Logout', style: TextStyle(color: scheme.error)),
          ),
        ],
      ),
    );
  }

  void _performLogout(BuildContext context) {
    context.read<AuthProvider>().logout(context);
    // Reset navigation stack and go to login
    context.go(AppRoutes.login);
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle,
            style: TextStyle(color: context.textSecondary)),
        trailing: Icon(Icons.chevron_right, color: context.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
