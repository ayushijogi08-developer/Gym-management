import 'package:hive/hive.dart';

part 'attendance_model.g.dart';

@HiveType(typeId: 2)
class AttendanceModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String memberId;

  @HiveField(2)
  String memberName;

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  String gateId;

  @HiveField(5)
  String entryType; // checkIn

  AttendanceModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.timestamp,
    this.gateId = 'Main Gate',
    this.entryType = 'checkIn',
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'memberName': memberName,
      'timestamp': timestamp.toIso8601String(),
      'gateId': gateId,
      'entryType': entryType,
    };
  }

  // --- ADDED: For Restore (Import) ---
   factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    // Handle memberId - could be a String or an ObjectId object
    String memberIdString;
    final memberIdData = json['memberId'];
    if (memberIdData is Map) {
      // MongoDB ObjectId format: { "$oid": "..." }
      memberIdString = memberIdData['\$oid']?.toString() ?? memberIdData['_id']?.toString() ?? '';
    } else if (memberIdData is String) {
      memberIdString = memberIdData;
    } else {
      memberIdString = memberIdData?.toString() ?? '';
    }

    // Handle id
    String idString;
    final idData = json['id'] ?? json['_id'];
    if (idData is Map) {
      idString = idData['\$oid']?.toString() ?? idData['_id']?.toString() ?? '';
    } else {
      idString = idData?.toString() ?? '';
    }

    // Handle timestamp
    DateTime timestamp;
    final timestampData = json['timestamp'] ?? json['checkInTime'] ?? json['createdAt'];
    if (timestampData is String) {
      timestamp = DateTime.parse(timestampData);
    } else if (timestampData is DateTime) {
      timestamp = timestampData;
    } else {
      timestamp = DateTime.now();
    }

    return AttendanceModel(
      id: idString,
      memberId: memberIdString,
      memberName: json['memberName']?.toString() ?? 'Unknown',
      timestamp: timestamp,
      gateId: json['gateId']?.toString() ?? 'Main Gate',
      entryType: json['entryType']?.toString() ?? 'checkIn',
    );
  }
}