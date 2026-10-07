import 'package:gym_management_app/data/models/gym_config_model.dart';
import 'package:gym_management_app/data/models/member_model.dart';

class BranchHelper {
  // Get branch name from ID
  static String getBranchName(String? branchId, List<BranchModel> branches) {
    if (branchId == null || branchId.isEmpty) return 'Unassigned';
    try {
      final branch = branches.firstWhere((b) => b.id == branchId);
      return branch.name;
    } catch (e) {
      return 'Unassigned';
    }
  }

  // Filter members by branch
  static List<MemberModel> filterByBranch(
    List<MemberModel> members,
    String? branchId,
  ) {
    if (branchId == null) return members;
    return members.where((m) => m.branchId == branchId).toList();
  }

  // Get branch statistics
  static Map<String, dynamic> getBranchStats(
    List<MemberModel> members,
    String branchId,
  ) {
    final branchMembers = members.where((m) => m.branchId == branchId).toList();
    final activeMembers = branchMembers
        .where((m) => m.membershipStatus == 'active')
        .toList();
    
    return {
      'total': branchMembers.length,
      'active': activeMembers.length,
      'inactive': branchMembers.length - activeMembers.length,
    };
  }
}