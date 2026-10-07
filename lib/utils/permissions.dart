import '../domain/entities/user_role.dart';
import '../data/models/app_user_model.dart';

class Permissions {
  static Map<UserRole, List<String>> rolePermissions = {
    UserRole.superAdmin: [
      'canDeleteMembers', 'canEditWorkoutPlans', 'canEditDietPlans', 'canEditPlans',
      'canViewMembers', 'canAddEditMembers', 'canDeleteMembers',
      'canViewFinancialReports', 'canChangeGymSettings', 'canManageTrainers',
      'canManageReceptionists', 'canManageAdmins', 'canCollectPayments',
      'canViewAllReports', 'canManageAllUsers', 'canManageSubscriptions',
      'canUpdateBodyMeasurements', 'canSendAnnouncements', 'canManagePlans',
      'canResetPasswords', 'canViewAttendance',
    ],
    UserRole.admin: [
      'canDeleteMembers', 'canEditWorkoutPlans', 'canEditDietPlans', 'canEditPlans',
      'canViewMembers', 'canAddEditMembers', 'canDeleteMembers',
      'canViewFinancialReports', 'canChangeGymSettings', 'canManageTrainers',
      'canCollectPayments', 'canViewAllReports', 'canManageSubscriptions',
      'canUpdateBodyMeasurements', 'canSendAnnouncements', 'canManagePlans',
      'canResetPasswords', 'canViewAttendance',
    ],
    UserRole.receptionist: [
      'canCollectPayments', 'canApproveEntry', 'canViewAttendance', 'canManageSubscriptions',
      'canViewMembers', 'canAddEditMembers', 'canDeleteMembers', 'canResetPasswords',
    ],
    UserRole.trainer: [
      'canEditWorkoutPlans', 'canEditDietPlans', 'canViewAssignedMembers',
      'canUpdateBodyMeasurements'
    ],
    UserRole.member: [
      'canViewOwnProfile', 
      'canViewOwnDiet', 
      'canViewOwnWorkout',
      'canCreateOwnGoal',
      'canUpdateOwnGoal',
      'canUpdateBodyMeasurements',
    ],
  };

  // ✅ Check permission for a specific user (combines role + custom)
  static bool hasPermission(AppUserModel? user, String permissionKey) {
    if (user == null) return false;
    
    // SuperAdmin has all permissions
    if (user.role == 'superAdmin') return true;
    
    // Check custom permissions first (user-specific)
    if (user.customPermissions.contains(permissionKey)) {
      return true;
    }
    
    // Then check role-based permissions
    final role = UserRole.values.firstWhere(
      (r) => r.name == user.role,
      orElse: () => UserRole.member,
    );
    
    return rolePermissions[role]?.contains(permissionKey) ?? false;
  }

  // ✅ Get all permissions for a user (role + custom)
  static List<String> getUserPermissions(AppUserModel user) {
    final role = UserRole.values.firstWhere(
      (r) => r.name == user.role,
      orElse: () => UserRole.member,
    );
    
    final rolePerms = rolePermissions[role] ?? [];
    final customPerms = user.customPermissions;
    
    // Combine and remove duplicates
    final allPerms = {...rolePerms, ...customPerms};
    return allPerms.toList();
  }

  // ✅ Add custom permission to a user
  static void addCustomPermission(AppUserModel user, String permission) {
    if (!user.customPermissions.contains(permission)) {
      user.customPermissions.add(permission);
    }
  }

  // ✅ Remove custom permission from a user
  static void removeCustomPermission(AppUserModel user, String permission) {
    user.customPermissions.remove(permission);
  }

  // ✅ Check if a permission is from role or custom
  static bool isCustomPermission(AppUserModel user, String permission) {
    final role = UserRole.values.firstWhere(
      (r) => r.name == user.role,
      orElse: () => UserRole.member,
    );
    final rolePerms = rolePermissions[role] ?? [];
    return user.customPermissions.contains(permission) && !rolePerms.contains(permission);
  }
}