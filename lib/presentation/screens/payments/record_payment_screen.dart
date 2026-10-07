import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/plan_provider.dart';
import '../../../providers/payment_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../../themes/app_design_tokens.dart';
import '../../../themes/app_spacing.dart';
import '../../widgets/app_dropdown_field.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_button.dart';

class RecordPaymentScreen extends StatefulWidget {
  const RecordPaymentScreen({super.key, this.preselectedMemberId});

  /// Optional member id to preselect when the screen opens (e.g. when a member
  /// taps "Renew" from their dashboard).
  final String? preselectedMemberId;

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedMemberId;
  String? _selectedPlanId;
  String _paymentMethod = 'cash';
  String _status = 'completed';
  bool _isLoading = false;
  double _gstAmount = 0;
  double _discountAmount = 0;
  double _finalAmount = 0;

  final List<String> _paymentMethods = ['cash', 'card', 'upi', 'netBanking', 'wallet'];
  final List<String> _statusOptions = ['completed', 'pending'];
  final List<String> _paymentTypes = ['subscription', 'renewal', 'one_time', 'other'];

  String _paymentType = 'subscription';

  @override
  void initState() {
    super.initState();
    if (widget.preselectedMemberId != null &&
        widget.preselectedMemberId!.isNotEmpty) {
      _selectedMemberId = widget.preselectedMemberId;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberProvider>().loadMembers();
      context.read<PlanProvider>().loadPlans();
      if (_selectedMemberId != null) setState(() {});
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateAmounts() {
    if (_selectedPlanId == null) {
      _gstAmount = 0;
      _discountAmount = 0;
      _finalAmount = double.tryParse(_amountController.text) ?? 0;
      return;
    }

    final planProvider = context.read<PlanProvider>();
    final plan = planProvider.getPlanById(_selectedPlanId!);

    if (plan != null) {
      final baseAmount = double.tryParse(_amountController.text) ?? plan.price;
      _discountAmount = (baseAmount * (plan.discountPercent ?? 0)) / 100;
      _gstAmount = ((baseAmount - _discountAmount) * (plan.gstPercent ?? 0)) / 100;
      _finalAmount = baseAmount - _discountAmount + _gstAmount;

      setState(() {});
    }
  }

  Future<void> _recordPayment() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a member')),
      );
      return;
    }

