import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/gradient_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  final authProvider = context.read<AuthProvider>();

  final success = await authProvider.login(
    _emailController.text.trim(),
    _passwordController.text,
  );

  if (!mounted) return;

  setState(() => _isLoading = false);

if (success) {

  if(authProvider.currentUser!.mustChangePassword){

      context.replace(AppRoutes.changePassword);

  }else{

      context.replace(AppRoutes.dashboard);

  }

} else {

  setState(() {

    _errorMessage = 'Invalid email or password';

  });

}
}

  @override
  Widget build(BuildContext context) {
    // Resolve the active palette once per build so the entire screen
    // tracks light/dark mode without per-widget lookups.
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Icon(
                      Icons.fitness_center_rounded,
                      color: scheme.primary,
                      size: 64,
                    ).animate().fadeIn().scale(),
                    const SizedBox(height: 24),
                    const Text(
                      'Welcome Back',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Sign in to continue',
                      style: TextStyle(color: context.textSecondary),
                    ),

                    const SizedBox(height: 32),
                    GlassContainer(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          AppTextField(
                            label: 'Email',
                            hint: 'admin@gym.com',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v!.contains('@') ? null : 'Valid email required',
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: 'Password',
                            hint: '••••••••',
                            controller: _passwordController,
                            isPassword: true,
                            validator: (v) => v!.length >= 6 ? null : 'Password too short',
                          ),
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: scheme.error),
                              ),
                            ),
                          const SizedBox(height: 24),
                          GradientButton(
                            label: 'Login',
                            isLoading: _isLoading,
                            onPressed: _handleLogin,
                          ),
                        ],
                      ),
                    ),
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
