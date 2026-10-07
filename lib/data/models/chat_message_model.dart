import 'package:hive/hive.dart';
part 'chat_message_model.g.dart';

@HiveType(typeId: 17)
class ChatMessageModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String memberId;

  @HiveField(2)
  String role; // "user" or "assistant"

  @HiveField(3)
  String content;

  @HiveField(4)
  DateTime timestamp;

  @HiveField(5)
  bool includedMedicalContext;

  ChatMessageModel({
    required this.id,
    required this.memberId,
    required this.role,
    required this.content,
    required this.timestamp,
    this.includedMedicalContext = false,
  });
 factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['_id'] ?? json['id'], // Handles MongoDB _id
      memberId: json['memberId'],
      role: json['role'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      includedMedicalContext: json['includedMedicalContext'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'includedMedicalContext': includedMedicalContext,
    };
  }
}