import 'dart:convert';
import 'package:hive/hive.dart';
import '../local/sync_queue_model.dart';
import '../local/sync_queue_repository.dart';
import '../network/api_client.dart';

abstract class BaseRepository<T> {
  final String boxName;
  final String endpoint;

  BaseRepository(this.boxName, this.endpoint);

  Box<T> get box => Hive.box<T>(boxName);

  // OPTIMISTIC + QUEUE
  Future<void> _saveAndQueue(String id, T item, String method, dynamic payload) async {
    // Save locally first (optimistic UI)
    await box.put(id, item);
    print("✅ Saved locally with ID: $id");

    // Try to send to API immediately
    try {
      if (method == 'POST') {
        final cleanPayload = Map<String, dynamic>.from(payload);
        cleanPayload.remove('id');
        print("📤 Sending POST to: $endpoint");
        print("📤 Payload: $cleanPayload");
        final response = await ApiClient.post(endpoint, data: cleanPayload);
        print("✅ POST successful! Status: ${response.statusCode}");
        print("✅ Response: ${response.data}");
      } else if (method == 'PUT') {
        await ApiClient.put('$endpoint/$id', data: payload);
        print("✅ PUT successful");
      } else if (method == 'DELETE') {
        await ApiClient.delete('$endpoint/$id');
        print("✅ DELETE successful");
      }
    } catch (e) {
      print("❌ Failed to sync to API: $e");
      // Queue for backend sync (offline fallback)
      await SyncQueueRepository().add(SyncQueueModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        endpoint: endpoint,
        method: method,
        payload: payload != null ? jsonEncode(payload) : '',
        createdAt: DateTime.now(),
      ));
      print("📦 Queued for later sync");
    }
  }

  // Example: Create
  Future<void> add(T item, {required String id}) async {
    print("📦 Adding item with ID: $id");
    await _saveAndQueue(id, item, 'POST', (item as dynamic).toJson());
  }

  // Example: Update
  Future<void> update(T item, {required String id}) async {
    await _saveAndQueue(id, item, 'PUT', (item as dynamic).toJson());
  }

  // Example: Delete
  Future<void> delete(String id) async {
    await box.delete(id);
    try {
      await ApiClient.delete('$endpoint/$id');
    } catch (e) {
      await SyncQueueRepository().add(SyncQueueModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        endpoint: '$endpoint/$id',
        method: 'DELETE',
        payload: '',
        createdAt: DateTime.now(),
      ));
    }
  }
}