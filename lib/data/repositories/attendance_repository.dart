import 'package:gym_management_app/data/local/hive_boxes.dart';
import 'package:gym_management_app/data/network/api_client.dart';
import 'package:gym_management_app/data/network/api_endpoints.dart';
import '../models/attendance_model.dart';
import 'base_repository.dart';

class AttendanceRepository extends BaseRepository<AttendanceModel> {
  AttendanceRepository() : super(HiveBoxes.attendance, ApiEndpoints.attendance);

  List<AttendanceModel> getAllLocal() => box.values.toList();

  List<AttendanceModel> getByDateLocal(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return box.values.where((a) => 
      a.timestamp.isAtSameMomentAs(start) || 
      (a.timestamp.isAfter(start) && a.timestamp.isBefore(end))
    ).toList();
  }

  // ✅ FIXED: GET ALL ATTENDANCE FROM API with better error handling
  Future<List<AttendanceModel>> getAll() async {
    try {
      print('📡 Calling API: GET $endpoint');
      final response = await ApiClient.get(endpoint);
      print('📡 API Response Status: ${response.statusCode}');
      print('📡 API Response Data: ${response.data}');
      
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          final List<dynamic> data = response.data['data'] ?? [];
          print('✅ Found ${data.length} attendance records from API');
          
          final records = <AttendanceModel>[];
          for (var json in data) {
            try {
              final record = AttendanceModel.fromJson(json);
              records.add(record);
            } catch (e) {
              print('⚠️ Error parsing record: $e');
              print('⚠️ JSON: $json');
            }
          }
          
          // Save to local cache
          for (var record in records) {
            await box.put(record.id, record);
          }
          
          print('✅ Saved ${records.length} records to local cache');
          return records;
        } else {
          print('⚠️ API returned success: false');
          return [];
        }
      } else {
        print('⚠️ API returned status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching attendance: $e');
      return box.values.toList();
    }
  }

  // Fetch by member
  Future<List<AttendanceModel>> fetchByMember(String memberId) async {
    try {
      print("📤 Fetching attendance for member: $memberId");
      final response = await ApiClient.get('$endpoint/member/$memberId');
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        final records = data.map((json) => AttendanceModel.fromJson(json)).toList();
        
        for (var record in records) {
          await box.put(record.id, record);
        }
        
        print("✅ Found ${records.length} attendance records");
        return records;
      }
      return [];
    } catch (e) {
      print("❌ Error fetching attendance: $e");
      return getByMemberLocal(memberId);
    }
  }

  List<AttendanceModel> getByMemberLocal(String memberId) {
    return box.values.where((a) => a.memberId == memberId).toList();
  }

  Future<void> addAttendance(AttendanceModel record) async {
    print("📤 Adding attendance record for: ${record.memberName}");
    await add(record, id: record.id);
  }
}