// import 'package:hive/hive.dart';
// import '../local/hive_boxes.dart';
// import '../models/chat_message_model.dart';

// class ChatHistoryRepository {
//   Box<ChatMessageModel> get _box => Hive.box<ChatMessageModel>(HiveBoxes.chatHistory);

//   List<ChatMessageModel> getForMember(String memberId) =>
//       _box.values.where((m) => m.memberId == memberId).toList()
//         ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

//   Future<void> add(ChatMessageModel message) async => await _box.put(message.id, message);

//   Future<void> clearForMember(String memberId) async {
//     final messages = _box.values.where((m) => m.memberId == memberId).toList();
//     for (var msg in messages) {
//       await _box.delete(msg.id);
//     }
//   }
// }
import 'package:gym_management_app/data/local/hive_boxes.dart';
import 'package:gym_management_app/data/network/api_client.dart';
import 'package:gym_management_app/data/network/api_endpoints.dart';
import '../models/chat_message_model.dart';
import 'base_repository.dart';

class ChatHistoryRepository extends BaseRepository<ChatMessageModel> {
  // Pass the Hive box name and API endpoint to the BaseRepository
  ChatHistoryRepository() : super(HiveBoxes.chatHistory, ApiEndpoints.chatMessages);

  // GET CHAT HISTORY FOR A MEMBER
  Future<List<ChatMessageModel>> getForMember(String memberId) async {
    try {
      final response = await ApiClient.get('$endpoint/history/$memberId');
      final List<dynamic> data = response.data['data'];
      
      return data.map((json) => ChatMessageModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching chat history: $e');
      return [];
    }
  }
List<ChatMessageModel> getLocalHistory(String memberId) {
    return box.values
        .where((m) => m.memberId == memberId)
        .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
  // ADD A NEW MESSAGE (Uses BaseRepository's Optimistic + Queue logic)
  Future<void> addMessage(ChatMessageModel message) async {
    await add(message, id: message.id);
  }

  // CLEAR HISTORY FOR MEMBER
  Future<bool> clearForMember(String memberId) async {
    try {
      // 1. Clear from local storage
      final messages = box.values.where((m) => m.memberId == memberId).toList();
      for (var msg in messages) {
        await box.delete(msg.id);
      }
      
      // 2. Sync deletion to backend
      await ApiClient.delete('$endpoint/history/$memberId');
      return true;
    } catch (e) {
      print('Error clearing chat history: $e');
      return false;
    }
  }
}