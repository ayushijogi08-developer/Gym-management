// import 'package:hive/hive.dart';
// import '../local/hive_boxes.dart';
// import '../models/subscription_model.dart';

// class SubscriptionRepository {
//   Box<SubscriptionModel> get _box => Hive.box<SubscriptionModel>(HiveBoxes.subscriptions);

//   List<SubscriptionModel> getAll() => _box.values.toList();

//   SubscriptionModel? getById(String id) => _box.get(id);

//   List<SubscriptionModel> getByMember(String memberId) =>
//       _box.values.where((s) => s.memberId == memberId).toList();

//   Future<void> add(SubscriptionModel sub) async => await _box.put(sub.id, sub);

//   Future<void> update(SubscriptionModel sub) async => await sub.save();

//   Future<void> delete(String id) async => await _box.delete(id);
// }
import 'package:gym_management_app/data/local/hive_boxes.dart';
import 'package:gym_management_app/data/network/api_client.dart';
import 'package:gym_management_app/data/network/api_endpoints.dart';
import '../models/subscription_model.dart';
import 'base_repository.dart';

class SubscriptionRepository extends BaseRepository<SubscriptionModel> {
  // Pass the Hive box name and API endpoint to the BaseRepository
  SubscriptionRepository() : super(HiveBoxes.subscriptions, ApiEndpoints.subscriptions);

List<SubscriptionModel> getAllLocal() => box.values.toList();
  List<SubscriptionModel> getByMemberLocal(String memberId) =>
      box.values.where((s) => s.memberId == memberId).toList();
      
  // GET ALL SUBSCRIPTIONS (Fetch from API)
  Future<List<SubscriptionModel>> getAll() async {
    try {
      final response = await ApiClient.get(endpoint);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => SubscriptionModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching subscriptions: $e');
      return box.values.toList(); // Fallback to local storage if API fails
    }
  }

  // GET SUBSCRIPTION BY ID
  Future<SubscriptionModel?> getById(String id) async {
    try {
      final response = await ApiClient.get('$endpoint/$id');
      final sub = SubscriptionModel.fromJson(response.data['data']);
      await box.put(id, sub); // Update local cache
      return sub;
    } catch (e) {
      return box.get(id); // Fallback to local cache
    }
  }

  // GET SUBSCRIPTIONS BY MEMBER ID
  Future<List<SubscriptionModel>> getByMember(String memberId) async {
    try {
      final response = await ApiClient.get(
        endpoint,
        params: {'memberId': memberId},
      );
      final List<dynamic> data = response.data['data'];
      return data.map((json) => SubscriptionModel.fromJson(json)).toList();
    } catch (e) {
      // Filter local cache by memberId
      return box.values.where((s) => s.memberId == memberId).toList();
    }
  }

  // ADD SUBSCRIPTION (Uses BaseRepository's Optimistic + Queue logic)
  Future<void> addSubscription(SubscriptionModel sub) async {
    await add(sub, id: sub.id);
  }

  // UPDATE SUBSCRIPTION (Uses BaseRepository's Optimistic + Queue logic)
  Future<void> updateSubscription(SubscriptionModel sub) async {
    await update(sub, id: sub.id);
  }

  // DELETE SUBSCRIPTION (Uses BaseRepository's logic)
  Future<void> deleteSubscription(String id) async {
    await delete(id);
  }
} 