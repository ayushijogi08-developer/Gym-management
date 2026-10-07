import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gym_management_app/data/models/gym_config_model.dart';
import '../../../providers/gym_config_provider.dart';
import '../../../providers/member_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_button.dart';

class BranchDetailScreen extends StatefulWidget {
  final BranchModel branch;

  const BranchDetailScreen({super.key, required this.branch});

  @override
  State<BranchDetailScreen> createState() => _BranchDetailScreenState();
}

class _BranchDetailScreenState extends State<BranchDetailScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _managerController;
  late TextEditingController _openingController;
  late TextEditingController _closingController;
  late TextEditingController _membersController;
  late TextEditingController _trainersController;
  late TextEditingController _revenueController;

  List<String> _workingDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  bool _isMain = false;
  int _branchMemberCount = 0;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadBranchMemberCount();
  }

  void _initControllers() {
    _nameController = TextEditingController(text: widget.branch.name);
    _addressController = TextEditingController(text: widget.branch.address);
    _phoneController = TextEditingController(text: widget.branch.phone ?? '');
    _emailController = TextEditingController(text: widget.branch.email ?? '');
    _managerController = TextEditingController(text: widget.branch.managerName ?? '');
    _openingController = TextEditingController(text: widget.branch.openingTime ?? '06:00');
    _closingController = TextEditingController(text: widget.branch.closingTime ?? '22:00');
    _membersController = TextEditingController(text: widget.branch.totalMembers?.toString() ?? '');
    _trainersController = TextEditingController(text: widget.branch.totalTrainers?.toString() ?? '');
    _revenueController = TextEditingController(text: widget.branch.monthlyRevenue?.toString() ?? '');
    _workingDays = widget.branch.workingDays;
    _isMain = widget.branch.isMainBranch;
  }

  Future<void> _loadBranchMemberCount() async {
    try {
      final memberProvider = context.read<MemberProvider>();
      await memberProvider.loadMembers();
      final members = memberProvider.members;
      setState(() {
        _branchMemberCount = members.where((m) => m.branchId == widget.branch.id).length;
      });
    } catch (e) {
      print('Error loading member count: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _managerController.dispose();
    _openingController.dispose();
    _closingController.dispose();
    _membersController.dispose();
    _trainersController.dispose();
    _revenueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Branch' : widget.branch.name),
        backgroundColor: context.background,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveBranch,
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _isEditing = false),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildBranchHeader(),
            const SizedBox(height: 16),
            _buildDetailsSection(),
            const SizedBox(height: 16),
            _buildWorkingHoursSection(),
            const SizedBox(height: 16),
            _buildPerformanceSection(),
            const SizedBox(height: 24),
            _buildActionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.6)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.business, color: Colors.white, size: 30),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.branch.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.branch.address,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (widget.branch.isMainBranch)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Text(
                            'MAIN BRANCH',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Text(
                          '$_branchMemberCount Members',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Branch Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Name', _nameController, _isEditing),
            _buildDetailRow('Address', _addressController, _isEditing),
            _buildDetailRow('Phone', _phoneController, _isEditing),
            _buildDetailRow('Email', _emailController, _isEditing),
            _buildDetailRow('Manager', _managerController, _isEditing),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, TextEditingController controller, bool isEditing) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: isEditing
                ? TextField(
                    controller: controller,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  )
                : Text(
                    controller.text.isNotEmpty ? controller.text : 'Not set',
                    style: TextStyle(
                      fontSize: 13,
                      color: controller.text.isNotEmpty
                          ? (isDark ? Colors.white : Colors.black87)
                          : (isDark ? Colors.white38 : Colors.black38),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Working Hours',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            if (_isEditing) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _openingController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: const InputDecoration(
                        labelText: 'Opening Time',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _closingController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: const InputDecoration(
                        labelText: 'Closing Time',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Working Days',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
                  final isSelected = _workingDays.contains(day);
                  return FilterChip(
                    label: Text(day),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _workingDays.add(day);
                        } else {
                          _workingDays.remove(day);
                        }
                      });
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.3),
                    backgroundColor: context.surface,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : (isDark ? Colors.white70 : Colors.black54),
                    ),
                  );
                }).toList(),
              ),
            ] else ...[
              Text(
                '${_openingController.text} - ${_closingController.text}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: _workingDays.map((day) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      day,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            if (_isEditing) ...[
              _buildStatsRow('Total Members', _membersController, isDark),
              _buildStatsRow('Total Trainers', _trainersController, isDark),
              _buildStatsRow('Monthly Revenue (₹)', _revenueController, isDark),
            ] else ...[
              _buildStatsDisplay('Total Members', 
                  widget.branch.totalMembers?.toString() ?? '$_branchMemberCount', isDark),
              _buildStatsDisplay('Total Trainers', 
                  widget.branch.totalTrainers?.toString() ?? 'N/A', isDark),
              _buildStatsDisplay('Monthly Revenue', 
                  widget.branch.monthlyRevenue != null 
                      ? '₹${widget.branch.monthlyRevenue!.toStringAsFixed(0)}' 
                      : 'N/A', isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(String label, TextEditingController controller, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDisplay(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Row(
      children: [
        Expanded(
          child: GradientButton(
            label: 'View Members ($_branchMemberCount)',
            onPressed: () {
              // Navigate to members filtered by this branch
              context.push('/members', extra: {'branchId': widget.branch.id});
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GradientButton(
            label: 'View Reports',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Viewing reports for ${widget.branch.name}')),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _saveBranch() async {
    final updatedBranch = BranchModel(
      id: widget.branch.id,
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      isMainBranch: _isMain,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      managerName: _managerController.text.trim(),
      openingTime: _openingController.text.trim(),
      closingTime: _closingController.text.trim(),
      workingDays: _workingDays,
      totalMembers: int.tryParse(_membersController.text.trim()),
      totalTrainers: int.tryParse(_trainersController.text.trim()),
      monthlyRevenue: double.tryParse(_revenueController.text.trim()),
    );

    try {
      final provider = context.read<GymConfigProvider>();
      await provider.updateBranch(updatedBranch);

      setState(() {
        _isEditing = false;
        widget.branch.name = updatedBranch.name;
        widget.branch.address = updatedBranch.address;
        widget.branch.phone = updatedBranch.phone;
        widget.branch.email = updatedBranch.email;
        widget.branch.managerName = updatedBranch.managerName;
        widget.branch.openingTime = updatedBranch.openingTime;
        widget.branch.closingTime = updatedBranch.closingTime;
        widget.branch.workingDays = updatedBranch.workingDays;
        widget.branch.totalMembers = updatedBranch.totalMembers;
        widget.branch.totalTrainers = updatedBranch.totalTrainers;
        widget.branch.monthlyRevenue = updatedBranch.monthlyRevenue;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Branch updated successfully!'),
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