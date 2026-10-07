import 'package:flutter/material.dart';
import 'package:gym_management_app/data/models/body_progress_model.dart';
import 'package:gym_management_app/domain/entities/user_role.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/body_progress_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';

class BodyProgressScreen extends StatefulWidget {
  const BodyProgressScreen({super.key});

  @override
  State<BodyProgressScreen> createState() => _BodyProgressScreenState();
}

class _BodyProgressScreenState extends State<BodyProgressScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    final progressProvider = context.read<BodyProgressProvider>();
    
    final memberId = auth.currentUser?.linkedMemberId ?? '';
    if (memberId.isNotEmpty) {
      await progressProvider.fetchForMember(memberId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final progressProvider = context.watch<BodyProgressProvider>();

    final memberId = auth.currentRole == UserRole.member 
        ? auth.currentUser?.linkedMemberId ?? '' 
        : '';

    final history = progressProvider.getHistory(memberId);
    final isLoading = progressProvider.isLoading;
    final latest = history.isNotEmpty ? history.first : null;
    final trend = progressProvider.getTrend(memberId);
    final totalChange = progressProvider.getTotalChange(memberId);

    // Check if user can add entries - FIXED: Allow member and trainer
    final canAddEntry = auth.currentRole == UserRole.member || 
                        auth.hasPermission('canUpdateBodyMeasurements');

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        title: const Text('Body Progress'),
        backgroundColor: context.background,
        actions: [
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          // ADD BUTTON - Always show for members
          if (canAddEntry)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await context.push('/add-progress-entry');
                _loadData(); // Reload after adding
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Quick Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Latest Weight',
                          latest != null ? '${latest.weightKg.toStringAsFixed(1)} kg' : '—',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'BMI',
                          latest != null ? latest.bmi?.toStringAsFixed(1) ?? '—' : '—',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Trend',
                          trend == 'losing' ? '📉 Losing' :
                          trend == 'gaining' ? '📈 Gaining' : '➖ Stable',
                        ),
                      ),
                    ],
                  ),

                  // Total Change
                  if (totalChange != 0.0)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: GlassContainer(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                totalChange < 0 ? Icons.trending_down : Icons.trending_up,
                                color: totalChange < 0 ? AppColors.success : AppColors.warning,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Total change: ${totalChange >= 0 ? '+' : ''}${totalChange.toStringAsFixed(1)} kg',
                                  style: TextStyle(
                                    color: totalChange < 0 ? AppColors.success : AppColors.warning,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Quick Actions
                  Row(
                    children: [
                      Expanded(
                        child: GlassContainer(
                          onTap: () => context.push('/progress-comparison'),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('Compare Progress', textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassContainer(
                          onTap: () => context.push('/progress-charts'),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('View Charts', textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // History List (inside scrollable parent so it doesn't need its own)
                  if (history.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 64,
                            color: context.textMuted,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No progress entries yet',
                            style: TextStyle(
                              color: context.textPrimary,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Log your first measurement to track progress!',
                            style: TextStyle(
                              color: context.textSecondary,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          // ADD "Add First Entry" button when empty
                          if (canAddEntry)
                            ElevatedButton.icon(
                              onPressed: () async {
                                await context.push('/add-progress-entry');
                                _loadData();
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add First Entry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        for (final entry in history) ...[
                          GlassContainer(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(
                                '${_formatDate(entry.date)} • ${entry.weightKg.toStringAsFixed(1)} kg',
                                style: TextStyle(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'BMI: ${entry.bmi?.toStringAsFixed(1) ?? '—'}',
                                    style: TextStyle(color: context.textSecondary),
                                  ),
                                  if (entry.bodyFatPercent != null)
                                    Text(
                                      'Body Fat: ${entry.bodyFatPercent!.toStringAsFixed(1)}%',
                                      style: TextStyle(color: context.textSecondary),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (entry.notes != null && entry.notes!.isNotEmpty)
                                    Icon(
                                      Icons.note,
                                      color: context.textSecondary,
                                      size: 16,
                                    ),
                                  const SizedBox(width: 8),
                                  // NEW: three-dot overflow menu with
                                  // Edit + Delete options. Hidden when
                                  // the user lacks update permission so
                                  // view-only users still see a clean
                                  // trailing chevron.
                                  if (canAddEntry)
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert),
                                      tooltip: 'Entry actions',
                                      onSelected: (value) {
                                        switch (value) {
                                          case 'edit':
                                            _editEntry(context, entry);
                                            break;
                                          case 'delete':
                                            _confirmAndDelete(
                                                context, entry, progressProvider);
                                            break;
                                        }
                                      },
                                      itemBuilder: (ctx) => const [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: ListTile(
                                            leading: Icon(Icons.edit_outlined),
                                            title: Text('Edit Entry'),
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: ListTile(
                                            leading: Icon(Icons.delete_outline,
                                                color: Colors.red),
                                            title: Text(
                                              'Delete Entry',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    const Icon(Icons.chevron_right),
                                ],
                              ),
                              onTap: () {
                                _showEntryDetails(context, entry);
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: context.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showEntryDetails(BuildContext context, BodyProgressModel entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surface,
        title: Text(
          'Entry Details',
          style: TextStyle(color: context.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Date', _formatDate(entry.date)),
            _buildDetailRow('Weight', '${entry.weightKg.toStringAsFixed(1)} kg'),
            _buildDetailRow('Height', '${entry.heightCm.toStringAsFixed(1)} cm'),
            _buildDetailRow('BMI', entry.bmi?.toStringAsFixed(1) ?? '—'),
            if (entry.bodyFatPercent != null)
              _buildDetailRow('Body Fat', '${entry.bodyFatPercent!.toStringAsFixed(1)}%'),
            if (entry.muscleMassKg != null)
              _buildDetailRow('Muscle Mass', '${entry.muscleMassKg!.toStringAsFixed(1)} kg'),
            if (entry.notes != null && entry.notes!.isNotEmpty)
              _buildDetailRow('Notes', entry.notes!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// NEW: navigate to the add/edit form with the entry pre-filled.
  /// Using go_router keeps the route consistent with the rest of the
  /// app — the form detects `existingEntry` and switches into edit mode.
  Future<void> _editEntry(
      BuildContext context, BodyProgressModel entry) async {
    await context.push('/add-progress-entry', extra: entry);
    // Refresh the list so the user sees the updated values when they
    // come back, regardless of whether they actually saved.
    _loadData();
  }

  /// NEW: confirm then dispatch a delete through the provider. The
  /// provider removes the row from Hive locally and queues the API
  /// push; the UI re-renders from the same in-memory list.
  Future<void> _confirmAndDelete(
    BuildContext context,
    BodyProgressModel entry,
    BodyProgressProvider provider,
  ) async {
    // Capture the messenger *before* any await so we never touch a
    // deactivated context after the dialog/promise cycle.
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete progress entry?'),
        content: const Text(
          'Are you sure you want to delete this progress entry? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await provider.deleteEntry(entry.id, entry.memberId);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Progress entry deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to delete entry: ${e.toString()}')),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: context.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: context.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}