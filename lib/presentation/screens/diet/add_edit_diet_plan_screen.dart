import 'package:flutter/material.dart';
import 'package:gym_management_app/presentation/widgets/app_dropdown_field.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/diet_plan_model.dart';
import '../../../data/models/meal_model.dart';
import '../../../providers/diet_plan_provider.dart';
import '../../../providers/member_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../../themes/app_spacing.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/glass_container.dart';

class AddEditDietPlanScreen extends StatefulWidget {
  final String? planId;
  const AddEditDietPlanScreen({super.key, this.planId});

  @override
  State<AddEditDietPlanScreen> createState() => _AddEditDietPlanScreenState();
}

class _AddEditDietPlanScreenState extends State<AddEditDietPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedMemberId;
  String category = 'General Fitness';
  List<MealModel> meals = [];
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  // Per-meal controllers
  late List<TextEditingController> _mealNameControllers;
  late List<TextEditingController> _foodItemsControllers;
  late List<TextEditingController> _quantityControllers;
  late List<TextEditingController> _caloriesControllers;
  late List<TextEditingController> _proteinControllers;
  late List<TextEditingController> _carbsControllers;
  late List<TextEditingController> _fatsControllers;
  late List<TextEditingController> _waterControllers;

  final List<String> _mealTypes = [
    'Breakfast',
    'Morning Snack',
    'Lunch',
    'Evening Snack',
    'Pre Workout',
    'Post Workout',
    'Dinner',
    'Bedtime'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberProvider>().loadMembers();

      if (widget.planId != null) {
        _loadExistingPlan();
      } else {
        _initDefaultMeals();
        _initControllersFromMeals();
      }
    });
  }

  void _initDefaultMeals() {
    meals = _mealTypes
        .map((type) => MealModel(
              mealType: type,
              mealName: '$type Meal',
              foodItems: ['Example Food'],
              quantity: '1 serving',
              calories: 400,
              protein: 20,
              carbs: 50,
              fats: 15,
              waterIntakeMl: 200,
            ))
        .toList();
  }

  void _initControllersFromMeals() {
    _mealNameControllers =
        meals.map((m) => TextEditingController(text: m.mealName)).toList();
    _foodItemsControllers = meals
        .map((m) => TextEditingController(text: m.foodItems.join(', ')))
        .toList();
    _quantityControllers =
        meals.map((m) => TextEditingController(text: m.quantity)).toList();
    _caloriesControllers = meals
        .map((m) => TextEditingController(text: m.calories.toString()))
        .toList();
    _proteinControllers = meals
        .map((m) => TextEditingController(text: m.protein.toString()))
        .toList();
    _carbsControllers = meals
        .map((m) => TextEditingController(text: m.carbs.toString()))
        .toList();
    _fatsControllers = meals
        .map((m) => TextEditingController(text: m.fats.toString()))
        .toList();
    _waterControllers = meals
        .map((m) =>
            TextEditingController(text: (m.waterIntakeMl ?? 0).toString()))
        .toList();
  }

  @override
  void dispose() {
    for (final c in [
      ..._mealNameControllers,
      ..._foodItemsControllers,
      ..._quantityControllers,
      ..._caloriesControllers,
      ..._proteinControllers,
      ..._carbsControllers,
      ..._fatsControllers,
      ..._waterControllers,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadExistingPlan() async {
    final dietProvider = context.read<DietPlanProvider>();
    final plan = dietProvider.plans.firstWhere(
      (p) => p.id == widget.planId,
      orElse: () => DietPlanModel(
        id: '',
        memberId: '',
        createdByTrainerId: '',
        category: '',
        meals: [],
        dailyCalorieTarget: 0,
        dailyProteinTarget: 0,
        dailyWaterTargetMl: 0,
      ),
    );

    if (plan.id.isNotEmpty) {
      setState(() {
        selectedMemberId = plan.memberId;
        category = plan.category;
        meals = List.from(plan.meals);
        _startDate = plan.startDate;
        _endDate = plan.endDate;
      });
      _initControllersFromMeals();
    } else {
      _initDefaultMeals();
      _initControllersFromMeals();
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.planId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Diet Plan' : 'Create Diet Plan',
          style: TextStyle(color: context.textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
              tooltip: 'Delete plan',
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: context.colors.primary),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Saving diet plan…',
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
                      Consumer<MemberProvider>(
                        builder: (context, memberProvider, _) {
                          final members = memberProvider.members;

                          if (members.isEmpty) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.md),
                              child: Text(
                                "No members found. Please add members first.",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            );
                          }

                          return AppDropdownField<String>(
                            label: 'Assign to Member',
                            value: selectedMemberId,
                            items: members.map((m) => m.id).toList(),
                            itemLabel: (id) {
                              try {
                                return members
                                    .firstWhere((m) => m.id == id)
                                    .fullName;
                              } catch (_) {
                                return 'Unknown Member';
                              }
                            },
                            onChanged: (v) =>
                                setState(() => selectedMemberId = v),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppDropdownField<String>(
                        label: 'Diet Category',
                        value: category,
                        items: const [
                          'Weight Loss',
                          'Muscle Gain',
                          'Fat Loss',
                          'General Fitness',
                          'Athletic Performance',
                          'Keto',
                          'Vegan',
                          'Vegetarian'
                        ],
                        itemLabel: (v) => v,
                        onChanged: (v) => setState(() => category = v!),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildDateRangePicker(),
                      const SizedBox(height: AppSpacing.md),
                      _buildQuickStats(),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Meals (${meals.length} Slots)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Tap on each meal to customize food items and nutrition',
                        style: TextStyle(
                            color: context.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...List.generate(meals.length, (index) {
                        return _buildMealCard(index, meals[index]);
                      }),
                      const SizedBox(height: AppSpacing.lg),
                      GradientButton(
                        label:
                            isEditing ? 'Update Diet Plan' : 'Save Diet Plan',
                        isLoading: _isLoading,
                        onPressed: _saveDietPlan,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDateRangePicker() {
    return GestureDetector(
      onTap: _selectDateRange,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.border),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                color: AppColors.primary, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plan Duration',
                    style: TextStyle(
                        color: context.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _startDate != null && _endDate != null
                        ? '${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}'
                        : 'Select date range (Optional)',
                    style: TextStyle(
                      color: (_startDate != null)
                          ? context.textPrimary
                          : context.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_startDate != null && _endDate != null)
                    Text(
                      '${_endDate!.difference(_startDate!).inDays + 1} days',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: context.textMuted, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final totalCalories = meals.fold(0.0, (sum, m) => sum + m.calories);
    final totalProtein = meals.fold(0.0, (sum, m) => sum + m.protein);
    final totalWater = meals.fold(0, (sum, m) => sum + (m.waterIntakeMl ?? 0));
    final totalCarbs = meals.fold(0.0, (sum, m) => sum + m.carbs);
    final totalFats = meals.fold(0.0, (sum, m) => sum + m.fats);

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatChip(
                '🔥 ${totalCalories.toInt()} kcal', AppColors.warning),
            const SizedBox(width: AppSpacing.xs),
            _buildStatChip(
                '💪 ${totalProtein.toInt()}g Protein', AppColors.success),
            const SizedBox(width: AppSpacing.xs),
            _buildStatChip(
                '💧 ${totalWater}ml Water', AppColors.primary),
            const SizedBox(width: AppSpacing.xs),
            _buildStatChip(
                '🍞 ${totalCarbs.toInt()}g Carbs', AppColors.accent),
            const SizedBox(width: AppSpacing.xs),
            _buildStatChip('🧈 ${totalFats.toInt()}g Fats',
                Theme.of(context).colorScheme.error),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String text, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMealCard(int index, MealModel meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border),
      ),
      child: Theme(
        // Remove default ExpansionTile divider lines
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding:
              const EdgeInsets.fromLTRB(14, 0, 14, AppSpacing.md),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          title: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.mealType,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${meal.calories.toInt()} kcal • ${meal.protein.toInt()}g protein',
                      style: TextStyle(
                          color: context.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: [
            AppTextField(
              label: 'Meal Name',
              controller: _mealNameControllers[index],
              onChanged: (v) => meal.mealName = v,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: 'Food Items (comma separated)',
              controller: _foodItemsControllers[index],
              onChanged: (v) => meal.foodItems =
                  v.split(',').map((e) => e.trim()).toList(),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: 'Quantity',
              controller: _quantityControllers[index],
              onChanged: (v) => meal.quantity = v,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Calories',
                    keyboardType: TextInputType.number,
                    controller: _caloriesControllers[index],
                    onChanged: (v) =>
                        meal.calories = double.tryParse(v) ?? 0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Protein (g)',
                    keyboardType: TextInputType.number,
                    controller: _proteinControllers[index],
                    onChanged: (v) =>
                        meal.protein = double.tryParse(v) ?? 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Carbs (g)',
                    keyboardType: TextInputType.number,
                    controller: _carbsControllers[index],
                    onChanged: (v) => meal.carbs = double.tryParse(v) ?? 0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Fats (g)',
                    keyboardType: TextInputType.number,
                    controller: _fatsControllers[index],
                    onChanged: (v) => meal.fats = double.tryParse(v) ?? 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: 'Water Intake (ml)',
              keyboardType: TextInputType.number,
              controller: _waterControllers[index],
              onChanged: (v) =>
                  meal.waterIntakeMl = int.tryParse(v) ?? 0,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDietPlan() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a member')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dietProvider = context.read<DietPlanProvider>();

      if (widget.planId != null) {
        final existingPlan = dietProvider.plans.firstWhere(
          (p) => p.id == widget.planId,
        );

        existingPlan.memberId = selectedMemberId!;
        existingPlan.category = category;
        existingPlan.meals = meals;
        existingPlan.startDate = _startDate;
        existingPlan.endDate = _endDate;

        await dietProvider.updateDietPlan(existingPlan);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Diet plan updated successfully!')),
          );
        }
      } else {
        await dietProvider.createDietPlan(
          memberId: selectedMemberId!,
          category: category,
          meals: meals,
          context: context,
          startDate: _startDate,
          endDate: _endDate,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error saving diet plan: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.delete_outline_rounded,
            color: Theme.of(context).colorScheme.error, size: 32),
        title: const Text('Delete Diet Plan?'),
        content: const Text(
          'Are you sure you want to delete this diet plan? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor:
                  Theme.of(context).colorScheme.errorContainer,
              foregroundColor:
                  Theme.of(context).colorScheme.onErrorContainer,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isLoading = true);
      final dietProvider = context.read<DietPlanProvider>();
      final planId = widget.planId!;
      try {
        await dietProvider.deleteDietPlan(planId, context);
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete diet plan')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}
