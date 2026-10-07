import 'package:hive/hive.dart';
import '../local/hive_boxes.dart';
import 'sync_queue_model.dart';

class SyncQueueRepository {
  Box<SyncQueueModel> get _box => Hive.box<SyncQueueModel>(HiveBoxes.syncQueue);

  List<SyncQueueModel> getPending() => 
      _box.values.where((q) => !q.synced).toList();

  Future<void> add(SyncQueueModel item) async => await _box.put(item.id, item);

  Future<void> markSynced(String id) async {
    final item = _box.get(id);
    if (item != null) {
      item.synced = true;
      await item.save();
    }
  }

  Future<void> clear() async => await _box.clear();
}