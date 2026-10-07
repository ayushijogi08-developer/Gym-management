import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/app_user_model.dart';
import '../../../data/models/gym_config_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/gym_config_provider.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_dropdown_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/glass_container.dart';

class AddEditAdminScreen extends StatefulWidget {
  final AppUserModel? existingUser;
  const AddEditAdminScreen({super.key, this.existingUser});

  @override
  State<AddEditAdminScreen> createState() => _AddEditAdminScreenState();
}

class _AddEditAdminScreenState extends State<AddEditAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  
  String _selectedRole = 'admin';
  String? _selectedBranchId;
  List<BranchModel> _branches = [];
  bool _isLoadingBranches = false;
  bool _isSaving = false;

  final List<String> _roles = ['admin', 'receptionist'];

  bool get _isEditMode => widget.existingUser != null;

  @override
  void initState() {
    super.initState();
    final u = widget.existingUser;
    _nameController = TextEditingController(text: u?.name ?? '');
    _emailController = TextEditingController(text: u?.email ?? '');
    _phoneController = TextEditingController(text: u?.phone ?? '');
    _passwordController = TextEditingController();
    
    if (u != null) {
      _selectedRole = u.role;
      _selectedBranchId = u.assignedBranchId;
    }

    // Load branches
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBranches();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadBranches() async {
    setState(() => _isLoadingBranches = true);
    try {
      final gymProvider = context.read<GymConfigProvider>();
      await gymProvider.loadConfig(forceRefresh: true);
      final config = gymProvider.config;
      if (config != null) {
        setState(() {
          _branches = config.branches;
        });
      }
    } catch (e) {
      debugPrint('Error loading branches: $e');
    } finally {
      if (mounted) setState(() => _isLoadingBranches = false);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final auth = context.read<AuthProvider>();

    try {
      if (_isEditMode) {
        final updatedUser = widget.existingUser!.copyWith(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          role: _selectedRole,
          assignedBranchId: _selectedRole == 'receptionist' ? _selectedBranchId : null,
        );
        await auth.updateUserBasicInfo(updatedUser);
      } else {
        final newUser = AppUserModel(
          id: '',
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          passwordHash: _passwordController.text,
          role: _selectedRole,
          assignedBranchId: _selectedRole == 'receptionist' ? _selectedBranchId : null,
          isActive: true,
          mustChangePassword: true,
        );
        await auth.createUser(newUser);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showBranchSelector = _selectedRole == 'receptionist';

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Staff' : 'Add Staff'), // Updated title
        backgroundColor: context.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        label: 'Full Name',
                        hint: 'John Doe',
                        controller: _nameController,
                        prefixIcon: Icons.person_outline,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Email',
                        hint: 'user@gym.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (v) => (v == null || !v.contains('@')) ? 'Enter valid email' : null,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Phone',
                        hint: '9876543210',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                      ),
                      const SizedBox(height: 16),
                      
                      // ✅ ROLE SELECTION
                      AppDropdownField<String>(
                        label: 'Role',
                        value: _selectedRole,
                        items: _roles,
                        itemLabel: (v) => v.toUpperCase(),
                        onChanged: (v) {
                          setState(() {
                            _selectedRole = v!;
                            if (_selectedRole != 'receptionist') {
                              _selectedBranchId = null;
                            }
                          });
                        },
                      ),

                      // ✅ BRANCH SELECTION (Only for Receptionists)
                      if (showBranchSelector) ...[
                        const SizedBox(height: 16),
                        if (_isLoadingBranches)
                          const Center(child: CircularProgressIndicator(strokeWidth: 2))
                        else if (_branches.isNotEmpty)
                          DropdownButtonFormField<String>(
                            initialValue: _selectedBranchId,
                            decoration: const InputDecoration(
                              labelText: 'Assign Branch',
                              prefixIcon: Icon(Icons.storefront_rounded),
                              border: OutlineInputBorder(),
                              filled: true,
                            ),
                            items: _branches.map((b) {
                              return DropdownMenuItem<String>(
                                value: b.id,
                                child: Text(b.name),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _selectedBranchId = v),
                            validator: (v) => v == null ? 'Please assign a branch' : null,
                          )
                        else
                          const Text(
                            'No branches available. Please add a branch first.',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                      ],

                      if (!_isEditMode) ...[
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Password',
                          hint: '••••••••',
                          controller: _passwordController,
                          isPassword: true,
                          prefixIcon: Icons.lock_outline,
                          validator: (v) => (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
                        ),
                      ],
                      const SizedBox(height: 24),
                      GradientButton(
                        label: _isEditMode ? 'Update Staff' : 'Create Staff',
                        isLoading: _isSaving,
                        onPressed: _handleSave,
                      ),
                    ],
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