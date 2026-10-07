import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if new password and confirm password match
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = '❌ New password and confirm password do not match';
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final auth = context.read<AuthProvider>();

    try {
      final success = await auth.changePassword(
        _currentPasswordController.text.trim(),
        _newPasswordController.text.trim(),
      );

      if (!mounted) return;

      setState(() => _loading = false);

      if (success) {
        setState(() {
          _successMessage = '✅ Password changed successfully!';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Password changed successfully'),
            backgroundColor: context.success,
          ),
        );

        // Navigate to dashboard after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.go(AppRoutes.dashboard);
          }
        });
      } else {
        setState(() {
          _errorMessage = '❌ Unable to change password. Please check your current password.';
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = '❌ Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final successColor = context.success;
    final errorColor = context.danger;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Change Password'),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.lock_reset,
                          size: 70,
                          color: context.primary,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Change Password',
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Update your password for security',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.textSecondary),
                        ),
                        const SizedBox(height: 30),

                        // Success Message
                        if (_successMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: successColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: successColor),
                            ),
                            child: Text(
                              _successMessage!,
                              style: TextStyle(color: successColor),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // Error Message
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: errorColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: errorColor),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: errorColor),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // Current Password
                        AppTextField(
                          label: 'Current Password',
                          controller: _currentPasswordController,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Current password is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // New Password
                        AppTextField(
                          label: 'New Password (min 6 characters)',
                          controller: _newPasswordController,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'New password is required';
                            }
                            if (value.length < 6) {
                              return 'Minimum 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Confirm Password
                        AppTextField(
                          label: 'Confirm Password',
                          controller: _confirmPasswordController,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _newPasswordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),

                        GradientButton(
                          label: 'Update Password',
                          isLoading: _loading,
                          onPressed: _changePassword,
                        ),

                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.dashboard),
                          child: const Text('Skip for now'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
