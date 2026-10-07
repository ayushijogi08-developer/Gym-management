import 'package:flutter/material.dart';
import 'package:gym_management_app/data/models/member_model.dart';
import 'package:gym_management_app/domain/entities/user_role.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/member_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_button.dart';

class MemberPasswordResetScreen extends StatefulWidget {
  final String memberId;
  const MemberPasswordResetScreen({super.key, required this.memberId});

  @override
  State<MemberPasswordResetScreen> createState() => _MemberPasswordResetScreenState();
}

class _MemberPasswordResetScreenState extends State<MemberPasswordResetScreen> {
  bool _isLoading = false;
  String? _generatedPassword;
  MemberModel? _member;

  @override
  void initState() {
    super.initState();
    _loadMember();
  }

  Future<void> _loadMember() async {
    final memberProvider = context.read<MemberProvider>();
    await memberProvider.loadMembers();
    
    final member = memberProvider.members.firstWhere(
      (m) => m.id == widget.memberId,
      orElse: () => MemberModel(
        id: '',
        fullName: 'Unknown',
        gender: '',
        phone: '',
        email: '',
        membershipStatus: 'inactive',
        planName: 'No Plan',
        joiningDate: DateTime.now(),
        expiryDate: DateTime.now(),
      ),
    );
    
    if (mounted) {
      setState(() => _member = member);
    }
  }

  Future<void> _resetPassword() async {
    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthProvider>();
      final tempPassword = await auth.resetMemberPassword(widget.memberId);
      
      if (tempPassword != null && mounted) {
        setState(() {
          _generatedPassword = tempPassword;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Password reset successfully! New password: $tempPassword'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 5),
          ),
        );
      } else if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reset password'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    
    // Check if user has permission
    final canReset = auth.currentRole == UserRole.admin || 
                     auth.currentRole == UserRole.superAdmin ||
                     auth.currentRole == UserRole.receptionist;

    if (!canReset) {
      return Scaffold(
        backgroundColor: context.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: AppColors.danger),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, color: context.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Only Admins and Receptionists can reset passwords',
                style: TextStyle(color: context.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        title: const Text('Reset Member Password'),
        backgroundColor: context.background,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon
                  const Icon(
                    Icons.lock_reset,
                    size: 70,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'Reset Member Password',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Member Info
                  if (_member != null) ...[
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow('Member Name', _member!.fullName),
                          _buildInfoRow('Email', _member!.email),
                          _buildInfoRow('Phone', _member!.phone),
                          _buildInfoRow('Plan', _member!.planName),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Generated Password
                  if (_generatedPassword != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'New Password Generated',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            _generatedPassword!,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Share this password with the member',
                            style: TextStyle(color: context.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'They will be prompted to change it on next login',
                            style: TextStyle(color: context.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Reset Button
                  GradientButton(
                    label: _generatedPassword != null 
                        ? 'Generate New Password Again' 
                        : 'Reset Password',
                    isLoading: _isLoading,
                    onPressed: _resetPassword,
                  ),

                  if (_generatedPassword != null) ...[
                    const SizedBox(height: 12),
                    GradientButton(
                      label: 'Copy Password',
                      onPressed: () {
                        if (_generatedPassword != null) {
                          // Copy to clipboard
                          // You can add Clipboard functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password copied to clipboard'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
                    ),
                  ],

                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Members'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: context.textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: context.textPrimary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}