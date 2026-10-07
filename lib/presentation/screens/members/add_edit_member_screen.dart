import 'package:flutter/material.dart';
import 'package:gym_management_app/data/models/gym_config_model.dart';
import 'package:gym_management_app/data/models/plan_model.dart';
import 'package:gym_management_app/providers/plan_provider.dart';
import 'package:gym_management_app/providers/gym_config_provider.dart';
import 'package:provider/provider.dart';
import '../../../data/models/member_model.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../../providers/trainer_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_dropdown_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/glass_container.dart';
import '../scanner/qr_reveal_screen.dart';
import '../../../data/models/trainer_model.dart';
import 'widgets/member_subscription_section.dart';
import 'package:gym_management_app/utils/route_helper.dart';
import '../../../providers/auth_provider.dart';
import '../../../domain/entities/user_role.dart';
import '../../../data/models/app_user_model.dart';

class AddEditMemberScreen extends StatefulWidget {
  final MemberModel? existingMember;

  const AddEditMemberScreen({super.key, this.existingMember});

  @override
  State<AddEditMemberScreen> createState() => _AddEditMemberScreenState();
}

class _AddEditMemberScreenState extends State<AddEditMemberScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _emergencyController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _medicalController;
  late TextEditingController _notesController;

  String _gender = 'Male';
  String _bloodGroup = 'O+';
  String _planName = '';
  String _paymentType = 'cash';
  TrainerModel? _selectedTrainer;
  DateTime _joiningDate = DateTime.now();
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 30));
  DateTime? _dob;
  bool _isSaving = false;

  bool get _isEditMode => widget.existingMember != null;

  final List<String> _paymentTypes = ['cash', 'card', 'upi', 'netBanking', 'wallet'];

  // ✅ BRANCH SELECTION FIELDS
  String? _selectedBranchId;
  List<BranchModel> _branches = [];
  bool _isLoadingBranches = true;
  bool _isBranchLocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanProvider>().loadPlans();
      context.read<TrainerProvider>().loadTrainers();
      _loadBranchesAndSetDefault(); 
    });

    final m = widget.existingMember;

    _nameController = TextEditingController(text: m?.fullName ?? '');
    _phoneController = TextEditingController(text: m?.phone ?? '');
    _emailController = TextEditingController(text: m?.email ?? '');
    _emergencyController = TextEditingController(text: m?.emergencyContact ?? '');
    _heightController = TextEditingController(text: m?.heightCm?.toString() ?? '');
    _weightController = TextEditingController(text: m?.weightKg?.toString() ?? '');
    _medicalController = TextEditingController(text: m?.medicalConditions ?? '');
    _notesController = TextEditingController(text: m?.notes ?? '');

    if (m != null) {
      _gender = m.gender;
      _bloodGroup = m.bloodGroup ?? 'O+';
      _planName = m.planName;
      _joiningDate = m.joiningDate;
      _expiryDate = m.expiryDate;
      _dob = m.dob;

      if (m.assignedTrainerId != null) {
        _selectedTrainer = context.read<TrainerProvider>()
            .trainers
            .where((t) => t.id == m.assignedTrainerId)
            .firstOrNull;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final availablePlans = context.read<PlanProvider>()
            .plans
            .map((p) => p.planName)
            .toList();

        if (!availablePlans.contains(_planName) && availablePlans.isNotEmpty) {
          setState(() {
            _planName = availablePlans.first;
          });
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final availablePlans = context.read<PlanProvider>().plans;
        if (availablePlans.isNotEmpty) {
          final monthlyPlan = availablePlans.firstWhere(
            (p) => p.planName.toLowerCase().contains('monthly'),
            orElse: () => availablePlans.first,
          );
          setState(() {
            _planName = monthlyPlan.planName;
            _expiryDate = _joiningDate.add(Duration(days: monthlyPlan.durationInDays));
          });
        }
      });
    }
  }

  Future<void> _loadBranchesAndSetDefault() async {
    setState(() => _isLoadingBranches = true);
    
    final gymProvider = context.read<GymConfigProvider>();
    final authProvider = context.read<AuthProvider>();
    
    await gymProvider.loadConfig(forceRefresh: true);
    final config = gymProvider.config;
    
    if (config != null) {
      _branches = config.branches;
      
      final currentUser = authProvider.currentUser;
      final isAdmin = currentUser?.role == 'admin' || currentUser?.role == 'superadmin';

      if (isAdmin) {
        _isBranchLocked = false;
        if (_branches.isNotEmpty) {
          _selectedBranchId = _branches.first.id;
        }
      } else {
        // Receptionist / Trainer: LOCKED
        _isBranchLocked = true;
        final userBranchId = currentUser?.assignedBranchId; 
        
        if (userBranchId != null && _branches.any((b) => b.id == userBranchId)) {
          _selectedBranchId = userBranchId;
        } else if (_branches.isNotEmpty) {
          _selectedBranchId = _branches.first.id;
        }
      }
    }
    
    if (mounted) setState(() => _isLoadingBranches = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _emergencyController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _medicalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required DateTime? initial,
    required void Function(DateTime) onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.primary,
            surface: context.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_planName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a membership plan before saving')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final memberProvider = context.read<MemberProvider>();
    final subProvider = context.read<SubscriptionProvider>();

    final status = _expiryDate.isBefore(DateTime.now())
        ? 'expired'
        : _expiryDate.difference(DateTime.now()).inDays <= 7
            ? 'expiringSoon'
            : 'active';

    MemberModel savedMember;

    if (_isEditMode) {
      final existing = widget.existingMember!;

      existing
        ..fullName = _nameController.text.trim()
        ..gender = _gender
        ..phone = _phoneController.text.trim()
        ..email = _emailController.text.trim()
        ..membershipStatus = status
        ..planName = _planName
        ..joiningDate = _joiningDate
        ..expiryDate = _expiryDate
        ..dob = _dob
        ..emergencyContact = _emergencyController.text.trim()
        ..bloodGroup = _bloodGroup
        ..heightCm = double.tryParse(_heightController.text.trim())
        ..weightKg = double.tryParse(_weightController.text.trim())
        ..medicalConditions = _medicalController.text.trim()
        ..notes = _notesController.text.trim()
        ..assignedTrainerId = _selectedTrainer?.id;

      await memberProvider.updateMember(existing);
      savedMember = existing;

      if (existing.expiryDate != widget.existingMember!.expiryDate) {
        await memberProvider.regenerateQr(existing.id);
      }
    } else {
      final selectedBranch = _branches.firstWhere((b) => b.id == _selectedBranchId);

      final newMember = MemberModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: _nameController.text.trim(),
        gender: _gender,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        membershipStatus: status,
        planName: _planName,
        joiningDate: _joiningDate,
        expiryDate: _expiryDate,
        dob: _dob,
        emergencyContact: _emergencyController.text.trim(),
        bloodGroup: _bloodGroup,
        heightCm: double.tryParse(_heightController.text.trim()),
        weightKg: double.tryParse(_weightController.text.trim()),
        medicalConditions: _medicalController.text.trim(),
        notes: _notesController.text.trim(),
        assignedTrainerId: _selectedTrainer?.id,
        qrData: '',
        branchId: _selectedBranchId,
        branchName: selectedBranch.name,
      );

      // Create the User first
      await _createLoginForMember(newMember);

      // Save the Member
      await memberProvider.addMember(
        newMember, 
        subProvider, 
        context,
        branchId: _selectedBranchId,
        branchName: selectedBranch.name,
      );
      savedMember = newMember;
    }

    // ✅ FIX: Turn off loading and Navigate
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (!_isEditMode) {
      Navigator.of(context).pushReplacement(
        buildAppRoute(QrRevealScreen(member: savedMember)),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final trainerProvider = context.watch<TrainerProvider>();
    
    if (trainerProvider.trainers.isEmpty && !_isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        trainerProvider.loadTrainers();
      });
    }

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Member' : 'Add Member'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;
            final maxWidth = isWide ? 800.0 : double.infinity;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Form(
                    key: _formKey,
                    child: GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildResponsiveRow(isWide, [
                            AppTextField(
                              label: 'Full Name',
                              hint: 'John Doe',
                              controller: _nameController,
                              prefixIcon: Icons.person_outline,
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                            AppDropdownField<String>(
                              label: 'Gender',
                              value: _gender,
                              items: const ['Male', 'Female', 'Other'],
                              itemLabel: (v) => v,
                              onChanged: (v) => setState(() => _gender = v!),
                            ),
                          ]),
                          const SizedBox(height: 16),
                          _buildResponsiveRow(isWide, [
                            AppTextField(
                              label: 'Phone',
                              hint: '9876543210',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icons.phone_outlined,
                              validator: (v) => (v == null || v.trim().length < 10) ? 'Enter valid phone' : null,
                            ),
                            AppTextField(
                              label: 'Email',
                              hint: 'you@example.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.email_outlined,
                              validator: (v) => (v == null || !v.contains('@')) ? 'Enter valid email' : null,
                            ),
                          ]),
                          const SizedBox(height: 16),
                          _buildResponsiveRow(isWide, [
                            _DatePickerTile(
                              label: 'Date of Birth',
                              date: _dob,
                              onTap: () => _pickDate(initial: _dob, onPicked: (d) => setState(() => _dob = d)),
                            ),
                            AppTextField(
                              label: 'Emergency Contact',
                              hint: '9876543210',
                              controller: _emergencyController,
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icons.emergency_outlined,
                            ),
                          ]),
                          const SizedBox(height: 16),
                          _buildResponsiveRow(isWide, [
                            AppDropdownField<String>(
                              label: 'Blood Group',
                              value: _bloodGroup,
                              items: const ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
                              itemLabel: (v) => v,
                              onChanged: (v) => setState(() => _bloodGroup = v!),
                            ),
                            Consumer<PlanProvider>(
                              builder: (context, planProvider, _) {
                                final plans = planProvider.plans;

                                if (plans.isEmpty) {
                                  return AppDropdownField<String>(
                                    label: 'Plan',
                                    value: 'Loading Plans...',
                                    items: const ['Loading Plans...'],
                                    itemLabel: (v) => v,
                                    onChanged: (_) {},
                                  );
                                }

                                return AppDropdownField<String>(
                                  label: 'Plan',
                                  value: plans.isNotEmpty
                                      ? (_planName.isNotEmpty && plans.map((p) => p.planName).contains(_planName)
                                          ? _planName
                                          : plans.first.planName)
                                      : null,
                                  items: plans.map((p) => p.planName).toList(),
                                  itemLabel: (planName) {
                                    final plan = plans.firstWhere(
                                      (p) => p.planName == planName,
                                      orElse: () => PlanModel(
                                        id: '',
                                        planName: planName,
                                        durationType: 'Monthly',
                                        durationInDays: 30,
                                        price: 0,
                                        discountPercent: 0,
                                        gstPercent: 18,
                                        facilitiesIncluded: [],
                                        isPTIncluded: false,
                                        status: 'active',
                                      ),
                                    );
                                    return '${plan.planName} - ₹${plan.price}';
                                  },
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => _planName = v);
                                      final selectedPlan = plans.firstWhere(
                                        (p) => p.planName == v,
                                        orElse: () => PlanModel(
                                          id: '',
                                          planName: v,
                                          durationType: 'Monthly',
                                          durationInDays: 30,
                                          price: 0,
                                          discountPercent: 0,
                                          gstPercent: 18,
                                          facilitiesIncluded: [],
                                          isPTIncluded: false,
                                          status: 'active',
                                        ),
                                      );
                                      setState(() {
                                        _expiryDate = _joiningDate.add(Duration(days: selectedPlan.durationInDays));
                                      });
                                    }
                                  },
                                );
                              },
                            ),
                          ]),
                          const SizedBox(height: 16),

                          // ✅ BRANCH SELECTION WIDGET
                          if (_isLoadingBranches)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: context.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                          else if (_branches.isNotEmpty)
                            DropdownButtonFormField<String>(
                              initialValue: _selectedBranchId,
                              decoration: InputDecoration(
                                labelText: _isBranchLocked ? 'Branch (Auto-Assigned)' : 'Assign Branch',
                                prefixIcon: const Icon(Icons.storefront_rounded),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: _isBranchLocked ? context.surfaceAlt : context.surface,
                              ),
                              onChanged: _isBranchLocked ? null : (String? newValue) {
                                setState(() {
                                  _selectedBranchId = newValue;
                                });
                              },
                              items: _branches.map<DropdownMenuItem<String>>((BranchModel branch) {
                                return DropdownMenuItem<String>(
                                  value: branch.id,
                                  child: Text(branch.name),
                                );
                              }).toList(),
                            ),
                          
                          const SizedBox(height: 16),

                          // ✅ Trainer Dropdown
                          Consumer<TrainerProvider>(
                            builder: (context, provider, _) {
                              final trainers = provider.trainers;
                              
                              if (trainers.isEmpty) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  provider.loadTrainers();
                                });
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: context.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: context.primary.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Loading trainers...',
                                        style: TextStyle(color: context.textSecondary),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return AppDropdownField<TrainerModel?>(
                                label: 'Assigned Trainer',
                                value: _selectedTrainer,
                                items: trainers,
                                itemLabel: (t) => t?.fullName ?? 'None',
                                onChanged: (t) => setState(() => _selectedTrainer = t),
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // ✅ Payment Type
                          AppDropdownField<String>(
                            label: 'Payment Type',
                            value: _paymentType,
                            items: _paymentTypes,
                            itemLabel: (v) => v.toUpperCase(),
                            onChanged: (v) => setState(() => _paymentType = v!),
                          ),
                          const SizedBox(height: 16),

                          _buildResponsiveRow(isWide, [
                            AppTextField(
                              label: 'Height (cm)',
                              hint: '175',
                              controller: _heightController,
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.height_rounded,
                            ),
                            AppTextField(
                              label: 'Weight (kg)',
                              hint: '70',
                              controller: _weightController,
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.monitor_weight_outlined,
                            ),
                          ]),
                          const SizedBox(height: 16),
                          _buildResponsiveRow(isWide, [
                            _DatePickerTile(
                              label: 'Joining Date',
                              date: _joiningDate,
                              onTap: () => _pickDate(initial: _joiningDate, onPicked: (d) => setState(() => _joiningDate = d)),
                            ),
                            _DatePickerTile(
                              label: 'Expiry Date',
                              date: _expiryDate,
                              onTap: () => _pickDate(initial: _expiryDate, onPicked: (d) => setState(() => _expiryDate = d)),
                            ),
                          ]),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: 'Medical Conditions',
                            hint: 'None',
                            controller: _medicalController,
                            prefixIcon: Icons.medical_services_outlined,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: 'Notes',
                            hint: 'Additional notes...',
                            controller: _notesController,
                            prefixIcon: Icons.note_outlined,
                          ),
                          if (_isEditMode) ...[
                            const SizedBox(height: 24),
                            MemberSubscriptionSection(
                              memberId: widget.existingMember?.id ?? '',
                              isEditMode: true,
                            ),
                          ],
                          const SizedBox(height: 24),
                          GradientButton(
                            label: _isEditMode ? 'Update Member' : 'Save Member',
                            isLoading: _isSaving,
                            onPressed: _handleSave,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResponsiveRow(bool isWide, List<Widget> children) {
    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 16), child: c)).toList(),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.asMap().entries.map((entry) {
        int idx = entry.key;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: idx == children.length - 1 ? 0 : 16),
            child: entry.value,
          ),
        );
      }).toList(),
    );
  }

  String _generateTempPassword(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 6) {
      return digits.substring(0, 6);
    }
    return digits.padRight(6, '0');
  }

  Future<void> _createLoginForMember(MemberModel member) async {
    final authProvider = context.read<AuthProvider>();

    final existingUser = await authProvider.getUsersByRole('member')
        .then((users) => users.where((u) => u.email == member.email).firstOrNull);

    if (existingUser != null) {
      print("⏭️ User already exists for this email");
      return;
    }

    final tempPassword = _generateTempPassword(member.phone);

    final newUser = AppUserModel(
      id: '',
      name: member.fullName,
      email: member.email,
      phone: member.phone,
      passwordHash: tempPassword,
      role: UserRole.member.name,
      isActive: true,
      mustChangePassword: true,
    );

    await authProvider.createUser(newUser);
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DatePickerTile({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: context.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.border),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 18, color: context.textSecondary),
                const SizedBox(width: 12),
                Text(
                  date != null ? '${date!.day}/${date!.month}/${date!.year}' : 'Select Date',
                  style: TextStyle(color: context.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}