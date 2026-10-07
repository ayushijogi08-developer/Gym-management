import 'package:hive/hive.dart';

part 'plan_model.g.dart';

@HiveType(typeId: 1)
class PlanModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String planName;

  @HiveField(2)
  String durationType;

  @HiveField(3)
  int durationInDays;

  @HiveField(4)
  double price;

  @HiveField(5)
  double? discountPercent;

  @HiveField(6)
  double? gstPercent;

  @HiveField(7)
  String? description;

  @HiveField(8)
  List<String> facilitiesIncluded;

  @HiveField(9)
  bool isPTIncluded;

  @HiveField(10)
  bool isFreezeAllowed;

  @HiveField(11)
  int renewalReminderDays;

  @HiveField(12)
  String status; // active | inactive

  PlanModel({
    required this.id,
    required this.planName,
    required this.durationType,
    required this.durationInDays,
    required this.price,
    this.discountPercent,
    this.gstPercent,
    this.description,
    this.facilitiesIncluded = const [],
    this.isPTIncluded = false,
    this.isFreezeAllowed = false,
    this.renewalReminderDays = 7,
    this.status = 'active',
  });

  /// Computed final price: discount first, then GST.
  double get finalPrice {
    double discounted = price;
    if (discountPercent != null && discountPercent! > 0) {
      discounted = price * (1 - discountPercent! / 100);
    }
    if (gstPercent != null && gstPercent! > 0) {
      discounted = discounted * (1 + gstPercent! / 100);
    }
    return double.parse(discounted.toStringAsFixed(2));
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planName': planName,
      'durationType': durationType,
      'durationInDays': durationInDays,
      'price': price,
      'discountPercent': discountPercent,
      'gstPercent': gstPercent,
      'description': description,
      'facilitiesIncluded': facilitiesIncluded,
      'isPTIncluded': isPTIncluded,
      'isFreezeAllowed': isFreezeAllowed,
      'renewalReminderDays': renewalReminderDays,
      'status': status,
    };
  }

  // --- ADDED: For Restore (Import) ---
  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
     id: json['_id'] ?? json['id'] ?? '', 
      planName: json['planName'] ?? '',
      durationType: json['durationType'] ?? 'Monthly',
      durationInDays: (json['durationInDays'] as num?)?.toInt() ?? 30,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercent: (json['discountPercent'] as num?)?.toDouble(),
      gstPercent: (json['gstPercent'] as num?)?.toDouble(),
      description: json['description'],
      facilitiesIncluded: List<String>.from(json['facilitiesIncluded'] ?? []),
      isPTIncluded: json['isPTIncluded'] ?? false,
      isFreezeAllowed: json['isFreezeAllowed'] ?? false,
      renewalReminderDays: (json['renewalReminderDays'] as num?)?.toInt() ?? 7,
      status: json['status'] ?? 'active',
    );
  }
}