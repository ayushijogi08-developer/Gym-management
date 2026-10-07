import '../data/models/member_model.dart';
import '../data/repositories/member_repository.dart';
// New import
import '../providers/subscription_provider.dart'; // New import
import 'package:provider/provider.dart'; // If not already used
import '../providers/timeline_provider.dart'; // Ensure this is imported
import 'package:flutter/material.dart'; // Required for BuildContext
import '../domain/entities/qr_payload.dart';

class MemberProvider extends ChangeNotifier {
  final MemberRepository _repository = MemberRepository();

  List<MemberModel> _allMembers = [];
  String _searchQuery = '';

  List<MemberModel> get members {
    if (_searchQuery.isEmpty) return _allMembers;
    final query = _searchQuery.toLowerCase();
    return _allMembers.where((m) {
      return m.fullName.toLowerCase().contains(query) ||
          m.phone.contains(query) ||
          m.email.toLowerCase().contains(query);
    }).toList();
  }

  MemberProvider() {
    loadMembers();
  }
  String getMemberName(String memberId) {
  try {
    return _allMembers.firstWhere((m) => m.id == memberId).fullName;
  } catch (e) {
    return 'Unknown Member';
  }
}

  // lib/providers/member_provider.dart

// Ensure your loadMembers method is exactly this:
Future<void> loadMembers() async {
  try {
    debugPrint("Fetching members from API...");
    final membersFromApi = await _repository.getAllMembers();
    
    // Only update if we actually got data, otherwise keep existing
    if (membersFromApi.isNotEmpty) {
      _allMembers = membersFromApi;
      notifyListeners();
    }
  } catch (e) {
    debugPrint("Failed to load members: $e");
    // Fallback
    _allMembers = _repository.getAllMembersLocal();
    notifyListeners();
  }
}

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Change 'Future<void>' to 'Future<MemberModel>'
  Future<MemberModel> addMember(
    MemberModel member, 
    SubscriptionProvider subProvider, 
    BuildContext context, {
    String? branchId,
    String? branchName,
  }) async {
    print("=== addMember called in Provider ===");

    if (branchId != null) {
      member.branchId = branchId;
      member.branchName = branchName ?? '';
    }

    final payload = QrPayload(
      memberId: member.id,
      name: member.fullName,
      expiryDate: member.expiryDate,
      membershipStatus: member.membershipStatus,
      planName: member.planName,
    );
    member.qrData = payload.toRawString();

    // Save to API / Database
    await _repository.addMember(member);

    // Add to local list
    _allMembers.add(member); 
    notifyListeners();
    
    context.read<TimelineProvider>().logEvent(
      memberId: member.id,
      eventType: 'joined',
      title: 'Joined the Gym',
      subtitle: '${member.planName} Plan',
      iconAsset: 'assets/icons/joined.png',
    );

    // RELOAD DATA TO GET THE REAL MONGODB ID
    await loadMembers();
    
    // Attempt to find the newly created member by email to get the correct _id
    final realMember = _allMembers.firstWhere(
      (m) => m.email == member.email,
      orElse: () => member,
    );

    // ✅ RETURN THE REAL MEMBER
    return realMember; 
  }

   Future<void> updateMember(MemberModel member) async {
    try {
      // 1. Send update to the API
      await _repository.updateMember(member);
      
      // 2. Find the member in your local list
      final index = _allMembers.indexWhere((m) => m.id == member.id);
      
      // 3. Update the local list IMMEDIATELY (without waiting for a full reload)
      if (index != -1) {
        _allMembers[index] = member;
        notifyListeners(); // This instantly updates your UI (Members & Subscriptions screen)
      }
      
      // 4. Optional: Refresh from API in background 1 second later to sync correctly
      Future.delayed(const Duration(seconds: 1), () async {
        await loadMembers();
      });
      
    } catch (e) {
      debugPrint("Error updating member: $e");
      rethrow; // Pass error back to the dialog
    }
  }
Future<void> refreshMembers() async {
  await loadMembers();
  notifyListeners();
}
  Future<void> deleteMember(String id) async {
  debugPrint("========== DELETE PROVIDER ==========");
  debugPrint("ID = $id");

  await _repository.deleteMember(id);

  debugPrint("DELETE FINISHED");

  await loadMembers();
}

  Future<void> regenerateQr(String memberId) async {
    // FIX: Await the repository result
    final member = await _repository.getMemberById(memberId);
    if (member == null) return;

    final payload = QrPayload(
      memberId: member.id,
  name: member.fullName,
  expiryDate: member.expiryDate,
  membershipStatus: member.membershipStatus,
  planName: member.planName,
    );
    member.qrData = payload.toRawString();
    
    await _repository.updateMember(member);
    loadMembers();
  }
} 