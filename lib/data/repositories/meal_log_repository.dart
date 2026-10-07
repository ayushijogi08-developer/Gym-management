import 'package:gym_management_app/data/local/hive_boxes.dart';
import 'package:gym_management_app/data/network/api_client.dart';
import 'package:gym_management_app/data/network/api_endpoints.dart';
import '../models/meal_log_model.dart';
import 'base_repository.dart';

class MealLogRepository extends BaseRepository<MealLogModel> {
  MealLogRepository() : super(HiveBoxes.mealLogs, ApiEndpoints.mealLogs);

  // GET ALL LOGS
  List<MealLogModel> getAll() {
    return box.values.toList();
  }

  // GET LOGS FOR A SPECIFIC DATE
  List<MealLogModel> getForDate(String memberId, DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    return box.values.where((log) =>
        log.memberId == memberId &&
        log.date.toIso8601String().split('T')[0] == dateStr).toList();
  }

  // ADD OR UPDATE
  Future<void> addOrUpdate(MealLogModel log) async {
    if (box.containsKey(log.id)) {
      await update(log, id: log.id);
    } else {
      await add(log, id: log.id);
    }
  }

  // DELETE
  @override
  Future<void> delete(String id) async {
    await box.delete(id);
    try {
      await ApiClient.delete('$endpoint/$id');
    } catch (e) {
      print('Error deleting meal log: $e');
    }
  }

  // FETCH FROM API
  Future<void> fetchForMember(String memberId) async {
    try {
      final response = await ApiClient.get('$endpoint/member/$memberId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        for (var json in data) {
          final log = MealLogModel.fromJson(json);
          await addOrUpdate(log);
        }
      }
    } catch (e) {
      print('Error fetching meal logs: $e');
    }
  }
}