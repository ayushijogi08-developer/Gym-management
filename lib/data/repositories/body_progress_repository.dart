import 'package:gym_management_app/data/local/hive_boxes.dart';
import 'package:gym_management_app/data/network/api_client.dart';
import 'package:gym_management_app/data/network/api_endpoints.dart';
import '../models/body_progress_model.dart';
import 'base_repository.dart';

class BodyProgressRepository extends BaseRepository<BodyProgressModel> {
  // Pass the Hive box name and API endpoint to the BaseRepository
  BodyProgressRepository() : super(HiveBoxes.bodyProgress, ApiEndpoints.bodyProgress);

  List<BodyProgressModel> getHistoryByMemberLocal(String memberId) {
    return box.values
        .where((p) => p.memberId == memberId)
        .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
  }

  BodyProgressModel? getLatestLocal(String memberId) {
    final history = getHistoryByMemberLocal(memberId);
    return history.isNotEmpty ? history.first : null;
  }
  
  // GET HISTORY BY MEMBER (Custom fetch logic)
  Future<List<BodyProgressModel>> getHistoryByMember(String memberId) async {
    try {
      final response = await ApiClient.get('$endpoint/member/$memberId/history');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => BodyProgressModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching progress history: $e');
      return [];
    }
  }

  // GET LATEST PROGRESS (Custom fetch logic)
  Future<BodyProgressModel?> getLatest(String memberId) async {
    try {
      final response = await ApiClient.get('$endpoint/member/$memberId/latest');
      return response.data['data'] != null 
          ? BodyProgressModel.fromJson(response.data['data']) 
          : null;
    } catch (e) {
      print('Error fetching latest progress: $e');
      return null;
    }
  }

  // ADD ENTRY (Uses BaseRepository's Optimistic + Queue logic)
  Future<void> addEntry(BodyProgressModel entry) async {
    await add(entry, id: entry.id);
  }

  // UPDATE ENTRY (Uses BaseRepository's Optimistic + Queue logic)
  Future<void> updateEntry(BodyProgressModel entry) async {
    await update(entry, id: entry.id);
  }

  // ADD THIS METHOD: DELETE ENTRY
  Future<void> deleteEntry(String entryId, String memberId) async {
    try {
      // Delete from API
      await ApiClient.delete('$endpoint/$entryId');
      
      // Delete from local Hive
      await box.delete(entryId);
      
      print("✅ Successfully deleted body progress entry: $entryId");
    } catch (e) {
      print("❌ Error deleting body progress entry: $e");
      // Fallback: delete locally anyway
      await box.delete(entryId);
      rethrow;
    }
  }

  // ADD THIS METHOD: Delete all entries for a member
  Future<void> deleteAllForMember(String memberId) async {
    try {
      final entries = getHistoryByMemberLocal(memberId);
      for (var entry in entries) {
        await deleteEntry(entry.id, memberId);
      }
    } catch (e) {
      print("❌ Error deleting all entries for member: $e");
      rethrow;
    }
  }
}