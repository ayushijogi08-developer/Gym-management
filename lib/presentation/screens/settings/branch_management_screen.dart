import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_management_app/data/models/gym_config_model.dart';
import '../../../providers/gym_config_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_button.dart';

class BranchManagementScreen extends StatefulWidget {
  const BranchManagementScreen({super.key});

  @override
  State<BranchManagementScreen> createState() => _BranchManagementScreenState();
}

class _BranchManagementScreenState extends State<BranchManagementScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<GymConfigProvider>();
      await provider.loadConfig(forceRefresh: true);
    } catch (e) {
      print('❌ Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _clearCacheAndRefresh() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<GymConfigProvider>();
      await provider.clearCache();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Cache cleared and data refreshed'),
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GymConfigProvider>();
    final config = provider.config;
    final branches = config?.branches ?? [];

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        title: const Text('Branch Management'),
        backgroundColor: context.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: _clearCacheAndRefresh,
            tooltip: 'Clear Cache',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : branches.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: branches.length,
                  itemBuilder: (context, index) {
                    final branch = branches[index];
                    return _buildBranchCard(context, branch, index);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBranchDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_outlined,
            size: 80,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            'No Branches Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first branch to get started',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddBranchDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Branch'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BRANCH CARD ====================
  Widget _buildBranchCard(BuildContext context, BranchModel branch, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    String truncateId(String id, {int maxLength = 12}) {
      if (id.isEmpty) return 'N/A';
      if (id.length <= maxLength) return id;
      return '${id.substring(0, maxLength)}...';
    }
    
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () => _navigateToBranchDetail(context, branch),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Number Badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            
            // Branch Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          branch.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (branch.isMainBranch) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    branch.address,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Show additional details if available
                  Row(
                    children: [
                      if (branch.phone != null && branch.phone!.isNotEmpty)
                        Text(
                          '📞 ${branch.phone}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      if (branch.totalMembers != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          '👥 ${branch.totalMembers} members',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Action Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!branch.isMainBranch)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade400,
                    ),
                    iconSize: 20,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    onPressed: () => _confirmDeleteBranch(context, branch),
                    tooltip: 'Delete Branch',
                  ),
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                  iconSize: 20,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  onPressed: () => _showEditBranchDialog(context, branch),
                  tooltip: 'Edit Branch',
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: isDark ? Colors.white38 : Colors.black38,
                    size: 16,
                  ),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  onPressed: () => _navigateToBranchDetail(context, branch),
                  tooltip: 'View Details',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== NAVIGATE TO BRANCH DETAIL ====================
  void _navigateToBranchDetail(BuildContext context, BranchModel branch) {
    context.push('/branch-detail', extra: branch);
  }

  // ==================== ADD BRANCH DIALOG ====================
  void _showAddBranchDialog(BuildContext context) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    bool isMain = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: context.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Add Branch',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black87,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Branch Name *',
                      labelStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white70 
                            : Colors.black54,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressController,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Address *',
                      labelStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white70 
                            : Colors.black54,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      labelStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white70 
                            : Colors.black54,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white70 
                            : Colors.black54,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: isMain,
                        onChanged: (value) {
                          setDialogState(() {
                            isMain = value ?? false;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                      Text(
                        'Set as Main Branch',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white70 
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white54 
                        : Colors.black54,
                  ),
                ),
              ),
              GradientButton(
                label: 'Add Branch',
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Branch name is required')),
                    );
                    return;
                  }
                  if (addressController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Address is required')),
                    );
                    return;
                  }

                  final newBranch = BranchModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    address: addressController.text.trim(),
                    isMainBranch: isMain,
                    phone: phoneController.text.trim(),
                    email: emailController.text.trim(),
                  );

                  Navigator.pop(ctx);
                  await _addBranch(context, newBranch);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // ==================== EDIT BRANCH DIALOG ====================
  void _showEditBranchDialog(BuildContext context, BranchModel branch) {
    final nameController = TextEditingController(text: branch.name);
    final addressController = TextEditingController(text: branch.address);
    final phoneController = TextEditingController(text: branch.phone ?? '');
    final emailController = TextEditingController(text: branch.email ?? '');
    bool isMain = branch.isMainBranch;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: context.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Edit Branch',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black87,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Branch Name *',
                      labelStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white70 
                            : Colors.black54,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressController,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Address *',
                      labelStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white70 
                            : Colors.black54,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      labelStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white70 
                            : Colors.black54,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white70 
                            : Colors.black54,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: isMain,
                        onChanged: (value) {
                          setDialogState(() {
                            isMain = value ?? false;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                      Text(
                        'Set as Main Branch',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white70 
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white54 
                        : Colors.black54,
                  ),
                ),
              ),
              GradientButton(
                label: 'Update Branch',
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Branch name is required')),
                    );
                    return;
                  }
                  if (addressController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Address is required')),
                    );
                    return;
                  }

                  final updatedBranch = BranchModel(
                    id: branch.id,
                    name: nameController.text.trim(),
                    address: addressController.text.trim(),
                    isMainBranch: isMain,
                    phone: phoneController.text.trim(),
                    email: emailController.text.trim(),
                  );

                  Navigator.pop(ctx);
                  await _updateBranch(context, updatedBranch);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // ==================== CRUD OPERATIONS ====================
  
  Future<void> _addBranch(BuildContext context, BranchModel newBranch) async {
    try {
      final provider = context.read<GymConfigProvider>();
      await provider.addBranch(newBranch);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Branch "${newBranch.name}" added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadData();
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

  Future<void> _updateBranch(BuildContext context, BranchModel updatedBranch) async {
    try {
      final provider = context.read<GymConfigProvider>();
      await provider.updateBranch(updatedBranch);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Branch "${updatedBranch.name}" updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadData();
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

  void _confirmDeleteBranch(BuildContext context, BranchModel branch) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Branch?',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black87,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${branch.name}"?',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white70 
                : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white54 
                    : Colors.black54,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteBranch(context, branch);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBranch(BuildContext context, BranchModel branch) async {
    try {
      final provider = context.read<GymConfigProvider>();
      await provider.deleteBranch(branch.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Branch "${branch.name}" deleted successfully!'),
            backgroundColor: Colors.orange,
          ),
        );
        await _loadData();
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