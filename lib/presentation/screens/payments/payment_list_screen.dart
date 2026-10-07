import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/payment_model.dart';
import '../../../providers/payment_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../themes/app_design_tokens.dart';
import '../../../themes/app_spacing.dart';
import '../../widgets/payment_card.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  String _searchQuery = '';
  String _statusFilter = 'All';
  String _dateFilter = 'All';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  bool _isLoading = true;

  final List<String> _statusOptions = ['All', 'Completed', 'Pending', 'Refunded'];
  final List<String> _dateOptions = ['All', 'Today', 'Yesterday', 'This Week', 'This Month', 'Custom'];

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    try {
      await context.read<PaymentProvider>().fetchPayments();
    } catch (e) {
      debugPrint('Error loading payments: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.hasPermission('canCollectPayments')) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline,
                  size: 64, color: context.textSecondary),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You do not have permission to view payments',
                style: TextStyle(color: context.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _loadPayments,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/record-payment'),
        child: const Icon(Icons.add_rounded),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: context.colors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Loading payments…',
                    style: TextStyle(color: context.textSecondary),
                  ),
                ],
              ),
            )
          : Consumer<PaymentProvider>(
              builder: (context, paymentProvider, child) {
                final allPayments = paymentProvider.allPayments;

                final totalCollected = allPayments
                    .where((p) => p.status.toLowerCase() == 'completed')
                    .fold<double>(0, (sum, p) => sum + p.amount);

                final totalPending = allPayments
                    .where((p) => p.status.toLowerCase() == 'pending')
                    .fold<double>(0, (sum, p) => sum + p.amount);

                final today = DateTime.now();
                final todayPayments = allPayments.where((p) {
                  final d = p.paymentDate;
                  return d.year == today.year &&
                      d.month == today.month &&
                      d.day == today.day &&
                      p.status.toLowerCase() == 'completed';
                }).toList();
                final todayTotal =
                    todayPayments.fold<double>(0, (sum, p) => sum + p.amount);

                List<PaymentModel> payments = List.from(allPayments);

                if (_statusFilter != 'All') {
                  payments = payments
                      .where((p) =>
                          p.status.toLowerCase() == _statusFilter.toLowerCase())
                      .toList();
                }

                if (_dateFilter != 'All') {
                  payments = payments.where((p) {
                    final paymentDate = DateTime(
                        p.paymentDate.year, p.paymentDate.month, p.paymentDate.day);

                    switch (_dateFilter) {
                      case 'Today':
                        final d = DateTime(today.year, today.month, today.day);
                        return paymentDate == d;
                      case 'Yesterday':
                        final y = today.subtract(const Duration(days: 1));
                        final d = DateTime(y.year, y.month, y.day);
                        return paymentDate == d;
                      case 'This Week':
                        final weekAgo = today.subtract(const Duration(days: 7));
                        return paymentDate.isAfter(
                          DateTime(weekAgo.year, weekAgo.month, weekAgo.day),
                        );
                      case 'This Month':
                        final monthAgo = today.subtract(const Duration(days: 30));
                        return paymentDate.isAfter(
                          DateTime(monthAgo.year, monthAgo.month, monthAgo.day),
                        );
                      case 'Custom':
                        final start = DateTime(
                            _startDate.year, _startDate.month, _startDate.day);
                        final end = DateTime(
                          _endDate.year,
                          _endDate.month,
                          _endDate.day,
                          23,
                          59,
                          59,
                        );
                        return !paymentDate.isBefore(start) &&
                            !paymentDate.isAfter(end);
                      default:
                        return true;
                    }
                  }).toList();
                }

                if (_searchQuery.isNotEmpty) {
                  final query = _searchQuery.toLowerCase();
                  payments = payments.where((p) {
                    return p.invoiceNumber.toLowerCase().contains(query) ||
                        p.memberId.toLowerCase().contains(query);
                  }).toList();
                }

                payments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

                return Column(
                  children: [
                    _buildSummaryBar(
                      totalCollected: totalCollected,
                      todayTotal: todayTotal,
                      totalPending: totalPending,
                    ),
                    _buildSearchBar(),
                    _buildFilterRow(),
                    Expanded(
                      child: payments.isEmpty
                          ? _buildEmptyState()
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl),
                              itemCount: payments.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final payment = payments[index];
                                return PaymentCard(
                                  payment: payment,
                                  onTap: () =>
                                      context.push('/invoice/${payment.id}'),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  // ─────────────────────────  UI parts  ─────────────────────────

  Widget _buildSummaryBar({
    required double totalCollected,
    required double todayTotal,
    required double totalPending,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
      child: Row(
        children: [
          _summaryChip(
            label: 'Total',
            amount: totalCollected,
            icon: Icons.account_balance_wallet_outlined,
            accent: context.primary,
          ),
          const SizedBox(width: 8),
          _summaryChip(
            label: 'Today',
            amount: todayTotal,
            icon: Icons.today_outlined,
            accent: context.accent,
          ),
          const SizedBox(width: 8),
          _summaryChip(
            label: 'Pending',
            amount: totalPending,
            icon: Icons.pending_actions_outlined,
            accent: context.warning,
          ),
        ],
      ),
    );
  }

  Widget _summaryChip({
    required String label,
    required double amount,
    required IconData icon,
    required Color accent,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.border),
          boxShadow: AppShadows.of(context).elevation1,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: accent),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: context.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${amount.toStringAsFixed(0)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        style: TextStyle(color: context.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search by invoice or member',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: context.textSecondary,
            size: 20,
          ),
          filled: true,
          fillColor: context.surfaceAlt,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: context.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: context.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: context.colors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Status chip row: takes the bulk of remaining space and scrolls
          // horizontally if the screen is narrow.
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statusOptions.map((status) {
                  final selected = _statusFilter == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _statusFilter = status),
                      child: AnimatedContainer(
                        duration: AppMotion.base,
                        curve: AppMotion.ease,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: selected
                              ? context.primary.withValues(alpha: 0.12)
                              : context.surface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: selected
                                ? context.primary
                                : context.border,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            color: selected
                                ? context.primary
                                : context.textPrimary,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Date dropdown: bounded Flexible so it can shrink but never collapse
          // below its content width; ensures the "All / Today / Custom" labels
          // remain legible and the trailing clear button stays visible.
          Flexible(
            flex: 3,
            fit: FlexFit.loose,
            child: DropdownButtonHideUnderline(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: context.border),
                ),
                child: DropdownButton<String>(
                  value: _dateFilter,
                  isExpanded: true,
                  dropdownColor: context.surface,
                  iconEnabledColor: context.textSecondary,
                  style: TextStyle(color: context.textPrimary, fontSize: 12),
                  selectedItemBuilder: (context) {
                    return _dateOptions.map((option) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          option,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList();
                  },
                  items: _dateOptions.map((option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(
                        option,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    if (value == null) return;
                    if (value == 'Custom') {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: DateTimeRange(
                          start: _startDate,
                          end: _endDate,
                        ),
                      );
                      if (picked != null) {
                        setState(() {
                          _dateFilter = 'Custom';
                          _startDate = picked.start;
                          _endDate = picked.end;
                        });
                      }
                    } else {
                      setState(() {
                        _dateFilter = value;
                        _updateDateRange(value);
                      });
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            visualDensity: VisualDensity.compact,
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _statusFilter = 'All';
                _dateFilter = 'All';
              });
            },
            icon: Icon(
              Icons.filter_alt_off_rounded,
              size: 20,
              color: context.textSecondary,
            ),
            tooltip: 'Clear filters',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 36,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No payments found',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try changing filters or add a new payment.',
              style: TextStyle(color: context.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _updateDateRange(String filter) {
    final now = DateTime.now();
    switch (filter) {
      case 'Today':
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'Yesterday':
        final y = now.subtract(const Duration(days: 1));
        _startDate = DateTime(y.year, y.month, y.day);
        _endDate = DateTime(y.year, y.month, y.day, 23, 59, 59);
        break;
      case 'This Week':
        _startDate = now.subtract(const Duration(days: 7));
        _endDate = now;
        break;
      case 'This Month':
        _startDate = now.subtract(const Duration(days: 30));
        _endDate = now;
        break;
      default:
        break;
    }
  }
}