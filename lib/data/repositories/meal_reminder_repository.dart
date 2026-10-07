
import 'package:gym_management_app/data/local/hive_boxes.dart';
import 'package:gym_management_app/data/network/api_client.dart';
import 'package:gym_management_app/data/network/api_endpoints.dart';
import '../models/meal_reminder_model.dart';
import 'base_repository.dart';

class MealReminderRepository extends BaseRepository<MealReminderModel> {
  // Pass the Hive box name and API endpoint to the BaseRepository
  MealReminderRepository() : super(HiveBoxes.mealReminders, ApiEndpoints.mealReminders);

List<MealReminderModel> getAllLocal() => box.values.toList();

  List<MealReminderModel> getForMemberLocal(String memberId) =>
      box.values.where((r) => r.memberId == memberId).toList();
      
  // GET ALL REMINDERS (API-only for fetching fresh data)
  Future<List<MealReminderModel>> getAll() async {
    try {
      final response = await ApiClient.get(endpoint);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => MealReminderModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching meal reminders: $e');
      return box.values.toList(); // Return local cache on failure
    }
  }

  // GET REMINDERS FOR SPECIFIC MEMBER
  Future<List<MealReminderModel>> getForMember(String memberId) async {
    try {
      final response = await ApiClient.get('$endpoint/member/$memberId');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => MealReminderModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching member reminders: $e');
      return box.values.where((r) => r.memberId == memberId).toList();
    }
  }

  // ADD REMINDER (Uses BaseRepository's Optimistic + Queue logic)
  Future<void> addReminder(MealReminderModel reminder) async {
    await add(reminder, id: reminder.id);
  }

  // UPDATE REMINDER (Uses BaseRepository's Optimistic + Queue logic)
  Future<void> updateReminder(MealReminderModel reminder) async {
    await update(reminder, id: reminder.id);
  }

  // DELETE REMINDER (Uses BaseRepository's logic)
  Future<void> deleteReminder(String id) async {
    await delete(id);
  }
}