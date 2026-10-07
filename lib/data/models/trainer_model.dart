import 'package:hive/hive.dart';

part 'trainer_model.g.dart';

@HiveType(typeId: 3)
class TrainerModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String fullName;

  @HiveField(2)
  String phone;

  @HiveField(3)
  String email;

  @HiveField(4)
  String? photoPath;

  @HiveField(5)
  String specialization;

  @HiveField(6)
  int experienceYears;

  @HiveField(7)
  String? bio;

  @HiveField(8)
  List<String> workingDays;

  @HiveField(9)
  String shiftStart; // "09:00"

  @HiveField(10)
  String shiftEnd;   // "17:00"

  @HiveField(11)
  String status; // active / onLeave / inactive

  TrainerModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    this.photoPath,
    required this.specialization,
    required this.experienceYears,
    this.bio,
    this.workingDays = const [],
    required this.shiftStart,
    required this.shiftEnd,
    this.status = 'active',
  });
  Map<String, dynamic> toJson() {
    return {
     
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'photoPath': photoPath,
      'specialization': specialization,
      'experienceYears': experienceYears,
      'bio': bio,
      'workingDays': workingDays,
      'shiftStart': shiftStart,
      'shiftEnd': shiftEnd,
      'status': status,
    };
  }

  // --- ADDED: For Restore (Import) ---
  factory TrainerModel.fromJson(Map<String, dynamic> json) {
    return TrainerModel(
    id: json['_id'] ?? json['id'] ?? '', 
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      photoPath: json['photoPath'],
      specialization: json['specialization'] ?? '',
      experienceYears: (json['experienceYears'] as num?)?.toInt() ?? 0,
      bio: json['bio'],
      workingDays: List<String>.from(json['workingDays'] ?? []),
      shiftStart: json['shiftStart'] ?? '09:00',
      shiftEnd: json['shiftEnd'] ?? '17:00',
      status: json['status'] ?? 'active',
    );
  }
}