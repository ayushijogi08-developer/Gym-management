import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_management_app/data/models/gym_config_model.dart';
import 'package:gym_management_app/providers/gym_config_provider.dart';
import 'package:gym_management_app/providers/member_provider.dart';
import 'package:gym_management_app/themes/app_colors.dart';
import 'gradient_button.dart';

class BranchAssignmentDialog extends StatefulWidget {
  final String memberId;
  final String? currentBranchId;

  const BranchAssignmentDialog({
    super.key,
    required this.memberId,
    this.currentBranchId,
  });

  @override
  State<BranchAssignmentDialog> createState() => _BranchAssignmentDialogState();
}

class _BranchAssignmentDialogState extends State<BranchAssignmentDialog> {
  String? _selectedBranchId;
  bool _isLoading = true;
  List<BranchModel> _branches = [];

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<GymConfigProvider>();
      await provider.loadConfig(forceRefresh: true);
      final config = provider.config;
      if (config != null) {
        _branches = config.branches;
        _selectedBranchId = widget.currentBranchId;
      }
    } catch (e) {
      print('Error loading branches: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.card : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        'Assign Branch',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: _isLoading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : _branches.isEmpty
              ? const SizedBox(
                  height: 100,
                  child: Center(
                    child: Text(
                      'No branches available.\nPlease add a branch first.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Select a branch for this member:',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      ..._branches.map((branch) {
                        final isSelected = _selectedBranchId == branch.id;
                        return ListTile(
                          leading: Radio<String>(
                            value: branch.id,
                            groupValue: _selectedBranchId,
                            onChanged: (value) {
                              setState(() => _selectedBranchId = value);
                            },
                            activeColor: AppColors.primary,
                          ),
                          title: Text(
                            branch.name,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            branch.address,
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                          trailing: branch.isMainBranch
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.green),
                                  ),
                                  child: const Text(
                                    'MAIN',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                          onTap: () {
                            setState(() => _selectedBranchId = branch.id);
                          },
                        );
                      }),
                    ],
                  ),
                ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ),
        GradientButton(
          label: 'Assign Branch',
          onPressed: _selectedBranchId != null ? () => _assignBranch() : null,
        ),
      ],
    );
  }

  Future<void> _assignBranch() async {
    if (_selectedBranchId == null) return;

    try {
      final memberProvider = context.read<MemberProvider>();
      final branchProvider = context.read<GymConfigProvider>();
      
      // Get branch name
      final branch = branchProvider.config?.branches
          .firstWhere((b) => b.id == _selectedBranchId);
      
      // Update member
      final members = memberProvider.members;
      final member = members.firstWhere((m) => m.id == widget.memberId);
      
      member.branchId = _selectedBranchId;
      member.branchName = branch?.name ?? '';
      
      await memberProvider.updateMember(member);
      
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Member assigned to ${branch?.name ?? 'branch'}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 