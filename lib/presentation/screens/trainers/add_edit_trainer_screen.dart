import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/trainer_model.dart';
import '../../../providers/trainer_provider.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_dropdown_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/glass_container.dart';
import 'package:flutter/services.dart'; 

class AddEditTrainerScreen extends StatefulWidget {
  final TrainerModel? existingTrainer;

  const AddEditTrainerScreen({super.key, this.existingTrainer});

  @override
  State<AddEditTrainerScreen> createState() => _AddEditTrainerScreenState();
}

class _AddEditTrainerScreenState extends State<AddEditTrainerScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late TextEditingController _experienceController;
  late TextEditingController _shiftStartController;
  late TextEditingController _shiftEndController;

  String _specialization = 'Strength Training';
  List<String> _workingDays = [];
  String _status = 'active';
  bool _isSaving = false;

  final List<String> _specializations = [
    'Strength Training', 'Yoga & Pilates', 'CrossFit', 'Cardio', 'Bodybuilding',
    'HIIT', 'Powerlifting', 'Rehabilitation'
  ];

  final List<String> _allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  bool get _isEditMode => widget.existingTrainer != null;

  @override
  void initState() {
    super.initState();
    final t = widget.existingTrainer;
    _nameController = TextEditingController(text: t?.fullName ?? '');
    _phoneController = TextEditingController(text: t?.phone ?? '');
    _emailController = TextEditingController(text: t?.email ?? '');
    _bioController = TextEditingController(text: t?.bio ?? '');
    _experienceController = TextEditingController(text: t?.experienceYears.toString() ?? '5');
    _shiftStartController = TextEditingController(text: t?.shiftStart ?? '06:00');
    _shiftEndController = TextEditingController(text: t?.shiftEnd ?? '14:00');

    if (t != null) {
      _specialization = t.specialization;
      _workingDays = List.from(t.workingDays);
      _status = t.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _shiftStartController.dispose();
    _shiftEndController.dispose();
    super.dispose();
  }

 Future<void> _handleSave() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isSaving = true);

  final trainer = TrainerModel(
    id: widget.existingTrainer?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    fullName: _nameController.text.trim(),
    phone: _phoneController.text.trim(),
    email: _emailController.text.trim(),
    specialization: _specialization,
    experienceYears: int.tryParse(_experienceController.text.trim()) ?? 5,
    bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
    workingDays: _workingDays,
    shiftStart: _shiftStartController.text,
    shiftEnd: _shiftEndController.text,
    status: _status,
  );

  final provider = context.read<TrainerProvider>();

  try {
    if (_isEditMode) {
      final existing = widget.existingTrainer!;
      existing
        ..fullName = trainer.fullName
        ..phone = trainer.phone
        ..email = trainer.email
        ..specialization = trainer.specialization
        ..experienceYears = trainer.experienceYears
        ..bio = trainer.bio
        ..workingDays = trainer.workingDays
        ..shiftStart = trainer.shiftStart
        ..shiftEnd = trainer.shiftEnd
        ..status = trainer.status;

      await provider.updateTrainer(existing);
    } else {
      await provider.addTrainer(trainer);
    }

    if (!mounted) return;

    Navigator.of(context).pop();           // Close Edit screen
  if (_isEditMode) {
     Navigator.of(context).pop();        // Close Profile screen if we were editing
  }        // Close Profile screen → back to List

  } catch (e) {
    if (!mounted) return;
    final String errorText = e.toString().replaceAll('Exception: ', '');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorText),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  } finally {
    if (mounted) setState(() => _isSaving = false);
  }

}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Trainer' : 'Add Trainer')),
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
                              hint: 'Vikram Singh',
                              controller: _nameController,
                              validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
                            ),
                            AppTextField(
                              label: 'Phone',
                              hint: '9876543210',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
    FilteringTextInputFormatter.digitsOnly, // Only allow numbers
    LengthLimitingTextInputFormatter(10),    // Max 10 characters
  ],
                              validator: (v) => (v?.length ?? 0) < 10 ? 'Valid phone required' : null,
                            ),
                          ]),
                          const SizedBox(height: 16),
                          _buildResponsiveRow(isWide, [
                            AppTextField(
                              label: 'Email',
                              hint: 'trainer@gym.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => !v!.contains('@') ? 'Valid email required' : null,
                            ),
                            AppDropdownField<String>(
                              label: 'Specialization',
                              value: _specialization,
                              items: _specializations,
                              itemLabel: (v) => v,
                              onChanged: (v) => setState(() => _specialization = v!),
                            ),
                          ]),
                          const SizedBox(height: 16),
                          _buildResponsiveRow(isWide, [
                            AppTextField(
                              label: 'Experience (Years)',
                              hint: '8',
                              controller: _experienceController,
                              keyboardType: TextInputType.number,
                              validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Positive number required' : null,
                            ),
                            AppDropdownField<String>(
                              label: 'Status',
                              value: _status,
                              items: const ['active', 'onLeave', 'inactive'],
                              itemLabel: (v) => v,
                              onChanged: (v) => setState(() => _status = v!),
                            ),
                          ]),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: 'Bio / Notes',
                            hint: 'Certified strength coach...',
                            controller: _bioController,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Working Days',
                            style: TextStyle(
                              color: context.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _allDays.map((day) {
                              final selected = _workingDays.contains(day);
                              return FilterChip(
                                label: Text(day),
                                selected: selected,
                                onSelected: (sel) {
                                  setState(() {
                                    if (sel) {
                                      _workingDays.add(day);
                                    } else {
                                      _workingDays.remove(day);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          _buildResponsiveRow(isWide, [
                            AppTextField(
                              label: 'Shift Start (HH:mm)',
                              hint: '06:00',
                              controller: _shiftStartController,
                            ),
                            AppTextField(
                              label: 'Shift End (HH:mm)',
                              hint: '14:00',
                              controller: _shiftEndController,
                            ),
                          ]),
                          const SizedBox(height: 24),
                          GradientButton(
                            label: _isEditMode ? 'Update Trainer' : 'Save Trainer',
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
        children: children
            .map((c) => Padding(padding: const EdgeInsets.only(bottom: 16), child: c))
            .toList(),
      );
    }
    
    // Improved Row logic
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.asMap().entries.map((entry) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: entry.key == 0 ? 0 : 8,
              right: entry.key == children.length - 1 ? 0 : 8,
            ),
            child: entry.value,
          ),
        );
      }).toList(),
    );
  }
}