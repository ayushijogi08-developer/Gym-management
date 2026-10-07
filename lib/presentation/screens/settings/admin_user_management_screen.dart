import 'package:flutter/material.dart';
import 'package:gym_management_app/data/models/app_user_model.dart';
import 'package:gym_management_app/domain/entities/user_role.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';
import '../../../utils/permissions.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  bool _isLoading = true;
  List<AppUserModel> _users = [];
  String _searchQuery = '';
  String _filterRole = 'all';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    
    final auth = context.read<AuthProvider>();
    try {
      final allUsers = await auth.getUsersByRole('');
      _users = allUsers;
    } catch (e) {
      debugPrint('Error loading users: $e');
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    
    if (auth.currentRole != UserRole.superAdmin && auth.currentRole != UserRole.admin) {
      return Scaffold(
        backgroundColor: context.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, color: context.textPrimary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Only Admins and Super Admins can access this page',
                style: TextStyle(color: context.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    var filteredUsers = _users;
    
    if (_filterRole != 'all') {
      filteredUsers = filteredUsers.where((u) => u.role == _filterRole).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filteredUsers = filteredUsers.where((u) =>
          u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        title: Text('User Management', style: TextStyle(color: context.textPrimary)),
        backgroundColor: context.background,
        iconTheme: IconThemeData(color: context.textPrimary),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: context.textPrimary),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: TextStyle(color: context.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search by name or email...',
                    hintStyle: TextStyle(color: context.textSecondary),
                    prefixIcon: Icon(Icons.search, color: context.textSecondary),
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
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    filled: true,
                    fillColor: context.surface,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      _buildFilterChip('Super Admin', 'superAdmin'),
                      _buildFilterChip('Admin', 'admin'),
                      _buildFilterChip('Trainer', 'trainer'),
                      _buildFilterChip('Receptionist', 'receptionist'),
                      _buildFilterChip('Member', 'member'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Users List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: context.textSecondary),
                            const SizedBox(height: 16),
                            Text(
                              'No users found',
                              style: TextStyle(color: context.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return _buildUserCard(context, user);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterRole == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterRole = selected ? value : 'all';
          });
        },
        selectedColor: AppColors.primary.withValues(alpha: 0.3),
        backgroundColor: context.surface,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : context.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, AppUserModel user) {
    final userRole = UserRole.values.firstWhere(
      (r) => r.name == user.role,
      orElse: () => UserRole.member,
    );
    
    final permissions = Permissions.rolePermissions[userRole] ?? [];
    
    Color roleColor;
    switch (user.role) {
      case 'superAdmin':
        roleColor = Colors.purple;
        break;
      case 'admin':
        roleColor = Colors.blue;
        break;
      case 'trainer':
        roleColor = Colors.orange;
        break;
      case 'receptionist':
        roleColor = Colors.teal;
        break;
      case 'member':
        roleColor = Colors.green;
        break;
      default:
        roleColor = Colors.grey;
    }

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: roleColor.withValues(alpha: 0.2),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: TextStyle(color: roleColor, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      user.email,
                      style: TextStyle(color: context.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: roleColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            _capitalizeRole(user.role),
                            style: TextStyle(
                              color: roleColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!user.isActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                            ),
                            child: const Text(
                              'INACTIVE',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.security, color: Colors.amber),
                onPressed: () => _showPermissionsDialog(context, user),
                tooltip: 'View/Edit Permissions',
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.border),
            ),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: permissions.take(5).map((permission) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _formatPermissionName(permission),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (permissions.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+ ${permissions.length - 5} more permissions',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showPermissionsDialog(BuildContext context, AppUserModel user) {
    final userPermissions = Permissions.getUserPermissions(user);
    final isSuperAdmin = user.role == 'superAdmin';
    
    final allPermissions = {
      'canViewMembers': 'View Members',
      'canAddEditMembers': 'Add/Edit Members',
      'canDeleteMembers': 'Delete Members',
      'canViewFinancialReports': 'View Financial Reports',
      'canViewAllReports': 'View All Reports',
      'canChangeGymSettings': 'Change Gym Settings',
      'canManageTrainers': 'Manage Trainers',
      'canManageReceptionists': 'Manage Receptionists',
      'canManageAdmins': 'Manage Admins',
      'canCollectPayments': 'Collect Payments',
      'canManageAllUsers': 'Manage All Users',
      'canManageSubscriptions': 'Manage Subscriptions',
      'canUpdateBodyMeasurements': 'Update Body Measurements',
      'canSendAnnouncements': 'Send Announcements',
      'canManagePlans': 'Manage Plans',
      'canResetPasswords': 'Reset Passwords',
      'canViewAttendance': 'View Attendance',
      'canApproveEntry': 'Approve Entry',
      'canEditWorkoutPlans': 'Edit Workout Plans',
      'canEditDietPlans': 'Edit Diet Plans',
      'canEditPlans': 'Edit Plans',
      'canViewAssignedMembers': 'View Assigned Members',
      'canViewOwnProfile': 'View Own Profile',
      'canViewOwnDiet': 'View Own Diet',
      'canViewOwnWorkout': 'View Own Workout',
      'canCreateOwnGoal': 'Create Own Goal',
      'canUpdateOwnGoal': 'Update Own Goal',
    };

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surface,
        title: Row(
          children: [
            const Icon(Icons.security, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Permissions: ${user.name}',
                style: TextStyle(color: context.textPrimary, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Role: ${_capitalizeRole(user.role)} • ${isSuperAdmin ? 'Full Access' : 'Custom permissions available'}',
                          style: TextStyle(color: context.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Permissions:',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...allPermissions.entries.map((entry) {
                  final isEnabled = userPermissions.contains(entry.key);
                  final isCustom = Permissions.isCustomPermission(user, entry.key);
                  final isFromRole = !isCustom && isEnabled;
                  
                  return CheckboxListTile(
                    value: isEnabled,
                    onChanged: isSuperAdmin
                        ? null
                        : (value) => _togglePermission(
                            context,
                            user,
                            entry.key,
                            value ?? false,
                          ),
                    title: Text(
                      entry.value,
                      style: TextStyle(
                        color: isEnabled ? context.textPrimary : context.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        if (isCustom) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                            ),
                            child: const Text(
                              'Custom',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        if (isFromRole) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                            ),
                            child: const Text(
                              'Role',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    activeColor: AppColors.primary,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }),
                if (isSuperAdmin)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lock, color: Colors.amber),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Super Admin has all permissions by default',
                              style: TextStyle(color: Colors.amber),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: TextStyle(color: context.textPrimary)),
          ),
        ],
      ),
    );
  }

  Future<void> _togglePermission(
    BuildContext context,
    AppUserModel user,
    String permissionKey,
    bool newValue,
  ) async {
    try {
      if (newValue) {
        Permissions.addCustomPermission(user, permissionKey);
      } else {
        Permissions.removeCustomPermission(user, permissionKey);
      }
      
      final auth = context.read<AuthProvider>();
      await auth.updateUserBasicInfo(user);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Permission ${newValue ? 'added' : 'removed'} for ${user.name}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
        _showPermissionsDialog(context, user);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatPermissionName(String permission) {
    String name = permission.replaceFirst('can', '');
    name = name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    ).trim();
    return name;
  }

  String _capitalizeRole(String role) {
    switch (role) {
      case 'superAdmin':
        return 'Super Admin';
      case 'admin':
        return 'Admin';
      case 'receptionist':
        return 'Receptionist';
      case 'trainer':
        return 'Trainer';
      case 'member':
        return 'Member';
      default:
        return role;
    }
  }
}