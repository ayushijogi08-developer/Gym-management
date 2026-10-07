import 'package:hive/hive.dart';

part 'gym_config_model.g.dart';

@HiveType(typeId: 20)
class GymConfigModel extends HiveObject {
  @HiveField(0)
  String gymName;

  @HiveField(1)
  String? logoPath;

  @HiveField(2)
  String address;

  @HiveField(3)
  String contactPhone;

  @HiveField(4)
  String contactEmail;

  @HiveField(5)
  List<String> workingDays;

  @HiveField(6)
  String openingTime;

  @HiveField(7)
  String closingTime;

  @HiveField(8)
  double taxPercent;

  @HiveField(9)
  String currencySymbol;

  @HiveField(10)
  String currencyCode;

  @HiveField(11)
  String themeMode;

  @HiveField(12)
  List<BranchModel> branches;

  GymConfigModel({
    required this.gymName,
    this.logoPath,
    required this.address,
    required this.contactPhone,
    required this.contactEmail,
    required this.workingDays,
    required this.openingTime,
    required this.closingTime,
    this.taxPercent = 18.0,
    this.currencySymbol = '₹',
    this.currencyCode = 'INR',
    this.themeMode = 'dark',
    required this.branches,
  });

  Map<String, dynamic> toJson() {
    return {
      'gymName': gymName,
      'logoPath': logoPath,
      'address': address,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'workingDays': workingDays,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'taxPercent': taxPercent,
      'currencySymbol': currencySymbol,
      'currencyCode': currencyCode,
      'themeMode': themeMode,
      'branches': branches.map((b) => b.toJson()).toList(),
    };
  }

  factory GymConfigModel.fromJson(Map<String, dynamic> json) {
    // ✅ Handle branches safely
    List<BranchModel> branchList = [];
    
    if (json['branches'] != null && json['branches'] is List) {
      try {
        branchList = (json['branches'] as List)
            .map((b) => BranchModel.fromJson(b))
            .toList();
      } catch (e) {
        print('⚠️ Error parsing branches: $e');
        branchList = [];
      }
    }

    return GymConfigModel(
      gymName: json['gymName'] ?? 'My Gym',
      logoPath: json['logoPath'],
      address: json['address'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      contactEmail: json['contactEmail'] ?? '',
      workingDays: List<String>.from(json['workingDays'] ?? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']),
      openingTime: json['openingTime'] ?? '06:00',
      closingTime: json['closingTime'] ?? '22:00',
      taxPercent: (json['taxPercent'] as num?)?.toDouble() ?? 18.0,
      currencySymbol: json['currencySymbol'] ?? '₹',
      currencyCode: json['currencyCode'] ?? 'INR',
      themeMode: json['themeMode'] ?? 'dark',
      branches: branchList,
    );
  }
}
 
@HiveType(typeId: 21)
class BranchModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String address;

  @HiveField(3)
  bool isMainBranch;

  // ✅ ADD THESE FIELDS FOR FULL BRANCH DETAILS
  @HiveField(4)
  String? phone;

  @HiveField(5)
  String? email;

  @HiveField(6)
  String? managerName;

  @HiveField(7)
  String? openingTime;

  @HiveField(8)
  String? closingTime;

  @HiveField(9)
  List<String> workingDays;

  @HiveField(10)
  int? totalMembers;

  @HiveField(11)
  int? totalTrainers;

  @HiveField(12)
  double? monthlyRevenue;

  @HiveField(13)
  String? imageUrl;

  @HiveField(14)
  double? latitude;

  @HiveField(15)
  double? longitude;

  BranchModel({
    required this.id,
    required this.name,
    required this.address,
    this.isMainBranch = false,
    this.phone,
    this.email,
    this.managerName,
    this.openingTime,
    this.closingTime,
    this.workingDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    this.totalMembers,
    this.totalTrainers,
    this.monthlyRevenue,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'isMainBranch': isMainBranch,
      'phone': phone,
      'email': email,
      'managerName': managerName,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'workingDays': workingDays,
      'totalMembers': totalMembers,
      'totalTrainers': totalTrainers,
      'monthlyRevenue': monthlyRevenue,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    String id = '';
    if (json['id'] != null) {
      id = json['id'].toString();
    } else if (json['_id'] != null) {
      id = json['_id'].toString();
    }

    return BranchModel(
      id: id.isNotEmpty ? id : DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] ?? 'Unnamed Branch',
      address: json['address'] ?? '',
      isMainBranch: json['isMainBranch'] ?? false,
      phone: json['phone'],
      email: json['email'],
      managerName: json['managerName'],
      openingTime: json['openingTime'] ?? '06:00',
      closingTime: json['closingTime'] ?? '22:00',
      workingDays: List<String>.from(json['workingDays'] ?? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']),
      totalMembers: json['totalMembers'],
      totalTrainers: json['totalTrainers'],
      monthlyRevenue: (json['monthlyRevenue'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}