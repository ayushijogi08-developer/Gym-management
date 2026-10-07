import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/models/gym_config_model.dart';
import '../../../data/models/member_model.dart';
import '../../../domain/entities/user_role.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/gym_config_provider.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/plan_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../../providers/trainer_provider.dart';
import '../../../themes/app_design_tokens.dart';
import '../../../themes/app_spacing.dart';
import '../../../utils/subscription_status_helper.dart';
import '../../widgets/premium_filter_chip.dart';
import '../../widgets/theme_toggle_button.dart';
import 'add_edit_member_screen.dart';

/// Premium member directory. Uses the new design tokens:
/// `context.surface` / `context.textPrimary` / `context.border` / etc.
/// so it renders correctly in both light and dark without any per-mode
/// branching.
///
/// Layout:
///   • 64dp top bar w/ translucent surface + 1px hairline.
///   • Search bar with focus-ring (primary at 1.5px).
///   • Filter strip: branch dropdown + status chips (PremiumFilterChip).
///   • Member cards in a list with hover lift on web/desktop.
///   • Action icon-buttons with hover states.
///   • Delete dialog uses the themed DialogTheme.
class MemberListScreen extends StatefulWidget {
  final String? initialPlanFilter;
  final String? branchId;

  const MemberListScreen({super.key, this.initialPlanFilter, this.branchId});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';
  String? _selectedBranchId;
  bool _isLoading = true;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _selectedBranchId = widget.branchId;
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (_isDataLoaded) return;
    setState(() => _isLoading = true);
    try {
      final memberProvider = context.read<MemberProvider>();
      final trainerProvider = context.read<TrainerProvider>();
      final planProvider = context.read<PlanProvider>();
      final branchProvider = context.read<GymConfigProvider>();
      await Future.wait([
        memberProvider.loadMembers(),
        trainerProvider.loadTrainers(),
        planProvider.loadPlans(),
        branchProvider.loadConfig(forceRefresh: true),
      ]);
      _isDataLoaded = true;
    } catch (e) {
      debugPrint('❌ Error loading member data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    _isDataLoaded = false;
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final memberProvider = context.watch<MemberProvider>();
    final auth = context.watch<AuthProvider>();
    final trainerProvider = context.watch<TrainerProvider>();
    final subProvider = context.watch<SubscriptionProvider>();
    final planProvider = context.watch<PlanProvider>();
    final branchProvider = context.watch<GymConfigProvider>();

    final canResetPassword = auth.currentRole == UserRole.admin ||
        auth.currentRole == UserRole.superAdmin ||
        auth.currentRole == UserRole.receptionist;

    var members = memberProvider.members;

    if (widget.initialPlanFilter != null &&
        widget.initialPlanFilter!.isNotEmpty) {
      members = members
          .where((m) =>
              m.planName.toLowerCase() ==
              widget.initialPlanFilter!.toLowerCase())
          .toList();
    }
    if (_selectedBranchId != null) {
      members =
          members.where((m) => m.branchId == _selectedBranchId).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      members = members.where((m) {
        return m.fullName.toLowerCase().contains(query) ||
            m.phone.contains(query) ||
            m.email.toLowerCase().contains(query) ||
            m.planName.toLowerCase().contains(query);
      }).toList();
    }
    if (_statusFilter != 'All') {
      members = members.where((m) {
        final activeSub = subProvider.getActiveForMember(m.id);
        String status = m.membershipStatus.toLowerCase();
        if (activeSub != null) {
          status = SubscriptionStatusHelper.computeStatus(activeSub);
        }
        final filterLower = _statusFilter.toLowerCase().replaceAll(' ', '_');
        if (filterLower == 'active') return status == 'active';
        if (filterLower == 'expiring_soon') return status == 'expiring_soon';
        if (filterLower == 'expired') {
          return status == 'expired' || status == 'cancelled';
        }
        if (filterLower == 'paused') return status == 'paused';
        return true;
      }).toList();
    }

    final branches = branchProvider.config?.branches ?? [];
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 720;

    return Scaffold(
      appBar: AppBar(
        title: widget.initialPlanFilter != null
            ? Text('Members · ${widget.initialPlanFilter} Plan')
            : widget.branchId != null && branches.isNotEmpty
                ? Text(
                    'Members · ${branches.firstWhere((b) => b.id == widget.branchId, orElse: () => branches.first).name}')
                : const Text('Members & Subscriptions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search members',
            onPressed: () {
              showSearch(
                context: context,
                delegate: MemberSearchDelegate(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _refreshData,
          ),
          const ThemeToggleButton(),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditMemberScreen()),
          );
          _isDataLoaded = false;
          await _loadData();
        },
        icon: const Icon(Icons.person_add_rounded, size: 20),
        label: const Text('Add Member'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: context.colors.primary,
          onRefresh: _refreshData,
          child: Column(
            children: [
              // ─── Search & filter strip ────────────────────────────────
              Container(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: context.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: context.border.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search by name, email, phone or plan…',
                        hintStyle: TextStyle(
                          color: context.textSecondary,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: context.textSecondary,
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: context.textSecondary,
                                  size: 18,
                                ),
                                tooltip: 'Clear',
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: context.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: context.border, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: context.borderStrong, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: context.colors.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          if (branches.isNotEmpty) ...[
                            _BranchDropdown(
                              branches: branches,
                              value: _selectedBranchId,
                              onChanged: (v) =>
                                  setState(() => _selectedBranchId = v),
                            ),
                            const SizedBox(width: 8),
                          ],
                          for (final label in const [
                            'All',
                            'Active',
                            'Expiring Soon',
                            'Expired',
                            'Paused',
                          ]) ...[
                            PremiumFilterChip(
                              label: label,
                              isSelected: _statusFilter == label,
                              onTap: () =>
                                  setState(() => _statusFilter = label),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Main list area ───────────────────────────────────────
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                            color: context.colors.primary),
                      )
                    : members.isEmpty
                        ? _EmptyState(
                            hasFilters: _searchQuery.isNotEmpty ||
                                _statusFilter != 'All' ||
                                _selectedBranchId != null,
                            onReset: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _statusFilter = 'All';
                                _selectedBranchId = null;
                              });
                            },
                          )
                        : LayoutBuilder(builder: (context, constraints) {
                            final cardWidth = isCompact
                                ? constraints.maxWidth
                                : (constraints.maxWidth - 16) / 2;
                            return ListView.separated(
                              padding: EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                AppSpacing.md,
                                AppSpacing.lg,
                                AppSpacing.xxxl,
                              ),
                              itemCount: members.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final m = members[index];
                                return SizedBox(
                                  width: cardWidth,
                                  child: _MemberCard(
                                    member: m,
                                    canResetPassword: canResetPassword,
                                    trainerProvider: trainerProvider,
                                    subProvider: subProvider,
                                    planProvider: planProvider,
                                    branchProvider: branchProvider,
                                    onEdit: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              AddEditMemberScreen(
                                                  existingMember: m),
                                        ),
                                      );
                                      _isDataLoaded = false;
                                      await _loadData();
                                    },
                                    onDelete: () =>
                                        _confirmDelete(context, m),
                                    onResetPassword: () => context.push(
                                        '/reset-member-password?memberId=${m.id}'),
                                  ),
                                );
                              },
                            );
                          }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, MemberModel member) async {
    final memberProvider = context.read<MemberProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.delete_outline_rounded,
          color: Theme.of(ctx).colorScheme.error,
          size: 32,
        ),
        title: const Text('Delete Member?'),
        content: Text(
          'Are you sure you want to delete ${member.fullName}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.errorContainer,
              foregroundColor: Theme.of(ctx).colorScheme.onErrorContainer,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await memberProvider.deleteMember(member.id);
      _isDataLoaded = false;
      await _loadData();
      messenger.showSnackBar(
        const SnackBar(content: Text('Member deleted successfully')),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Branch dropdown
// ─────────────────────────────────────────────────────────────────────────────

class _BranchDropdown extends StatelessWidget {
  final List<BranchModel> branches;
  final String? value;
  final ValueChanged<String?> onChanged;
  const _BranchDropdown({
    required this.branches,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.business_rounded,
              size: 14, color: context.textSecondary),
          const SizedBox(width: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: value,
              hint: Text(
                'All Branches',
                style: TextStyle(
                  fontSize: 13,
                  color: context.textSecondary,
                ),
              ),
              dropdownColor: context.surface,
              icon: Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: context.textSecondary,
              ),
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    'All Branches',
                    style: TextStyle(color: context.textPrimary),
                  ),
                ),
                ...branches.map((b) => DropdownMenuItem<String?>(
                      value: b.id,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(b.name),
                          if (b.isMainBranch) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: context.colors.tertiary
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'MAIN',
                                style: TextStyle(
                                  color: context.colors.tertiary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )),
              ],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Member card
// ─────────────────────────────────────────────────────────────────────────────

class _MemberCard extends StatefulWidget {
  final MemberModel member;
  final bool canResetPassword;
  final TrainerProvider trainerProvider;
  final SubscriptionProvider subProvider;
  final PlanProvider planProvider;
  final GymConfigProvider branchProvider;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onResetPassword;

  const _MemberCard({
    required this.member,
    required this.canResetPassword,
    required this.trainerProvider,
    required this.subProvider,
    required this.planProvider,
    required this.branchProvider,
    required this.onEdit,
    required this.onDelete,
    required this.onResetPassword,
  });

  @override
  State<_MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<_MemberCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.member;
    final activeSub = widget.subProvider.getActiveForMember(m.id);
    String status = m.membershipStatus.toLowerCase();
    if (activeSub != null) {
      status = SubscriptionStatusHelper.computeStatus(activeSub);
    }
    final statusColor = SubscriptionStatusHelper.getStatusColor(status);

    final statusLabel = switch (status) {
      'active' => 'ACTIVE',
      'expiring_soon' => 'EXPIRING SOON',
      'grace_period' => 'GRACE PERIOD',
      'expired' => 'EXPIRED',
      'paused' => 'PAUSED',
      'cancelled' => 'CANCELLED',
      _ => m.membershipStatus.toUpperCase(),
    };

    String planName = m.planName;
    if (activeSub != null) {
      final p = widget.planProvider.getPlanById(activeSub.planId);
      if (p != null && p.planName.isNotEmpty) planName = p.planName;
    }
    if (planName.isEmpty) planName = 'No Active Plan';

    final expiryDate = activeSub?.endDate ?? m.expiryDate;
    final formattedExpiry = DateFormat('MMM dd, yyyy').format(expiryDate);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final exp = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final daysRemaining = exp.difference(today).inDays;
    final remainingText = daysRemaining < 0
        ? 'Expired ${daysRemaining.abs()} ${daysRemaining.abs() == 1 ? 'day' : 'days'} ago'
        : daysRemaining == 0
            ? 'Expires Today'
            : '$daysRemaining ${daysRemaining == 1 ? 'day' : 'days'} left';
    final remainingIsWarning = daysRemaining <= 7;

    String branchName = 'Unassigned';
    final branches = widget.branchProvider.config?.branches ?? [];
    if (m.branchId != null && m.branchId!.isNotEmpty) {
      try {
        branchName = branches
            .firstWhere((b) => b.id == m.branchId)
            .name;
      } catch (_) {
        branchName = 'Unassigned';
      }
    }

    String trainerName = 'Not Assigned';
    if (m.assignedTrainerId != null && m.assignedTrainerId!.isNotEmpty) {
      try {
        trainerName = widget.trainerProvider.trainers
            .firstWhere((t) => t.id == m.assignedTrainerId)
            .fullName;
      } catch (_) {
        trainerName = 'Assigned';
      }
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: AppMotion.base,
        curve: AppMotion.ease,
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hovered
                ? context.colors.primary.withValues(alpha: 0.5)
                : context.borderStrong,
            width: _hovered ? 1.5 : 1,
          ),
          boxShadow: _hovered
              ? AppShadows.of(context).elevation2
              : AppShadows.of(context).elevation1,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: avatar + name + status
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      m.fullName.isNotEmpty
                          ? m.fullName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 18,
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.fullName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.star_rounded,
                                size: 14, color: context.accentMuted),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                planName,
                                style: TextStyle(
                                  color: context.accentMuted,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.business_rounded,
                                size: 12, color: context.textSecondary),
                            const SizedBox(width: 4),
                            Flexible(
                              fit: FlexFit.loose,
                              child: Text(
                                branchName,
                                style: TextStyle(
                                  color: context.textSecondary,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: _StatusPill(label: statusLabel, color: statusColor),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              Divider(color: context.border, height: 1),
              const SizedBox(height: 12),

              // Contact row
              _ContactRow(
                icon: Icons.phone_outlined,
                value: m.phone,
              ),
              const SizedBox(height: 6),
              _ContactRow(
                icon: Icons.email_outlined,
                value: m.email,
              ),
              if (trainerName != 'Not Assigned') ...[
                const SizedBox(height: 6),
                _ContactRow(
                  icon: Icons.fitness_center_rounded,
                  value: trainerName,
                ),
              ],

              const SizedBox(height: 14),
              Divider(color: context.border, height: 1),
              const SizedBox(height: 12),

              // Footer: expiry + actions
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.event_outlined,
                            size: 14, color: context.textSecondary),
                        const SizedBox(width: 6),
                        Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            'Expires $formattedExpiry',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          fit: FlexFit.loose,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (remainingIsWarning
                                      ? Theme.of(context).colorScheme.error
                                      : Theme.of(context).colorScheme.tertiary)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              remainingText,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: remainingIsWarning
                                    ? Theme.of(context).colorScheme.error
                                    : Theme.of(context).colorScheme.tertiary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _CardActions(
                    canResetPassword: widget.canResetPassword,
                    onEdit: widget.onEdit,
                    onDelete: widget.onDelete,
                    onResetPassword: widget.onResetPassword,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small building blocks
// ─────────────────────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String value;
  const _ContactRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: context.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CardActions extends StatelessWidget {
  final bool canResetPassword;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onResetPassword;
  const _CardActions({
    required this.canResetPassword,
    required this.onEdit,
    required this.onDelete,
    required this.onResetPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (canResetPassword)
          _ActionButton(
            icon: Icons.lock_reset_rounded,
            color: Theme.of(context).colorScheme.tertiary,
            tooltip: 'Reset password',
            onTap: onResetPassword,
          ),
        _ActionButton(
          icon: Icons.edit_rounded,
          color: context.colors.primary,
          tooltip: 'Edit',
          onTap: onEdit,
        ),
        _ActionButton(
          icon: Icons.delete_outline_rounded,
          color: Theme.of(context).colorScheme.error,
          tooltip: 'Delete',
          onTap: onDelete,
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            padding: const EdgeInsets.all(7),
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
              color: _hovered
                  ? widget.color.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(widget.icon, size: 18, color: widget.color),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onReset;
  const _EmptyState({required this.hasFilters, required this.onReset});

  @override
  Widget build(BuildContext context) {
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
                Icons.people_outline_rounded,
                size: 36,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters
                  ? 'No members match your filters'
                  : 'No members yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasFilters
                  ? 'Try adjusting the search or status filter.'
                  : 'Add your first member to get started.',
              style: TextStyle(
                fontSize: 13,
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Reset filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search delegate (themed)
// ─────────────────────────────────────────────────────────────────────────────

class MemberSearchDelegate extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) =>
      Theme.of(context).copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
        ),
      );

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear_rounded),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final members = context.read<MemberProvider>().members.where((m) {
      return m.fullName.toLowerCase().contains(query.toLowerCase()) ||
          m.phone.contains(query) ||
          m.email.toLowerCase().contains(query.toLowerCase()) ||
          m.planName.toLowerCase().contains(query.toLowerCase()) ||
          (m.branchName?.toLowerCase().contains(query.toLowerCase()) ??
              false);
    }).toList();

    if (members.isEmpty) {
      return Center(
        child: Text(
          'No matches for "$query"',
          style: TextStyle(
            color: context.textSecondary,
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: members.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        color: context.border.withValues(alpha: 0.6),
      ),
      itemBuilder: (context, index) {
        final m = members[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor:
                context.colors.primary.withValues(alpha: 0.14),
            child: Text(
              m.fullName.isNotEmpty ? m.fullName[0].toUpperCase() : '?',
              style: TextStyle(
                color: context.colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          title: Text(
            m.fullName,
            style: TextStyle(color: context.textPrimary),
          ),
          subtitle: Text(
            '${m.planName} · ${m.phone}',
            style: TextStyle(color: context.textSecondary),
          ),
          onTap: () {
            close(context, null);
            context.push('/add-edit-member', extra: m);
          },
        );
      },
    );
  }
}