import 'package:flutter/foundation.dart';
import '../data/models/timeline_event_model.dart';
import '../data/repositories/timeline_event_repository.dart';

class TimelineProvider extends ChangeNotifier {
  final TimelineEventRepository _repo = TimelineEventRepository();
  List<TimelineEventModel> _events = [];
  bool _isLoading = false;

  List<TimelineEventModel> get events => _events;
  bool get isLoading => _isLoading;

  // Get events for a member
  List<TimelineEventModel> getTimelineForMember(String memberId) {
    print("🔍 getTimelineForMember called for: $memberId");
    print("📊 Total events in memory: ${_events.length}");
    
    final filtered = _events.where((e) => e.memberId == memberId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    
    print("📊 Filtered events: ${filtered.length}");
    return filtered;
  }

  // Load from local
  void loadFromLocal() {
    print("📂 Loading timeline from local storage...");
    _events = _repo.box.values.toList();
    print("✅ Loaded ${_events.length} events from local storage");
    notifyListeners();
  }

  // Fetch from API
  Future<void> fetchForMember(String memberId) async {
    if (memberId.isEmpty) {
      print("❌ Cannot fetch: memberId is empty");
      return;
    }
    
    print("🌐 Fetching timeline from API for: $memberId");
    _isLoading = true;
    notifyListeners();

    try {
      final apiEvents = await _repo.fetchByMember(memberId);
      
      if (apiEvents.isNotEmpty) {
        _events = apiEvents;
        print("✅ Fetched ${apiEvents.length} timeline events from API");
      } else {
        print("⚠️ API returned empty, keeping local events");
        _events = _repo.box.values.toList();
        print("✅ Keeping ${_events.length} local events");
      }
    } catch (e) {
      print("❌ Error fetching timeline: $e");
      _events = _repo.box.values.toList();
      print("✅ Using ${_events.length} local events as fallback");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Log an event (Fixed typo: _repository -> _repo)
  Future<void> logEvent({
    required String memberId,
    required String eventType,
    required String title,
    String? subtitle,
    String? iconAsset,
    String? relatedRecordId,
    String? thumbnailPath,
  }) async {
    try {
      // ✅ Use _repo (NOT _repository)
      await _repo.addEvent(TimelineEventModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // ✅ ID is required
        memberId: memberId,
        eventType: eventType,
        title: title,
        subtitle: subtitle,
        iconAsset: iconAsset, // ✅ Pass as optional
        relatedRecordId: relatedRecordId,
        thumbnailPath: thumbnailPath,
      ));
    } catch (e) {
      print("Timeline Error (Ignored): $e");
    }
  }

  // Delete event
  Future<void> deleteEvent(String id) async {
    await _repo.deleteEvent(id);
    _events = _repo.box.values.toList();
    notifyListeners();
  }

  // Clear all events for testing
  Future<void> clearAllEvents() async {
    print("🧹 Clearing all timeline events...");
    await _repo.box.clear();
    _events = [];
    notifyListeners();
    print("✅ All events cleared");
  }
}