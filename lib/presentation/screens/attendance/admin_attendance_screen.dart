import 'package:flutter/material.dart';
import 'package:gym_management_app/data/models/attendance_model.dart';
import 'package:gym_management_app/domain/entities/user_role.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/attendance_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../../themes/app_spacing.dart';
import '../../widgets/glass_tile.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  bool _isLoading = true;
  String _filterType = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final provider = context.read<AttendanceProvider>();
      await provider.fetchAllAttendance();
      debugPrint('📊 Records after fetch: ${provider.allRecords.length}');
    } catch (e) {
      debugPrint('❌ Error loading attendance: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<AttendanceProvider>();
    final records = provider.allRecords;

    final hasAccess = auth.currentRole == UserRole.admin ||
        auth.currentRole == UserRole.superAdmin ||
        auth.currentRole == UserRole.receptionist;

    if (!hasAccess) {
      return Scaffold(
        body: Center(
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
                  child: Icon(Icons.lock_outline,
                      size: 36, color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Access Denied',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Only Admins and Receptionists can view attendance',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Filter records
    var filteredRecords = records;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredRecords = filteredRecords
          .where((a) => a.memberName.toLowerCase().contains(query))
          .toList();
    }

    final now = DateTime.now();
    switch (_filterType) {
      case 'today':
        filteredRecords = filteredRecords
            .where((a) =>
                a.timestamp.year == now.year &&
                a.timestamp.month == now.month &&
                a.timestamp.day == now.day)
            .toList();
        break;
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        filteredRecords =
            filteredRecords.where((a) => a.timestamp.isAfter(weekAgo)).toList();
        break;
      case 'month':
        final monthAgo = now.subtract(const Duration(days: 30));
        filteredRecords =
            filteredRecords.where((a) => a.timestamp.isAfter(monthAgo)).toList();
        break;
      default:
        break;
    }

    // Group by date
    final groupedRecords = <String, List<AttendanceModel>>{};
    for (var record in filteredRecords) {
      final dateKey = DateFormat('yyyy-MM-dd').format(record.timestamp);
      if (!groupedRecords.containsKey(dateKey)) {
        groupedRecords[dateKey] = [];
      }
      groupedRecords[dateKey]!.add(record);
    }

    final sortedDates = groupedRecords.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    // Stats
    final totalRecords = filteredRecords.length;
    final todayCount = records
        .where((a) =>
            a.timestamp.year == now.year &&
            a.timestamp.month == now.month &&
            a.timestamp.day == now.day)
        .length;
    final uniqueMembers = records.map((a) => a.memberId).toSet().length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _loadData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Stats Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
            child: Row(
              children: [
                _buildStatCard('Total', totalRecords.toString(),
                    AppColors.primary, Icons.list_alt_rounded),
                const SizedBox(width: AppSpacing.sm),
                _buildStatCard('Today', todayCount.toString(),
                    AppColors.success, Icons.today_rounded),
                const SizedBox(width: AppSpacing.sm),
                _buildStatCard('Members', uniqueMembers.toString(),
                    AppColors.accent, Icons.group_outlined),
              ],
            ),
          ),

          // Filter Bar
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) =>
                        setState(() => _searchQuery = value),
                    style: TextStyle(
                        color: context.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search member...',
                      hintStyle:
                          TextStyle(color: context.textMuted, fontSize: 14),
                      prefixIcon: Icon(Icons.search_rounded,
                          color: context.textSecondary, size: 20),
                      filled: true,
                      fillColor: context.surfaceAlt,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
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
                        borderSide: BorderSide(
                            color: context.colors.primary, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: context.surfaceAlt,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: context.border),
                  ),
                  child: DropdownButton<String>(
                    value: _filterType,
                    dropdownColor: context.surface,
                    style: TextStyle(
                        color: context.textPrimary, fontSize: 13),
                    underline: const SizedBox(),
                    iconEnabledColor: context.textSecondary,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(value: 'today', child: Text('Today')),
                      DropdownMenuItem(value: 'week', child: Text('Week')),
                      DropdownMenuItem(value: 'month', child: Text('Month')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _filterType = value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Records List
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: context.colors.primary),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Loading attendance…',
                          style: TextStyle(color: context.textSecondary),
                        ),
                      ],
                    ),
                  )
                : filteredRecords.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: sortedDates.length,
                        itemBuilder: (context, index) {
                          final dateKey = sortedDates[index];
                          final dayRecords = groupedRecords[dateKey]!;
                          final date = DateTime.parse(dateKey);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.sm),
                                child: Row(
                                  children: [
                                    Text(
                                      DateFormat('EEEE, dd MMM yyyy')
                                          .format(date),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: context.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        '${dayRecords.length} check-ins',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...dayRecords.map(
                                  (record) => _buildAttendanceTile(record)),
                              const SizedBox(height: AppSpacing.sm),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.md),
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
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
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
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
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
                Icons.how_to_reg_outlined,
                size: 36,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No attendance records found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try adding a check-in first',
              style: TextStyle(fontSize: 13, color: context.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceTile(AttendanceModel record) {
    final accent = AppColors.success;
    return GlassTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          record.memberName.isNotEmpty
              ? record.memberName[0].toUpperCase()
              : '?',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: Text(
        record.memberName,
        style: TextStyle(
          color: context.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gate: ${record.gateId}',
            style: TextStyle(color: context.textSecondary, fontSize: 12),
          ),
          Text(
            'Entry: ${record.entryType}',
            style: TextStyle(color: context.textSecondary, fontSize: 12),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            DateFormat('HH:mm').format(record.timestamp),
            style: TextStyle(
              color: context.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Check-in',
              style: TextStyle(
                color: accent,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}