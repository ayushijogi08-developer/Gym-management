import 'package:hive/hive.dart';

part 'member_model.g.dart';

/// Core Member entity, persisted to Hive local storage.
@HiveType(typeId: 0)
class MemberModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String fullName;

  @HiveField(2)
  String gender;

  @HiveField(3)
  String phone;

  @HiveField(4)
  String email;

  @HiveField(5)
  String? photoPath;

  @HiveField(6)
  String membershipStatus; 

  @HiveField(7)
  String planName;

  @HiveField(8)
  DateTime joiningDate;

  @HiveField(9)
  DateTime expiryDate;

  @HiveField(10)
  String? trainerAssigned;

  @HiveField(11)
  DateTime? dob;

  @HiveField(12)
  String? emergencyContact;

  @HiveField(13)
  String? bloodGroup;

  @HiveField(14)
  double? heightCm;

  @HiveField(15)
  double? weightKg;

  @HiveField(16)
  String? medicalConditions;

  @HiveField(17)
  String? notes;

  @HiveField(18)  // NEW
  String? qrData;

  @HiveField(19)
String? assignedTrainerId;

@HiveField(20)
  String? currentSubscriptionId;

@HiveField(21) // Add after existing fields
String? branchId; // ID of the assigned branch

@HiveField(22)
String? branchName; // Denormalized branch name for display

  MemberModel({
    required this.id,
    required this.fullName,
    required this.gender,
    required this.phone,
    required this.email,
    this.photoPath,
    required this.membershipStatus,
    required this.planName,
    required this.joiningDate,
    required this.expiryDate,
    this.trainerAssigned,
    this.dob,
    this.emergencyContact,
    this.bloodGroup,
    this.heightCm,
    this.weightKg,
    this.medicalConditions,
    this.notes,
    this.qrData,
    this.assignedTrainerId,
    this.currentSubscriptionId,
      this.branchId, // NEW
  this.branchName, 
  });

  /// BMI = weight(kg) / (height(m))^2 — null if height or weight missing.
  double? get bmi {
    if (heightCm == null || weightKg == null || heightCm == 0) return null;
    final heightM = heightCm! / 100;
    return weightKg! / (heightM * heightM);
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'gender': gender,
      'phone': phone,
      'email': email,
      'photoPath': photoPath,
      'membershipStatus': membershipStatus,
      'planName': planName,
      'joiningDate': joiningDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
     'assignedTrainerId': assignedTrainerId,
      'dob': dob?.toIso8601String(),
      'emergencyContact': emergencyContact,
      'bloodGroup': bloodGroup,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'medicalConditions': medicalConditions,
      'notes': notes,
      'qrData': qrData,

      'currentSubscriptionId': currentSubscriptionId,
       'branchId': branchId,
    'branchName': branchName,
    };
  }
  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['_id']?? json['id'] ?? '',
      fullName: json['fullName'],
      gender: json['gender'],
      phone: json['phone'],
      email: json['email'],
      photoPath: json['photoPath'],
      membershipStatus: json['membershipStatus'],
      planName: json['planName'],
      joiningDate: DateTime.parse(json['joiningDate']),
      expiryDate: DateTime.parse(json['expiryDate']),
      trainerAssigned: json['trainerAssigned'],
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      emergencyContact: json['emergencyContact'],
      bloodGroup: json['bloodGroup'],
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      medicalConditions: json['medicalConditions'],
      notes: json['notes'],
      qrData: json['qrData'],
      assignedTrainerId: json['assignedTrainerId'],
      currentSubscriptionId: json['currentSubscriptionId'],
       branchId: json['branchId']?.toString(),
    branchName: json['branchName']?.toString(),
    );
  }
} 