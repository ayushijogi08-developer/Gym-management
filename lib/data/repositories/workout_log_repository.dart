
import 'package:gym_management_app/data/local/hive_boxes.dart';
import 'package:gym_management_app/data/network/api_client.dart';
import 'package:gym_management_app/data/network/api_endpoints.dart';
import '../models/workout_log_model.dart';
import 'base_repository.dart';

class WorkoutLogRepository extends BaseRepository<WorkoutLogModel> {
  // Pass the Hive box name and API endpoint to the BaseRepository
  WorkoutLogRepository() : super(HiveBoxes.workoutLogs, ApiEndpoints.workoutLogs);

  // GET ALL LOGS
  List<WorkoutLogModel> getAll() {
    return box.values.toList();
  }
  
  // GET LOGS FOR A SPECIFIC DATE (Local filter)
  List<WorkoutLogModel> getForDate(String memberId, DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    return box.values.where((log) =>
        log.memberId == memberId &&
        log.date.toIso8601String().split('T')[0] == dateStr).toList();
  }

  // ADD OR UPDATE (Uses BaseRepository's Optimistic + Queue logic)
  Future<void> addOrUpdate(WorkoutLogModel log) async {
    if (box.containsKey(log.id)) {
      await update(log, id: log.id);
    } else {
      await add(log, id: log.id);
    }
  }
// lib/data/repositories/workout_log_repository.dart

Future<void> fetchLogsForMember(String memberId) async {
  try {
    // Correct way to build the URL using your endpoint constant
    final String url = '${ApiEndpoints.workoutLogs}/member/$memberId/range';
    
    final response = await ApiClient.get(url);
    
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'] ?? [];
      for (var json in data) {
        final log = WorkoutLogModel.fromJson(json);
        await addOrUpdate(log);
      }
    }
  } catch (e) {
    print("❌ Repository Error: $e");
  }
}
  Future<void> markCompletedOnServer(WorkoutLogModel log) async {
    try {
      final response = await ApiClient.post(
        '${ApiEndpoints.workoutLogs}/mark-completed',
        data: {  // Changed to named parameter
          'memberId': log.memberId,
          'workoutPlanId': log.workoutPlanId,
          'exerciseName': log.exerciseName,
          'sets': log.actualSetsCompleted,
          'reps': log.reps,
          'weightKg': log.weightUsedKg,
          'calories': log.caloriesBurned,
          'durationMinutes': log.workoutDurationMinutes,
          'date': log.date.toIso8601String(),
        },
      );
      print("✅ Workout log synced to server: ${response.data}");
      await box.put(log.id, log);
    } catch (e) {
      print("❌ Error syncing workout log: $e");
      await addOrUpdate(log);
    }
  }
}