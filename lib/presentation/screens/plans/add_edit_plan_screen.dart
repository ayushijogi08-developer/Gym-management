import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/plan_model.dart';
import '../../../providers/plan_provider.dart';
import '../../../themes/app_design_tokens.dart';
import '../../../themes/app_spacing.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_dropdown_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/plan_card.dart';
import '../../widgets/premium_filter_chip.dart';

class AddEditPlanScreen extends StatefulWidget {
  final PlanModel? existingPlan;

  const AddEditPlanScreen({super.key, this.existingPlan});

  @override
  State<AddEditPlanScreen> createState() => _AddEditPlanScreenState();
}

class _AddEditPlanScreenState extends State<AddEditPlanScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _durationDaysController;
  late TextEditingController _priceController;
  late TextEditingController _discountController;
  late TextEditingController _gstController;
  late TextEditingController _descriptionController;
  late TextEditingController _renewalController;

  String _durationType = 'Monthly';
  bool _isPTIncluded = false;
  bool _isFreezeAllowed = false;
  List<String> _facilities = [];
  bool _isSaving = false;
  final List<String> _presetFacilities = [
    'Gym Access',
    'Locker',
    'Sauna',
    'Steam',
    'Swimming Pool',
    'Group Classes',
    'Diet Consultation',
  ];

  bool get _isEditMode => widget.existingPlan != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existingPlan;
    _nameController = TextEditingController(text: p?.planName ?? '');
    _durationDaysController =
        TextEditingController(text: p?.durationInDays.toString() ?? '30');
    _priceController = TextEditingController(text: p?.price.toString() ?? '');
    _discountController =
        TextEditingController(text: p?.discountPercent?.toString() ?? '');
    _gstController = TextEditingController(text: p?.gstPercent?.toString() ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _renewalController =
        TextEditingController(text: p?.renewalReminderDays.toString() ?? '7');

    if (p != null) {
      _durationType = p.durationType;
      _isPTIncluded = p.isPTIncluded;
      _isFreezeAllowed = p.isFreezeAllowed;
      _facilities = List.from(p.facilitiesIncluded);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationDaysController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _gstController.dispose();
    _descriptionController.dispose();
    _renewalController.dispose();
    super.dispose();
  }

  void _updateDurationDays(String type) {
    if (type == 'Custom') return;
    int days = 30;
    if (type == 'Quarterly') {
      days = 90;
    } else if (type == 'Half Yearly') {
      days = 180;
    } else if (type == 'Yearly') {
      days = 365;
    }
    _durationDaysController.text = days.toString();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final Map<String, dynamic> planData = {
      'planName': _nameController.text.trim(),
      'durationType': _durationType,
      'durationInDays': int.tryParse(_durationDaysController.text) ?? 30,
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'discountPercent': double.tryParse(_discountController.text) ?? 0.0,
      'gstPercent': double.tryParse(_gstController.text) ?? 18.0,
      'description': _descriptionController.text.trim(),
      'facilitiesIncluded': _facilities,
      'isPTIncluded': _isPTIncluded,
      'isFreezeAllowed': _isFreezeAllowed,
      'renewalReminderDays': int.tryParse(_renewalController.text) ?? 7,
      'status': 'active',
    };

    final provider = context.read<PlanProvider>();
    bool success = false;

    try {
      if (_isEditMode) {
        success = await provider.updatePlan(widget.existingPlan!.id, planData);
      } else {
        success = await provider.createPlan(planData);
      }

      if (success && mounted) {
        Navigator.of(context).pop();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to save plan. Check permissions or network.')),
          );
        }
      }
    } catch (e) {
      debugPrint('SAVE ERROR: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _toggleFacility(String facility) {
    setState(() {
      if (_facilities.contains(facility)) {
        _facilities.remove(facility);
      } else {
        _facilities.add(facility);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final previewPlan = PlanModel(
      id: '',
      planName: _nameController.text.isNotEmpty ? _nameController.text : 'Preview Plan',
      durationType: _durationType,
      durationInDays: int.tryParse(_durationDaysController.text) ?? 30,
      price: double.tryParse(_priceController.text) ?? 0,
      discountPercent: double.tryParse(_discountController.text),
      gstPercent: double.tryParse(_gstController.text),
      facilitiesIncluded: _facilities,
      isPTIncluded: _isPTIncluded,
    );

    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Plan' : 'Create Plan')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;
            final maxWidth = isWide ? 900.0 : double.infinity;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Form(
                    key: _formKey,
                    child: GlassContainer(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildResponsiveRow(isWide, [
                            AppTextField(
                              label: 'Plan Name',
                              hint: 'Gold Monthly',
                              controller: _nameController,
                              validator: (v) =>
                                  v?.trim().isEmpty ?? true ? 'Required' : null,
                            ),
                            AppDropdownField<String>(
                              label: 'Duration Type',
                              value: _durationType,
                              items: const [
                                'Monthly',
                                'Quarterly',
                                'Half Yearly',
                                'Yearly',
                                'Custom'
                              ],
                              itemLabel: (v) => v,
                              onChanged: (v) {
                                setState(() {
                                  _durationType = v!;
                                  _updateDurationDays(v);
                                });
                              },
                            ),
                          ]),
                          const SizedBox(height: AppSpacing.md),
                          _buildResponsiveRow(isWide, [
                            AppTextField(
                              label: 'Duration in Days',
                              hint: '30',
                              controller: _durationDaysController,
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null ||
                                      int.tryParse(v) == null)
                                  ? 'Required number'
                                  : null,
                            ),
                            AppTextField(
                              label: 'Price (₹)',
                              hint: '2000',
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null ||
                                      double.tryParse(v) == null ||
                                      double.parse(v) <= 0)
                                  ? 'Valid price >0'
                                  : null,
                            ),
                          ]),
                          const SizedBox(height: AppSpacing.md),
                          _buildResponsiveRow(isWide, [
                            AppTextField(
                              label: 'Discount %',
                              hint: '0',
                              controller: _discountController,
                              keyboardType: TextInputType.number,
                            ),
                            AppTextField(
                              label: 'GST %',
                              hint: '18',
                              controller: _gstController,
                              keyboardType: TextInputType.number,
                            ),
                          ]),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'Description',
                            hint: 'Comprehensive plan...',
                            controller: _descriptionController,
                            maxLines: 3,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Text(
                              'Facilities Included',
                              style: TextStyle(
                                color: context.textSecondary,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _presetFacilities.map((f) {
                              final selected = _facilities.contains(f);
                              return PremiumFilterChip(
                                label: f,
                                isSelected: selected,
                                onTap: () => _toggleFacility(f),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildResponsiveRow(isWide, [
                            _buildCheckRow(
                              label: 'PT Included',
                              value: _isPTIncluded,
                              onChanged: (v) =>
                                  setState(() => _isPTIncluded = v ?? false),
                            ),
                            _buildCheckRow(
                              label: 'Freeze Allowed',
                              value: _isFreezeAllowed,
                              onChanged: (v) =>
                                  setState(() => _isFreezeAllowed = v ?? false),
                            ),
                          ]),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'Renewal Reminder Days',
                            hint: '7',
                            controller: _renewalController,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Text(
                              'Live Preview',
                              style: TextStyle(
                                color: context.textSecondary,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          PlanCard(plan: previewPlan),
                          const SizedBox(height: AppSpacing.lg),
                          GradientButton(
                            label: _isEditMode ? 'Update Plan' : 'Create Plan',
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

  Widget _buildCheckRow({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveRow(bool isWide, List<Widget> children) {
    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children
            .map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: c,
                ))
            .toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.asMap().entries.map((entry) {
        final idx = entry.key;
        final child = entry.value;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                right: idx == children.length - 1 ? 0 : AppSpacing.md),
            child: child,
          ),
        );
      }).toList(),
    );
  }
}