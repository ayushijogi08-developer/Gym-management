import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import 'app_shell.dart';

class RoleBasedDashboard extends StatelessWidget {
  const RoleBasedDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    // For now, all roles use the same AppShell (with future role-based menu hiding)
    // Later steps will branch more dashboards
    return const AppShell();
  }
}