import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/gradient_button.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isChangingPassword = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty) {
      return;
    }

    setState(() => _isChangingPassword = true);

    // In real implementation, verify old password and hash new one
    final success =
        await Future.delayed(const Duration(seconds: 1), () => true);

    if (!mounted) return;
    setState(() => _isChangingPassword = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );
      _oldPasswordController.clear();
      _newPasswordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Account Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Logged in as',
                style: TextStyle(color: context.textSecondary)),
            Text(auth.currentUser?.name ?? 'User',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 32),

            Text('Change Password',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Current Password',
              hint: '••••••••',
              controller: _oldPasswordController,
              isPassword: true,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'New Password',
              hint: '••••••••',
              controller: _newPasswordController,
              isPassword: true,
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Update Password',
              isLoading: _isChangingPassword,
              onPressed: _changePassword,
            ),

            const SizedBox(height: 48),
            ListTile(
              leading: Icon(Icons.logout, color: scheme.error),
              title: Text('Logout',
                  style: TextStyle(color: scheme.error)),
              onTap: () {
                context.read<AuthProvider>().logout(context);
                context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
