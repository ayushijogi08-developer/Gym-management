import 'package:hive/hive.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 19)
class NotificationModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String? memberId; // null for role-wide announcements

  @HiveField(2)
  String? recipientRole; // null for individual member

  @HiveField(3)
  String type; // expiry, payment_due, birthday, offer, announcement

  @HiveField(4)
  String title;

  @HiveField(5)
  String body;

  @HiveField(6)
  String? relatedRecordId;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  bool isRead;

  NotificationModel({
    required this.id,
    this.memberId,
    this.recipientRole,
    required this.type,
    required this.title,
    required this.body,
    this.relatedRecordId,
    required this.createdAt,
    this.isRead = false,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'recipientRole': recipientRole,
      'type': type,
      'title': title,
      'body': body,
      'relatedRecordId': relatedRecordId,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? json['_id'], // Handles both 'id' and MongoDB '_id'
      memberId: json['memberId'],
      recipientRole: json['recipientRole'],
      type: json['type'],
      title: json['title'],
      body: json['body'],
      relatedRecordId: json['relatedRecordId'],
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
    );
  }

}