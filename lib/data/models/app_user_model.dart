import 'package:hive/hive.dart';

part 'app_user_model.g.dart';

@HiveType(typeId: 4)
class AppUserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String passwordHash;

  @HiveField(4)
  String role; // stored as enum name

  @HiveField(5)
  String? linkedMemberId;

  @HiveField(6)
  String? linkedTrainerId;

  @HiveField(7)
  String? assignedBranchId;

  @HiveField(8)
  bool isActive;

  @HiveField(9)
bool mustChangePassword;

 @HiveField(10) // ADD THIS - Phone field
  String? phone; 

   @HiveField(11)
  List<String> customPermissions;


  AppUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.role,
    this.linkedMemberId,
    this.linkedTrainerId,
    this.assignedBranchId,
    this.isActive = true,
    this.mustChangePassword = false,
     this.phone,
      this.customPermissions = const [],
  });
AppUserModel copyWith({
    String? name,
    String? email,
    String? passwordHash,
    String? role,
    String? linkedMemberId,
    String? linkedTrainerId,
    String? assignedBranchId,
    bool? isActive,
    bool? mustChangePassword,
    String? phone,
     List<String>? customPermissions,

  }) {
    return AppUserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      linkedMemberId: linkedMemberId ?? this.linkedMemberId,
      linkedTrainerId: linkedTrainerId ?? this.linkedTrainerId,
      assignedBranchId: assignedBranchId ?? this.assignedBranchId,
      isActive: isActive ?? this.isActive,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
        phone: phone ?? this.phone,
         customPermissions: customPermissions ?? this.customPermissions,

    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
      'role': role,
      'linkedMemberId': linkedMemberId,
      'linkedTrainerId': linkedTrainerId,
      'assignedBranchId': assignedBranchId,
      'isActive': isActive,
      'mustChangePassword': mustChangePassword,
      'phone': phone,
       'customPermissions': customPermissions,
    };
  }

  // --- ADDED: For Restore (Import) ---
factory AppUserModel.fromJson(Map<String, dynamic> json) {
  return AppUserModel(
    id: (json['id'] ?? json['_id']).toString(),
    // Backend sends 'fullName', ensure your model uses it
    name: json['fullName'] ?? json['name'] ?? 'Unknown User', 
    email: json['email'] ?? '',
    passwordHash: json['password'] ?? json['passwordHash'] ?? '',
    role: json['role'] ?? '',
    linkedMemberId: json['linkedMemberId']?.toString(),
    linkedTrainerId: json['linkedTrainerId']?.toString(),
     assignedBranchId: json['assignedBranchId']?.toString() ?? json['branchId']?.toString(), 
    isActive: json['isActive'] ?? true,
    mustChangePassword: json['mustChangePassword'] ?? false,
     phone: json['phone']?.toString(),
      customPermissions: List<String>.from(json['customPermissions'] ?? []),
  );
}
}