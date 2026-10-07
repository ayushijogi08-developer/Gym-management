import 'package:hive/hive.dart';

part 'timeline_event_model.g.dart';

@HiveType(typeId: 18)
class TimelineEventModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String memberId;

  @HiveField(2)
  String eventType;

  @HiveField(3)
  String title;

  @HiveField(4)
  String? subtitle;

  @HiveField(5)
  String? iconAsset;

  @HiveField(6)
  DateTime date;

  @HiveField(7)
  String? relatedRecordId;

  @HiveField(8)
  String? thumbnailPath;

  TimelineEventModel({
    required this.id,
    required this.memberId,
    required this.eventType,
    required this.title,
    this.subtitle,
   this.iconAsset, // ✅ Now optional
    DateTime? date, // ✅ Accepts nullable date
    this.relatedRecordId,
    this.thumbnailPath,
  }) : date = date ?? DateTime.now();
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'eventType': eventType,
      'title': title,
      'subtitle': subtitle,
      'iconAsset': iconAsset,
      'date': date.toIso8601String(),
      'relatedRecordId': relatedRecordId,
      'thumbnailPath': thumbnailPath,
    };
  }

  // ADD THIS: Create from JSON from API
   factory TimelineEventModel.fromJson(Map<String, dynamic> json) {
    return TimelineEventModel(
      id: (json['id'] ?? json['_id']).toString(),
      memberId: json['memberId'].toString(),
      eventType: json['eventType'] ?? 'general',
      title: json['title'] ?? 'Event',
      subtitle: json['subtitle'],
      iconAsset: json['iconAsset'], // ✅ Can be null
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      relatedRecordId: json['relatedRecordId']?.toString(),
      thumbnailPath: json['thumbnailPath'],
    );
  }

}
