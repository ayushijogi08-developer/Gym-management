import 'package:flutter/material.dart';
import 'package:gym_management_app/data/enums/goal_enums.dart';
import 'package:gym_management_app/data/models/body_progress_model.dart';
import 'package:gym_management_app/data/models/goal_milestone_model.dart';
import 'package:gym_management_app/data/models/goal_model.dart';
import 'package:gym_management_app/data/models/member_model.dart';
import 'package:gym_management_app/domain/entities/user_role.dart';
import 'package:gym_management_app/providers/body_progress_provider.dart';
import 'package:gym_management_app/providers/goal_provider.dart';
import 'package:gym_management_app/providers/member_provider.dart';
import 'package:gym_management_app/providers/auth_provider.dart';
import 'package:gym_management_app/themes/app_colors.dart';
import 'package:gym_management_app/themes/app_design_tokens.dart';
import 'package:gym_management_app/themes/app_spacing.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_dropdown_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/glass_container.dart';

class AddEditGoalScreen extends StatefulWidget {
  final String? goalId;
  final String? memberId;

  const AddEditGoalScreen({super.key, this.goalId, this.memberId});

  @override
  State<AddEditGoalScreen> createState() => _AddEditGoalScreenState();
}

class _AddEditGoalScreenState extends State<AddEditGoalScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _targetValueController = TextEditingController();
  final TextEditingController _startingValueController = TextEditingController();

  String? selectedMemberId;
  String goalType = GoalType.weightLoss;
  String unit = GoalUnit.kg;
  DateTime? targetDate;
  String trackingMode = GoalTrackingMode.manual;

  bool _isLoading = false;

  final List<Map<String, String>> goalTypes = [
    {'value': GoalType.weightLoss, 'label': GoalType.label(GoalType.weightLoss)},
    {'value': GoalType.muscleGain, 'label': GoalType.label(GoalType.muscleGain)},
    {'value': GoalType.strength, 'label': GoalType.label(GoalType.strength)},
    {'value': GoalType.endurance, 'label': GoalType.label(GoalType.endurance)},
    {'value': GoalType.other, 'label': GoalType.label(GoalType.other)},
  ];

  final List<String> units = GoalUnit.all;

  bool get _isAutomaticCompatible =>
      GoalTrackingMode.isAutomaticMetric(unit, goalType);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final isMember = auth.currentRole == UserRole.member;
      final memberProvider = context.read<MemberProvider>();

      memberProvider.loadMembers();

      // Set the memberId based on role and parameters
      if (widget.memberId != null && widget.memberId!.isNotEmpty) {
        setState(() {
          selectedMemberId = widget.memberId;
        });
      } else if (isMember) {
        final memberId = auth.currentUser?.linkedMemberId;
        if (memberId != null && memberId.isNotEmpty) {
          setState(() {
            selectedMemberId = memberId;
          });
        }
      }

      // If editing existing goal, load it
      if (widget.goalId != null) {
        _loadExistingGoal();
      }
    });
  }

  Future<void> _loadExistingGoal() async {
    setState(() => _isLoading = true);
    final goalProvider = context.read<GoalProvider>();
    final existingGoal = goalProvider.getGoalById(widget.goalId!);

    if (existingGoal != null) {
      setState(() {
        selectedMemberId = existingGoal.memberId;
        goalType = existingGoal.goalType;
        _titleController.text = existingGoal.goalTitle;
        _targetValueController.text = existingGoal.targetValue.toString();
        unit = existingGoal.unit;
        targetDate = existingGoal.targetDate;
        trackingMode = existingGoal.trackingMode;
        _startingValueController.text = existingGoal.startingValue.toString();
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetValueController.dispose();
    _startingValueController.dispose();
    super.dispose();
  }

  /// Pulls the latest body-progress entry that matches the current
  /// unit/goalType so we can prefill the starting value for new
  /// automatic goals. Returns null if no usable entry exists.
  double? _latestBodyValue() {
    final provider = context.read<BodyProgressProvider>();
    final auth = context.read<AuthProvider>();
    final memberId = selectedMemberId ??
        auth.currentUser?.linkedMemberId ??
        widget.memberId ??
        '';
    if (memberId.isEmpty) return null;
    if (!_isAutomaticCompatible) return null;

    final history = provider.getHistory(memberId);
    if (history.isEmpty) return null;
    final entry = history.first;
    switch (unit) {
      case 'kg':
      case 'lbs':
        if (goalType == GoalType.weightLoss) return entry.weightKg;
        if (goalType == GoalType.muscleGain) return entry.muscleMassKg;
        return null;
      case '%':
        return entry.bodyFatPercent;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.goalId != null;
    final auth = context.watch<AuthProvider>();
    final isMember = auth.currentRole == UserRole.member;
    final memberProvider = context.watch<MemberProvider>();

    // Get member name for display
    String memberName = '';
    if (selectedMemberId != null) {
      MemberModel? match;
      try {
        match = memberProvider.members
            .firstWhere((m) => m.id == selectedMemberId);
      } catch (_) {
        match = null;
      }
      if (match != null) memberName = match.fullName;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Goal' : 'Create New Goal'),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: context.colors.primary),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Loading…',
                    style: TextStyle(color: context.textSecondary),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: GlassContainer(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Member Selector - HIDE for members, SHOW for trainers/admins
                      if (!isMember)
                        Consumer<MemberProvider>(
                          builder: (context, memberProvider, _) {
                            final members = memberProvider.members;
                            return AppDropdownField<String>(
                              label: 'Member',
                              value: selectedMemberId,
                              items: members.map((m) => m.id).toList(),
                              itemLabel: (id) => members
                                  .firstWhere((m) => m.id == id)
                                  .fullName,
                              onChanged: (v) =>
                                  setState(() => selectedMemberId = v),
                            );
                          },
                        )
                      else
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.person_outline,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Member',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: context.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      memberName.isNotEmpty
                                          ? memberName
                                          : 'Loading…',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: context.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppSpacing.md),

                      // Goal Type
                      AppDropdownField<String>(
                        label: 'Goal Type',
                        value: goalType,
                        items: goalTypes.map((e) => e['value']!).toList(),
                        itemLabel: (v) => goalTypes
                            .firstWhere((e) => e['value'] == v)['label']!,
                        onChanged: (v) {
                          setState(() {
                            goalType = v!;
                            // Drop automatic mode if the new combo isn't
                            // supported so we don't show a stale helper.
                            if (!_isAutomaticCompatible) {
                              trackingMode = GoalTrackingMode.manual;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Goal Title
                      AppTextField(
                        label: 'Goal Title',
                        controller: _titleController,
                        validator: (v) =>
                            (v?.isEmpty ?? true) ? 'Title is required' : null,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Target Value + Unit
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Target Value',
                              controller: _targetValueController,
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v?.isEmpty ?? true) return 'Required';
                                if (double.tryParse(v!) == null) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppDropdownField<String>(
                              label: 'Unit',
                              value: unit,
                              items: units,
                              itemLabel: (v) => v,
                              onChanged: (v) {
                                setState(() {
                                  unit = v!;
                                  if (!_isAutomaticCompatible) {
                                    trackingMode = GoalTrackingMode.manual;
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Tracking Mode toggle
                      _buildTrackingModeToggle(),
                      if (_isAutomaticCompatible &&
                          trackingMode == GoalTrackingMode.automatic) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.auto_awesome,
                                  size: 14, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Progress updates automatically from the '
                                  'member\'s latest body measurement. They '
                                  'don\'t need to type a current value.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (trackingMode == GoalTrackingMode.automatic &&
                          _isAutomaticCompatible) ...[
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Starting Value ($unit)',
                          controller: _startingValueController,
                          keyboardType: TextInputType.number,
                          hint:
                              'Latest measurement: ${_latestBodyValue()?.toStringAsFixed(1) ?? '—'}',
                          validator: (v) {
                            if (trackingMode != GoalTrackingMode.automatic) {
                              return null;
                            }
                            if (v?.isEmpty ?? true) return 'Required';
                            if (double.tryParse(v!) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),

                      // Target Date
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: targetDate ??
                                DateTime.now()
                                    .add(const Duration(days: 30)),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null && mounted) {
                            setState(() => targetDate = picked);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: context.surfaceAlt,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: context.border),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded,
                                  color: AppColors.primary, size: 18),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Target Date (Optional)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: context.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      targetDate != null
                                          ? '${targetDate!.day}/${targetDate!.month}/${targetDate!.year}'
                                          : 'Not set',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: context.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded,
                                  color: context.textSecondary),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      GradientButton(
                        label: isEditing ? 'Update Goal' : 'Create Goal',
                        isLoading: _isLoading,
                        onPressed: _saveGoal,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTrackingModeToggle() {
    final canUseAutomatic = _isAutomaticCompatible;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tracking Mode',
          style: TextStyle(
            color: context.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildModeChip(
                label: 'Manual',
                icon: Icons.edit_outlined,
                isSelected: trackingMode == GoalTrackingMode.manual,
                onTap: () => setState(
                    () => trackingMode = GoalTrackingMode.manual),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildModeChip(
                label: 'Automatic',
                icon: Icons.auto_awesome,
                isSelected: trackingMode == GoalTrackingMode.automatic,
                onTap: canUseAutomatic
                    ? () => setState(
                        () => trackingMode = GoalTrackingMode.automatic)
                    : null,
                disabledHint: canUseAutomatic
                    ? null
                    : 'Auto-tracking is only available for weight-loss '
                        '(kg/lbs/% bodyfat) and muscle-gain (kg/lbs) '
                        'goals with a matching unit.',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback? onTap,
    String? disabledHint,
  }) {
    final disabled = onTap == null;
    return Tooltip(
      message: disabledHint ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.12)
                : context.surfaceAlt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : context.border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? AppColors.primary
                    : disabled
                        ? context.textMuted
                        : context.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.primary
                      : disabled
                          ? context.textMuted
                          : context.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final goalProvider = context.read<GoalProvider>();
    final auth = context.read<AuthProvider>();
    final targetVal = double.tryParse(_targetValueController.text) ?? 0.0;
    final startingVal =
        trackingMode == GoalTrackingMode.automatic
            ? double.tryParse(_startingValueController.text) ?? 0.0
            : 0.0;

    try {
      if (widget.goalId != null) {
        // EDIT MODE
        final existingGoal = goalProvider.getGoalById(widget.goalId!);
        if (existingGoal != null) {
          existingGoal.goalTitle = _titleController.text.trim();
          existingGoal.targetValue = targetVal;
          existingGoal.goalType = goalType;
          existingGoal.unit = unit;
          existingGoal.targetDate = targetDate;
          existingGoal.trackingMode = trackingMode;
          if (trackingMode == GoalTrackingMode.automatic) {
            existingGoal.startingValue = startingVal;
          }
          await goalProvider.updateGoal(existingGoal);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Goal updated successfully!')),
          );
        }
      } else {
        // CREATE MODE
        final memberIdToUse = selectedMemberId ??
            widget.memberId ??
            auth.currentUser?.linkedMemberId;

        if (memberIdToUse == null || memberIdToUse.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Member ID not found. Please select a member.')),
          );
          setState(() => _isLoading = false);
          return;
        }

        final goalId = const Uuid().v4();
        await goalProvider.createGoalAdvanced(
          memberId: memberIdToUse,
          goalType: goalType,
          goalTitle: _titleController.text.trim(),
          targetValue: targetVal,
          unit: unit,
          targetDate: targetDate,
          trackingMode: trackingMode,
          startingValue: startingVal,
          milestones: GoalMilestoneModel.defaultsFor(goalId),
          context: context,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal created successfully!')),
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error saving goal: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}