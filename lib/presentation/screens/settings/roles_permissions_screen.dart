import 'package:flutter/material.dart';
import '../../../domain/entities/user_role.dart';
import '../../../utils/permissions.dart';
import '../../../themes/app_colors.dart';

class RolesPermissionsScreen extends StatelessWidget {
  const RolesPermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Roles & Permissions')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: UserRole.values.map((role) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              title: Text(role.label, style: const TextStyle(fontWeight: FontWeight.bold)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: Permissions.rolePermissions[role]!
                        .map((perm) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.check, color: AppColors.success, size: 18),
                                  const SizedBox(width: 12),
                                  Text(perm),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}