
import 'package:gym_management_app/data/local/hive_boxes.dart';
import 'package:gym_management_app/data/network/api_client.dart';
import 'package:gym_management_app/data/network/api_endpoints.dart';
import '../models/app_user_model.dart';
import 'base_repository.dart';

class AppUserRepository extends BaseRepository<AppUserModel> {
  // Pass the Hive box name and API endpoint to the BaseRepository
  AppUserRepository() : super(HiveBoxes.users, ApiEndpoints.users);

  // GET ALL USERS (API Fetch)
  Future<List<AppUserModel>> getAllUsersFromApi() async {
    try {
      final response = await ApiClient.get(endpoint);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => AppUserModel.fromJson(json)).toList();
    } catch (e) {
      return box.values.toList(); // Return local cache if API fails
    }
  }

  // ADD USER (Uses BaseRepository's Optimistic + Queue logic)
  Future<void> addUser(AppUserModel user) async {
    await add(user, id: user.id);
  }

  // UPDATE USER (Uses BaseRepository's Optimistic + Queue logic)
  Future<void> updateUser(AppUserModel user) async {
    await update(user, id: user.id);
  }

  // DELETE USER (Uses BaseRepository's logic)
  Future<void> deleteUser(String id) async {
    await delete(id);
  }

Future<String?> resetPassword(String memberId) async {
  try {
    // ✅ Use the member endpoint
    final response = await ApiClient.put(
      '$endpoint/member/$memberId/reset-password',
      data: {},
    );
    return response.data['tempPassword'];
  } catch (e) {
    print('Error resetting password: $e');
    return null;
  }
}
  // LOOKUP (Local-only, very fast)
  AppUserModel? getUserByEmail(String email) {
    return box.values.where((u) => u.email.toLowerCase() == email.toLowerCase()).firstOrNull;
  }

  AppUserModel? getUserById(String id) => box.get(id);
}