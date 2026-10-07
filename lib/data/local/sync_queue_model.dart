import 'package:hive/hive.dart';

part 'sync_queue_model.g.dart';

@HiveType(typeId: 22)
class SyncQueueModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String endpoint; // e.g. '/api/members'

  @HiveField(2)
  String method; // POST, PUT, DELETE

  @HiveField(3)
  String payload; // JSON string of request body

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  bool synced;

  SyncQueueModel({
    required this.id,
    required this.endpoint,
    required this.method,
    required this.payload,
    required this.createdAt,
    this.synced = false,
  });
}