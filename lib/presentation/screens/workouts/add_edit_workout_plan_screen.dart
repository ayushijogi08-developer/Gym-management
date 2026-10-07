import 'package:flutter/material.dart';
import 'package:gym_management_app/data/models/member_model.dart';
import 'package:gym_management_app/presentation/widgets/app_dropdown_field.dart';
import 'package:provider/provider.dart';
import '../../../data/models/exercise_model.dart';
import '../../../providers/workout_plan_provider.dart';
import '../../../providers/member_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../../themes/app_spacing.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/exercise_edit_dialog.dart';
import '../../widgets/glass_container.dart';

class AddEditWorkoutPlanScreen extends StatefulWidget {
  final String? planId;
  const AddEditWorkoutPlanScreen({super.key, this.planId});

  @override
  State<AddEditWorkoutPlanScreen> createState() =>
      _AddEditWorkoutPlanScreenState();
}

class _AddEditWorkoutPlanScreenState extends State<AddEditWorkoutPlanScreen> {
  String? selectedMemberId;
  String category = 'Muscle Building';
  List<ExerciseModel> exercises = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberProvider>().loadMembers();
    });

    if (widget.planId != null) {
      final plan = context.read<WorkoutPlanProvider>().getById(widget.planId!);
      if (plan != null) {
        selectedMemberId = plan.memberId;
        category = plan.category;
        exercises = List.from(plan.exercises);
        return;
      }
    }
    exercises = List.generate(
        4,
        (index) => ExerciseModel(
              exerciseName: 'Exercise ${index + 1}',
              targetMuscle: 'Chest',
              sets: 4,
              reps: 12,
              restTimeSeconds: 60,
              difficulty: 'Intermediate',
            ));
  }

  @override
  Widget build(BuildContext context) {
    final members = context.watch<MemberProvider>().members;
    final selectedMember = members.firstWhere(
      (m) => m.id == selectedMemberId,
      orElse: () => MemberModel(
        id: '',
        fullName: '',
        gender: '',
        phone: '',
        email: '',
        membershipStatus: '',
        planName: '',
        joiningDate: DateTime.now(),
        expiryDate: DateTime.now(),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.planId == null
            ? 'Create Workout Plan'
            : 'Edit Workout Plan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassContainer(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Autocomplete<String>(
                    initialValue: TextEditingValue(
                      text: selectedMemberId == null || members.isEmpty
                          ? ''
                          : selectedMember.fullName,
                    ),
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return members.map((m) => m.fullName);
                      }
                      return members
                          .where((m) => m.fullName
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()))
                          .map((m) => m.fullName);
                    },
                    onSelected: (String selectedName) {
                      final member =
                          members.firstWhere((m) => m.fullName == selectedName);
                      setState(() => selectedMemberId = member.id);
                    },
                    fieldViewBuilder:
                        (context, textController, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: textController,
                        focusNode: focusNode,
                        style: TextStyle(
                            color: context.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Member',
                          labelStyle: TextStyle(color: context.textSecondary),
                          filled: true,
                          fillColor: context.surfaceAlt,
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
                            borderSide: BorderSide(
                                color: context.colors.primary, width: 1.5),
                          ),
                          prefixIcon: Icon(Icons.person_outline,
                              color: context.textSecondary),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppDropdownField<String>(
                    label: 'Category',
                    value: category,
                    items: const [
                      'Muscle Building',
                      'Strength',
                      'Fat Loss',
                      'HIIT',
                      'Cardio'
                    ],
                    itemLabel: (v) => v,
                    onChanged: (v) => setState(() => category = v!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Text(
                    'Exercises',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${exercises.length}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...exercises.map((ex) => _buildExerciseTile(ex, ex.exerciseName)),
            const SizedBox(height: AppSpacing.sm),
            // Add exercise button
            InkWell(
              onTap: _addNewExercise,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.border,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: context.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Add Exercise',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            GradientButton(
              label: widget.planId == null
                  ? 'Create Workout Plan'
                  : 'Update Workout Plan',
              onPressed: () {
                if (selectedMemberId == null) return;
                final provider = context.read<WorkoutPlanProvider>();
                if (widget.planId == null) {
                  provider.createWorkoutPlan(
                    memberId: selectedMemberId!,
                    category: category,
                    exercises: exercises,
                    context: context,
                  );
                } else {
                  provider.updateWorkoutPlan(
                    planId: widget.planId!,
                    memberId: selectedMemberId!,
                    category: category,
                    exercises: exercises,
                  );
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addNewExercise() {
    setState(() {
      exercises.add(ExerciseModel(
        exerciseName: 'New Exercise',
        targetMuscle: 'Chest',
        sets: 3,
        reps: 12,
        restTimeSeconds: 60,
        difficulty: 'Beginner',
      ));
    });
  }

  Widget _buildExerciseTile(ExerciseModel ex, String key) {
    final difficultyColor = ex.difficulty.toLowerCase() == 'beginner'
        ? AppColors.success
        : ex.difficulty.toLowerCase() == 'advanced'
            ? Theme.of(context).colorScheme.error
            : AppColors.warning;

    return Container(
      key: ValueKey(key),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border),
      ),
      child: InkWell(
        onTap: () async {
          final updated = await showDialog<ExerciseModel>(
            context: context,
            builder: (_) => ExerciseEditDialog(exercise: ex),
          );
          if (updated != null && mounted) {
            setState(() {
              final index = exercises.indexOf(ex);
              if (index != -1) {
                exercises[index] = updated;
              }
            });
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.fitness_center_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ex.exerciseName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${ex.sets}×${ex.reps} • ${ex.targetMuscle}',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: difficultyColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  ex.difficulty,
                  style: TextStyle(
                    color: difficultyColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
                tooltip: 'Remove',
                onPressed: () => setState(() => exercises.remove(ex)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
