enum UserRole {
  superAdmin,
  admin,
  receptionist,
  trainer,
  member,
}

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.admin:
        return 'Admin';
      case UserRole.receptionist:
        return 'Receptionist';
      case UserRole.trainer:
        return 'Trainer';
      case UserRole.member:
        return 'Member';
    }
  }

  String get name => toString().split('.').last;
}