import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:gym_management_app/data/local/hive_boxes.dart';
import 'package:gym_management_app/data/network/api_client.dart';
import 'package:gym_management_app/data/network/api_endpoints.dart';
import '../models/member_model.dart';
import 'base_repository.dart';

class MemberRepository extends BaseRepository<MemberModel> {
  MemberRepository() : super(HiveBoxes.members, ApiEndpoints.members);

  List<MemberModel> getAllMembersLocal() => box.values.toList();

 Future<List<MemberModel>> getAllMembers({
  String? search,
  int page = 1,
  int limit = 20,
}) async {
  try {
    final response = await ApiClient.get(
      endpoint,
      params: {
        'search': search,
        'page': page,
        'limit': limit,
      },
    );

    print("========== MEMBER API ==========");
    print(response.realUri);
    print(response.data);
    print("===============================");

    final List<dynamic> data = response.data['data'];

    return data.map((e) => MemberModel.fromJson(e)).toList();
  } catch (e) {
    print(e);
    return getAllMembersLocal();
  }
}
    Future<bool> saveMemberToDatabase(MemberModel member) async {
    try {
      final Map<String, dynamic> data = member.toJson();
      
      // Clean data before sending
      data.remove('id');
      data.remove('_id');

      print("=== SENDING MEMBER TO BACKEND ===");
      print("Payload: ${jsonEncode(data)}");   // Add this for better visibility

   final response = await ApiClient.post(
        ApiEndpoints.members,
        data: data,  // Changed from positional to named
      );


      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.data}");

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("API Save Error: $e");
      if (e is DioException) {
        print("Dio Error Data: ${e.response?.data}");
      }
      return false;
    }
  }

  Future<void> addMember(MemberModel member) async {
    print("=== addMember called in Repository for ${member.fullName} ===");
    
    final isSaved = await saveMemberToDatabase(member);
    
    if (isSaved) {
      print("✅ Member successfully saved to MongoDB");
    } else {
      print("❌ API call failed, saving locally only");
      await add(member, id: member.id);
    }
  }

Future<void> updateMember(MemberModel member) async {
    try {
      // FIX: Use named parameter 'data'
      await ApiClient.put(
        '$endpoint/${member.id}',
        data: member.toJson(),  // Changed from positional to named
      );
      await box.put(member.id, member);
    } catch (e) {
      print("API Update Error: $e");
      await update(member, id: member.id);
    }
  }

 Future<void> deleteMember(String id) async {
  print("========== REPOSITORY DELETE ==========");
  print("ID = $id");

  if (id.isEmpty) {
    print("ID IS EMPTY");
    return;
  }

  try {
    final url = '$endpoint/$id';

    print("DELETE URL");
    print(url);

    final response = await ApiClient.delete(url);

    print("STATUS = ${response.statusCode}");

    if (response.statusCode == 200) {
      await box.delete(id);
      print("DELETE SUCCESS");
    }
  } catch (e) {
    print("DELETE ERROR");
    print(e);
  }
}

 Future<MemberModel?> getMemberById(String id) async {
  try {
    final response = await ApiClient.get('$endpoint/$id');
    return MemberModel.fromJson(response.data['data']);
  } catch (e) {
    // Fallback to local
    return box.get(id);
  }
}
}