    if (_selectedPlanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a plan')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthProvider>();
      final paymentProvider = context.read<PaymentProvider>();
      final planProvider = context.read<PlanProvider>();

      planProvider.getPlanById(_selectedPlanId!);
      final amount = double.parse(_amountController.text.trim());

      await paymentProvider.recordPayment(
        memberId: _selectedMemberId!,
        subscriptionId: null,
        amount: amount,
        method: _paymentMethod,
        gstAmount: _gstAmount,
        discountApplied: _discountAmount,
        notes: _notesController.text.trim(),
        status: _status,
        auth: auth,
        context: context,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Payment recorded successfully!')),
        );

        if (_paymentType == 'subscription' || _paymentType == 'renewal') {
          await _createSubscription();
        }

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createSubscription() async {
    try {
      final planProvider = context.read<PlanProvider>();
      final subscriptionProvider = context.read<SubscriptionProvider>();
      final plan = planProvider.getPlanById(_selectedPlanId!);

      if (plan != null && _selectedMemberId != null) {
        await subscriptionProvider.createSubscription(
          memberId: _selectedMemberId!,
          planId: plan.id,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: plan.durationInDays)),
          status: 'active',
          context: context,
        );
      }
    } catch (e) {
      debugPrint('Error creating subscription: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final memberProvider = context.watch<MemberProvider>();
    final planProvider = context.watch<PlanProvider>();
    final selectedPlan = _selectedPlanId != null
        ? planProvider.getPlanById(_selectedPlanId!)
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Record Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Consumer<MemberProvider>(
                  builder: (context, provider, _) {
                    final members = provider.members;

                    if (members.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: Text(
                          'No members found. Please add members first.',
                          style: TextStyle(
                            color: context.danger,
                          ),
                        ),
                      );
                    }

                    return AppDropdownField<String>(
                      label: 'Select Member',
                      value: _selectedMemberId,
                      items: members.map((m) => m.id).toList(),
                      itemLabel: (id) {
                        try {
                          final member =
                              members.firstWhere((m) => m.id == id);
                          return '${member.fullName} (${member.phone})';
                        } catch (e) {
                          return 'Unknown Member';
                        }
                      },
                      onChanged: (v) => setState(() {
                        _selectedMemberId = v;
                        if (_selectedPlanId != null) {
                          final plan =
                              planProvider.getPlanById(_selectedPlanId!);
                          if (plan != null) {
                            _amountController.text = plan.price.toString();
                            _updateAmounts();
                          }
                        }
                      }),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                Consumer<PlanProvider>(
                  builder: (context, provider, _) {
                    final plans = provider.plans;

                    if (plans.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: Text(
                          'No plans found. Please add plans first.',
                          style: TextStyle(
                            color: context.danger,
                          ),
                        ),
                      );
                    }

                    return AppDropdownField<String>(
                      label: 'Select Plan',
                      value: _selectedPlanId,
                      items: plans.map((p) => p.id).toList(),
                      itemLabel: (id) {
                        try {
                          final plan = plans.firstWhere((p) => p.id == id);
                          return '${plan.planName} - ₹${plan.price}';
                        } catch (e) {
                          return 'Unknown Plan';
                        }
                      },
                      onChanged: (v) => setState(() {
                        _selectedPlanId = v;
                        if (v != null) {
                          final plan = provider.getPlanById(v);
                          if (plan != null) {
                            _amountController.text = plan.price.toString();
                            _updateAmounts();
                          }
                        }
                      }),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                if (selectedPlan != null)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: context.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: context.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plan Details',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _buildPlanDetailRow(
                            'Plan', selectedPlan.planName),
                        _buildPlanDetailRow('Duration',
                            '${selectedPlan.durationInDays} days'),
                        _buildPlanDetailRow(
                            'Base Price', '₹${selectedPlan.price}'),
                        if (selectedPlan.discountPercent != null &&
                            selectedPlan.discountPercent! > 0)
                          _buildPlanDetailRow('Discount',
                              '${selectedPlan.discountPercent}%',
                              color: context.success),
                        if (selectedPlan.gstPercent != null &&
                            selectedPlan.gstPercent! > 0)
                          _buildPlanDetailRow('GST',
                              '${selectedPlan.gstPercent}%',
                              color: context.warning),
                        Divider(color: context.border),
                        _buildPlanDetailRow(
                          'Final Price',
                          '₹${selectedPlan.finalPrice.toStringAsFixed(2)}',
                          color: context.success,
                          isBold: true,
                        ),
                      ],
                    ),
                  ),

                AppDropdownField<String>(
                  label: 'Payment Type',
                  value: _paymentType,
                  items: _paymentTypes,
                  itemLabel: (v) => v.toUpperCase().replaceAll('_', ' '),
                  onChanged: (v) => setState(() => _paymentType = v!),
                ),
                const SizedBox(height: AppSpacing.lg),

                AppTextField(
                  label: 'Amount (₹)',
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _updateAmounts(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Amount is required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid amount';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                AppDropdownField<String>(
                  label: 'Payment Method',
                  value: _paymentMethod,
                  items: _paymentMethods,
                  itemLabel: (v) => v.toUpperCase(),
                  onChanged: (v) => setState(() => _paymentMethod = v!),
                ),
                const SizedBox(height: AppSpacing.lg),

                AppDropdownField<String>(
                  label: 'Status',
                  value: _status,
                  items: _statusOptions,
                  itemLabel: (v) => v.toUpperCase(),
                  onChanged: (v) => setState(() => _status = v!),
                ),
                const SizedBox(height: AppSpacing.lg),

                AppTextField(
                  label: 'Notes (Optional)',
                  controller: _notesController,
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.xl),

                if (_gstAmount > 0 || _discountAmount > 0)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.border),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                            'Subtotal',
                            _amountController.text.isNotEmpty
                                ? double.parse(_amountController.text)
                                : 0),
                        if (_discountAmount > 0)
                          _buildSummaryRow('Discount', -_discountAmount,
                              color:
                                  context.success),
                        if (_gstAmount > 0)
                          _buildSummaryRow('GST', _gstAmount,
                              color: context.warning),
                        Divider(color: context.border),
                        _buildSummaryRow('Total', _finalAmount,
                            isBold: true,
                            color:
                                context.success),
                      ],
                    ),
                  ),

                GradientButton(
                  label: 'Record Payment',
                  isLoading: _isLoading,
                  onPressed: _recordPayment,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanDetailRow(String label, String value,
      {Color? color, bool isBold = false}) {
    final textColor = color ?? context.textPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: context.textSecondary, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value,
      {Color? color, bool isBold = false}) {
    final textColor = color ?? context.textPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: context.textSecondary, fontSize: 13)),
          Text(
            '₹${value.toStringAsFixed(2)}',
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}