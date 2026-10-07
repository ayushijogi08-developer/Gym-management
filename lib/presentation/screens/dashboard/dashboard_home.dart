
import 'package:flutter/material.dart';
import 'package:gym_management_app/domain/entities/user_role.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import 'super_admin_dashboard_content.dart';
import 'admin_dashboard_content.dart';
import 'receptionist_dashboard_content.dart'; // ← New
import 'trainer_dashboard_content.dart';
import 'member_dashboard_content.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.currentRole) {
  case UserRole.superAdmin:
    return const SuperAdminDashboardContent();
  case UserRole.admin:
    return const AdminDashboardContent();
  case UserRole.receptionist:
    return const ReceptionistDashboardContent();
  case UserRole.trainer:
    return const TrainerDashboardContent();
    case UserRole.member: // NEW
        return const MemberDashboardContent();
  default:
    return const AdminDashboardContent(); // fallback
}
  }
}