import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/app_empty_state.dart';
import 'add_edit_admin_screen.dart';
import '../../../data/models/app_user_model.dart';

class AdminManagementScreen extends StatelessWidget {
  const AdminManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final scheme = Theme.of(context).colorScheme;

    // Fetch both Admins and Receptionists
    // We fetch all users and filter on the frontend to avoid API clashes
    final Future<List<AppUserModel>> staffUsers = auth
        .getUsersByRole('admin')
        .then((admins) async {
      final receptionists = await auth.getUsersByRole('receptionist');
      return [...admins, ...receptionists];
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add),
        label: const Text('Add Staff'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditAdminScreen()),
        ),
      ),
      body: FutureBuilder<List<AppUserModel>>(
        future: staffUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final staffList = snapshot.data ?? [];

          return staffList.isEmpty
              ? const AppEmptyState(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'No Staff Yet',
                  subtitle:
                      'Add an admin or receptionist to delegate management access.',
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth >= 1100
                        ? 3
                        : (constraints.maxWidth >= 700 ? 2 : 1);
                    return GridView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: staffList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 3.2,
                      ),
                      itemBuilder: (context, index) {
                        final staff = staffList[index];

                        // Define colors based on role for better UI clarity
                        Color avatarColor;
                        IconData roleIcon;
                        if (staff.role == 'admin') {
                          avatarColor =
                              scheme.primary.withValues(alpha: 0.16);
                          roleIcon = Icons.shield_outlined;
                        } else {
                          avatarColor = context.warning
                              .withValues(alpha: 0.16);
                          roleIcon =
                              Icons.person_pin_circle_outlined;
                        }

                        return GlassContainer(
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: avatarColor,
                                child: Text(
                                  staff.name.isNotEmpty
                                      ? staff.name[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: staff.role == 'admin'
                                        ? scheme.primary
                                        : context.warning,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Icon(roleIcon,
                                      size: 16,
                                      color: context.textSecondary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      staff.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    staff.email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: context.textSecondary,
                                        fontSize: 13),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: staff.role == 'admin'
                                          ? scheme.primary
                                              .withValues(alpha: 0.16)
                                          : context.warning
                                              .withValues(alpha: 0.16),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      staff.role.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: staff.role == 'admin'
                                            ? scheme.primary
                                            : context.warning,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete_outline,
                                    color: scheme.error),
                                onPressed: () => _confirmDelete(
                                    context, staff.id, staff.name),
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AddEditAdminScreen(existingUser: staff),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String userId, String userName) {
    final scheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Staff?'),
        content: Text(
          'This will permanently remove $userName\'s access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: context.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().deleteUser(userId);
              Navigator.pop(ctx);
            },
            child: Text('Delete', style: TextStyle(color: scheme.error)),
          ),
        ],
      ),
    );
  }
}
