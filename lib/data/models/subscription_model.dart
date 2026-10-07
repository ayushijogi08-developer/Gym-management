import 'package:hive/hive.dart';

part 'subscription_model.g.dart';

@HiveType(typeId: 5)
class SubscriptionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String memberId;

  @HiveField(2)
  String planId;

  @HiveField(3)
  DateTime startDate;

  @HiveField(4)
  DateTime endDate;

  @HiveField(5)
  String status; // active | paused | expired | cancelled

  @HiveField(6)
  DateTime? pausedOn;

  @HiveField(7)
  DateTime? resumedOn;

  @HiveField(8)
  String? previousSubscriptionId;

  @HiveField(9)
  int gracePeriodDays;

  SubscriptionModel({
    required this.id,
    required this.memberId,
    required this.planId,
    required this.startDate,
    required this.endDate,
    this.status = 'active',
    this.pausedOn,
    this.resumedOn,
    this.previousSubscriptionId,
    this.gracePeriodDays = 3,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'planId': planId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'pausedOn': pausedOn?.toIso8601String(),
      'resumedOn': resumedOn?.toIso8601String(),
      'previousSubscriptionId': previousSubscriptionId,
      'gracePeriodDays': gracePeriodDays,
    };
  }

  // --- ADDED: For Restore (Import) ---
  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'],
      memberId: json['memberId'],
      planId: json['planId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: json['status'],
      pausedOn: json['pausedOn'] != null ? DateTime.parse(json['pausedOn']) : null,
      resumedOn: json['resumedOn'] != null ? DateTime.parse(json['resumedOn']) : null,
      previousSubscriptionId: json['previousSubscriptionId'],
      gracePeriodDays: json['gracePeriodDays'],
    );
  }

}