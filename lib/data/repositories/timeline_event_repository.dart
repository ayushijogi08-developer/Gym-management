import 'package:gym_management_app/data/local/hive_boxes.dart';
import 'package:gym_management_app/data/network/api_client.dart';
import 'package:gym_management_app/data/network/api_endpoints.dart';
import '../models/timeline_event_model.dart';
import 'base_repository.dart';

class TimelineEventRepository extends BaseRepository<TimelineEventModel> {
  TimelineEventRepository() : super(HiveBoxes.timelineEvents, ApiEndpoints.timeline);

  // Get events for a member from local
  List<TimelineEventModel> getByMember(String memberId) {
    return box.values
        .where((e) => e.memberId == memberId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Fetch from API
  Future<List<TimelineEventModel>> fetchByMember(String memberId) async {
    try {
      print("📤 Fetching timeline from API for member: $memberId");
      final response = await ApiClient.get('$endpoint/member/$memberId');
      
      print("Response status: ${response.statusCode}");
      print("Response data: ${response.data}");
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        final events = data.map((json) => TimelineEventModel.fromJson(json)).toList();
        
        // Save to local
        for (var event in events) {
          await box.put(event.id, event);
        }
        
        print("✅ Found ${events.length} timeline events from API");
        return events;
      }
      return [];
    } catch (e) {
      print("❌ Error fetching timeline: $e");
      return getByMember(memberId);
    }
  }

  // Add event to API (uses BaseRepository)
  Future<void> addEvent(TimelineEventModel event) async {
    try {
      print("📤 Sending event to API: ${event.title}");
      await add(event, id: event.id);
      print("✅ Event synced to API");
    } catch (e) {
      print("❌ Failed to sync event to API: $e");
      // Don't throw - we already saved locally
    }
  }

  // Add event locally only (NO API call)
  Future<void> addEventLocal(TimelineEventModel event) async {
    await box.put(event.id, event);
    print("✅ Event saved locally (ID: ${event.id})");
  }

  // Delete event
  Future<void> deleteEvent(String id) async {
    await box.delete(id);
    try {
      await ApiClient.delete('$endpoint/$id');
    } catch (e) {
      print("Error deleting event from API: $e");
    }
  }
}