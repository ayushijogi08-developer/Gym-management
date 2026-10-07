import 'package:flutter/material.dart';
import 'package:gym_management_app/providers/auth_provider.dart';
import 'package:gym_management_app/providers/goal_provider.dart';
import 'package:provider/provider.dart';
import '../../../data/models/body_progress_model.dart';
import '../../../providers/body_progress_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/measurement_input_row.dart';
import '../../widgets/gradient_button.dart';

class AddProgressEntryScreen extends StatefulWidget {
  /// CHANGED: renamed from `entryToEdit` to `existingEntry` for
  /// consistency with the project's public API. When supplied, the
  /// screen opens in "edit" mode and pre-fills the controllers with
  /// the entry's existing values. The save button then routes through
  /// [BodyProgressProvider.updateEntry] instead of
  /// [BodyProgressProvider.addEntry], and the title switches to
  /// "Edit Body Progress Entry".
  final BodyProgressModel? existingEntry;

  const AddProgressEntryScreen({super.key, this.existingEntry});

  @override
  State<AddProgressEntryScreen> createState() => _AddProgressEntryScreenState();
}

class _AddProgressEntryScreenState extends State<AddProgressEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _muscleMassController = TextEditingController();
  final _notesController = TextEditingController();

  // Additional measurements
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipController = TextEditingController();
  final _armController = TextEditingController();
  final _thighController = TextEditingController();

  bool _showAdvanced = false;
  bool _applyToGoals = true;

  // CHANGED: convenience getter — true when the screen was opened to
  // edit an existing record rather than create a new one. Reads from
  // the renamed `widget.existingEntry`.
  bool get _isEditing => widget.existingEntry != null;

  @override
  void initState() {
    super.initState();
    // CHANGED: when editing, pre-fill every controller from the
    // supplied entry so the user can correct mistakes instead of
    // starting over. Uses null-safe `?.toString()` accessors so a
    // missing optional field silently leaves the input empty rather
    // than throwing.
    if (widget.existingEntry != null) {
      _weightController.text =
          widget.existingEntry!.weightKg.toString();
      _heightController.text =
          widget.existingEntry!.heightCm.toString();
      _bodyFatController.text =
          widget.existingEntry!.bodyFatPercent?.toString() ?? '';
      _muscleMassController.text =
          widget.existingEntry!.muscleMassKg?.toString() ?? '';
      _chestController.text =
          widget.existingEntry!.chestCm?.toString() ?? '';
      _waistController.text =
          widget.existingEntry!.waistCm?.toString() ?? '';
      _hipController.text =
          widget.existingEntry!.hipCm?.toString() ?? '';
      _armController.text =
          widget.existingEntry!.armCm?.toString() ?? '';
      _thighController.text =
          widget.existingEntry!.thighCm?.toString() ?? '';
      _notesController.text =
          widget.existingEntry!.notes?.toString() ?? '';

      _applyToGoals = widget.existingEntry!.autoApplyToGoals;
      // Show the advanced section if any optional fields were filled in.
      if (widget.existingEntry!.chestCm != null ||
          widget.existingEntry!.waistCm != null ||
          widget.existingEntry!.hipCm != null ||
          widget.existingEntry!.armCm != null ||
          widget.existingEntry!.thighCm != null) {
        _showAdvanced = true;
      }
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _bodyFatController.dispose();
    _muscleMassController.dispose();
    _notesController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipController.dispose();
    _armController.dispose();
    _thighController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final memberId = auth.currentUser?.linkedMemberId ?? '';

    if (memberId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(_isEditing ? 'Edit Body Progress Entry' : 'Log Body Progress')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.danger),
              const SizedBox(height: 16),
              Text(
                'No member ID found',
                style: TextStyle(fontSize: 18, color: context.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Please login as a member to log progress',
                style: TextStyle(color: context.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Body Progress Entry' : 'Log Body Progress'),
        backgroundColor: context.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Measurements section header — high contrast
              // against the light scaffold so users know where the
              // required fields begin.
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Basic Measurements',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Required fields are marked with a label above the input.',
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Basic Measurements
              MeasurementInputRow(
                label: 'Weight',
                unit: 'kg',
                controller: _weightController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Weight is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              MeasurementInputRow(
                label: 'Height',
                unit: 'cm',
                controller: _heightController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Height is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              MeasurementInputRow(
                label: 'Body Fat %',
                unit: '%',
                controller: _bodyFatController,
                isOptional: true,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              MeasurementInputRow(
                label: 'Muscle Mass',
                unit: 'kg',
                controller: _muscleMassController,
                isOptional: true,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                  }
                  return null;
                },
              ),

              // Toggle Advanced Measurements — explicit textPrimary
              // and a primary-coloured chevron so the toggle reads
              // clearly in both light and dark mode.
              const SizedBox(height: 16),
              InkWell(
                onTap: () => setState(() => _showAdvanced = !_showAdvanced),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        _showAdvanced ? Icons.expand_less : Icons.expand_more,
                        color: context.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _showAdvanced
                              ? 'Hide Advanced Measurements'
                              : 'Show Advanced Measurements',
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Optional body measurements for more detailed tracking.',
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),

              // Advanced Measurements
              if (_showAdvanced) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Advanced Measurements',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                MeasurementInputRow(
                  label: 'Chest',
                  unit: 'cm',
                  controller: _chestController,
                  isOptional: true,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                MeasurementInputRow(
                  label: 'Waist',
                  unit: 'cm',
                  controller: _waistController,
                  isOptional: true,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                MeasurementInputRow(
                  label: 'Hip',
                  unit: 'cm',
                  controller: _hipController,
                  isOptional: true,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                MeasurementInputRow(
                  label: 'Arm',
                  unit: 'cm',
                  controller: _armController,
                  isOptional: true,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                MeasurementInputRow(
                  label: 'Thigh',
                  unit: 'cm',
                  controller: _thighController,
                  isOptional: true,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 24),
              // Section header for the notes block so the user has
              // a clear visual separator from the measurement inputs.
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Notes',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                style: TextStyle(color: context.textPrimary),
                decoration: InputDecoration(
                  hintText: 'How are you feeling? Any changes?',
                  hintStyle: TextStyle(color: context.textMuted),
                  labelText: 'Notes (Optional)',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelStyle: TextStyle(
                    color: context.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  floatingLabelStyle: TextStyle(
                    color: context.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  // Use the muted surface fill so the textarea
                  // visually separates from the white scaffold but
                  // stays inside the same colour family.
                  filled: true,
                  fillColor: context.surfaceAlt,
                  // Distinct border using the theme outline so the
                  // field reads as a real input on light backgrounds.
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Apply-to-goals toggle. Shows only when the member has
              // at least one automatic active goal that matches a
              // metric we can derive from this entry. Read it inline
              // (not in initState) so it reacts to state changes.
              _buildApplyToGoalsToggle(context, memberId),

              const SizedBox(height: 16),

              GradientButton(
                label: _isEditing ? 'Update Entry' : 'Save Progress Entry', // NEW: button copy switches with mode
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Fire-and-forget: the async work runs inside
                    // [_saveProgressEntry] which handles all the
                    // mounted/context guards.
                    _saveProgressEntry(memberId);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the apply-to-goals toggle. Reads the goal provider
  /// inline so it reflects the current `_applyToGoals` state and the
  /// member's latest goal list. Returns a hidden empty widget when the
  /// member has no automatic goals that match this entry's metric.
  Widget _buildApplyToGoalsToggle(BuildContext context, String memberId) {
    final provider = context.watch<GoalProvider>();
    final autoGoals = provider.getAutomaticGoalsForMember(memberId);
    if (autoGoals.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome,
              size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Apply to ${autoGoals.length} active goal${autoGoals.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Update the progress of your automatic goals based on this measurement.',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _applyToGoals,
                  onChanged: (v) => setState(() => _applyToGoals = v),
                  title: const Text(
                    'Apply to goals',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the [BodyProgressModel] from the controllers and persists it
  /// through [BodyProgressProvider.addEntry].
  ///
  /// The previous implementation kicked off the async save and then
  /// immediately called `Navigator.pop(context)` and
  /// `ScaffoldMessenger.of(context)`. Because the provider's `addEntry`
  /// awaits the repository save *and* uses the supplied `BuildContext`
  /// for subsequent `context.read(...)` / `ScaffoldMessenger.of(context)`
  /// calls, the original `context` was being used after the screen was
  /// already unmounted, which produced the
  /// "Looking up a deactivated widget's ancestor is unsafe" error.
  ///
  /// To fix this we:
  ///   1. Capture the [ScaffoldMessengerState] and the form's
  ///      [BuildContext] *before* the first `await` so we don't reach
  ///      for a deactivated context after the save completes.
  ///   2. `await` the provider's async save.
  ///   3. Guard every subsequent access to `this.context` with
  ///      `if (!mounted) return;` so we exit cleanly if the user has
  ///      already navigated away.
  ///   4. Wrap the whole flow in try / catch / finally so an error
  ///      during the save still surfaces a snackbar (when the widget is
  ///      still mounted) and never leaves the form in a broken state.
  Future<void> _saveProgressEntry(String memberId) async {
    // CHANGED: in edit mode we preserve the original id, date, and
    // loggedByTrainerId from the renamed `widget.existingEntry` so
    // the repository's updateEntry hits the same row instead of
    // creating a duplicate.
    final existing = widget.existingEntry;
    final entry = BodyProgressModel(
      id: existing?.id ?? '',
      memberId: memberId,
      loggedByTrainerId: existing?.loggedByTrainerId,
      date: existing?.date ?? DateTime.now(),
      weightKg: double.parse(_weightController.text),
      heightCm: double.parse(_heightController.text),
      bodyFatPercent: _bodyFatController.text.isNotEmpty
          ? double.tryParse(_bodyFatController.text)
          : null,
      muscleMassKg: _muscleMassController.text.isNotEmpty
          ? double.tryParse(_muscleMassController.text)
          : null,
      chestCm: _chestController.text.isNotEmpty
          ? double.tryParse(_chestController.text)
          : null,
      waistCm: _waistController.text.isNotEmpty
          ? double.tryParse(_waistController.text)
          : null,
      hipCm: _hipController.text.isNotEmpty
          ? double.tryParse(_hipController.text)
          : null,
      armCm: _armController.text.isNotEmpty
          ? double.tryParse(_armController.text)
          : null,
      thighCm: _thighController.text.isNotEmpty
          ? double.tryParse(_thighController.text)
          : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      // CHANGED: also copy any optional fields the form doesn't edit
      // so they aren't lost on round-trip.
      frontPhotoPath: existing?.frontPhotoPath,
      sidePhotoPath: existing?.sidePhotoPath,
      backPhotoPath: existing?.backPhotoPath,
      goalId: existing?.goalId,
      waterLitres: existing?.waterLitres,
      autoApplyToGoals: _applyToGoals,
    );

    // Capture messenger + nav handle *before* the await so we never
    // touch a deactivated context after the future resolves.
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      // CHANGED: route through addEntry / updateEntry depending on
      // whether we're editing an existing record.
      final provider = context.read<BodyProgressProvider>();
      if (_isEditing) {
        await provider.updateEntry(entry, context);
      } else {
        await provider.addEntry(entry, context);
      }

      // ── Guard against the widget having been unmounted during the
      // await. If it has, the screen is gone and we have nothing to
      // pop or snack on.
      if (!mounted) return;

      // Navigate back first so the snackbar surfaces on the parent
      // route rather than on the (about-to-be-popped) form.
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Progress entry updated successfully!'
                : 'Progress entry saved successfully!',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      // The widget may have been disposed while the save was in-flight.
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error saving progress: ${e.toString()}'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}