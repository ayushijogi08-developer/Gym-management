import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models/member_model.dart';
import '../data/models/subscription_model.dart';
import '../data/models/plan_model.dart';
import '../data/models/payment_model.dart';
import '../data/models/attendance_model.dart';
import '../data/repositories/member_repository.dart';
import '../data/repositories/subscription_repository.dart';
import '../data/repositories/plan_repository.dart';
import '../data/repositories/payment_repository.dart';
import '../data/repositories/attendance_repository.dart';
import '../utils/subscription_status_helper.dart';

/// Data model binding a Member with their active Subscription and Plan details.
class MemberSubscriptionItem {
  final MemberModel member;
  final SubscriptionModel? subscription;
  final PlanModel? plan;

  MemberSubscriptionItem({
    required this.member,
    this.subscription,
    this.plan,
  });

  String get memberId => member.id;
  String get memberName => member.fullName;
  String get email => member.email;
  String get phone => member.phone;
  String? get photoPath => member.photoPath;
  String? get trainerAssigned => member.trainerAssigned;

  String get planName {
    if (plan != null && plan!.planName.isNotEmpty) {
      return plan!.planName;
    }
    if (member.planName.isNotEmpty) {
      return member.planName;
    }
    return 'No Active Plan';
  }

  /// Evaluates status using SubscriptionStatusHelper or member status fallback
  String get status {
    if (subscription != null) {
      return SubscriptionStatusHelper.computeStatus(subscription);
    }
    return member.membershipStatus.isEmpty ? 'no_plan' : member.membershipStatus.toLowerCase();
  }

  Color get statusColor => SubscriptionStatusHelper.getStatusColor(status);

  String get statusLabel {
    switch (status) {
      case 'active':
        return 'Active';
      case 'expiring_soon':
        return 'Expiring Soon';
      case 'grace_period':
        return 'Grace Period';
      case 'expired':
        return 'Expired';
      case 'paused':
        return 'Paused';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'No Plan';
    }
  }

  DateTime get expiryDate {
    if (subscription != null) {
      return subscription!.endDate;
    }
    return member.expiryDate;
  }

  String get formattedExpiry {
    return DateFormat('MMM dd, yyyy').format(expiryDate);
  }

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final exp = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return exp.difference(today).inDays;
  }

  String get remainingText {
    final days = daysRemaining;
    if (days < 0) {
      return 'Expired ${days.abs()} ${days.abs() == 1 ? 'day' : 'days'} ago';
    } else if (days == 0) {
      return 'Expires Today';
    } else {
      return '$days ${days == 1 ? 'day' : 'days'} remaining';
    }
  }
}

/// Provider managing real-time data fetching and analytics for the Admin Dashboard.
class AdminDashboardProvider extends ChangeNotifier {
  final MemberRepository _memberRepo = MemberRepository();
  final SubscriptionRepository _subRepo = SubscriptionRepository();
  final PlanRepository _planRepo = PlanRepository();
  final PaymentRepository _paymentRepo = PaymentRepository();
  final AttendanceRepository _attendanceRepo = AttendanceRepository();

  bool _isLoading = false;
  String? _errorMessage;

  // Real-time computed metrics
  int _todaysMembersCount = 0;
  int _activeMembershipsCount = 0;
  int _expiredMembershipsCount = 0;
  int _totalMembersCount = 0;
  double _totalRevenue = 0.0;
  double _todayRevenue = 0.0;
  int _attendanceTodayCount = 0;

  // Subscriptions list data
  List<MemberSubscriptionItem> _memberSubscriptionItems = [];
  List<PlanModel> _allPlans = [];

  // Filter state
  String _searchQuery = '';
  String _statusFilter = 'All'; // 'All', 'Active', 'Expiring Soon', 'Expired', 'Paused'
  String _selectedPlanFilter = 'All';

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get todaysMembersCount => _todaysMembersCount;
  int get activeMembershipsCount => _activeMembershipsCount;
  int get expiredMembershipsCount => _expiredMembershipsCount;
  int get totalMembersCount => _totalMembersCount;
  double get totalRevenue => _totalRevenue;
  double get todayRevenue => _todayRevenue;
  int get attendanceTodayCount => _attendanceTodayCount;

  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  String get selectedPlanFilter => _selectedPlanFilter;

  List<MemberSubscriptionItem> get allItems => _memberSubscriptionItems;

  List<String> get availablePlanNames {
    final names = {'All'};
    for (var plan in _allPlans) {
      if (plan.planName.isNotEmpty) {
        names.add(plan.planName);
      }
    }
    return names.toList();
  }

  /// Filtered items based on searchQuery, statusFilter, and selectedPlanFilter
  List<MemberSubscriptionItem> get filteredMemberSubscriptions {
    return _memberSubscriptionItems.where((item) {
      // 1. Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatch = item.memberName.toLowerCase().contains(query);
        final emailMatch = item.email.toLowerCase().contains(query);
        final phoneMatch = item.phone.contains(query);
        final planMatch = item.planName.toLowerCase().contains(query);
        if (!nameMatch && !emailMatch && !phoneMatch && !planMatch) {
          return false;
        }
      }

      // 2. Status Filter
      if (_statusFilter != 'All') {
        final filterLower = _statusFilter.toLowerCase().replaceAll(' ', '_');
        if (filterLower == 'active' && item.status != 'active') return false;
        if (filterLower == 'expiring_soon' && item.status != 'expiring_soon') return false;
        if (filterLower == 'expired' && item.status != 'expired' && item.status != 'cancelled') return false;
        if (filterLower == 'paused' && item.status != 'paused') return false;
      }

      // 3. Plan Filter
      if (_selectedPlanFilter != 'All') {
        if (item.planName.toLowerCase() != _selectedPlanFilter.toLowerCase()) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  AdminDashboardProvider() {
    fetchDashboardData();
  }

  /// Fetch real-time metrics and member subscriptions from Backend API / Local Repositories
  Future<void> fetchDashboardData({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      // 1. Fetch Members (Try API first, fallback to local)
      List<MemberModel> members = [];
      try {
        members = await _memberRepo.getAllMembers();
      } catch (e) {
        debugPrint("Error fetching members from API, fallback local: $e");
        members = _memberRepo.getAllMembersLocal();
      }

      // 2. Fetch Subscriptions
      List<SubscriptionModel> subscriptions = [];
      try {
        subscriptions = await _subRepo.getAll();
      } catch (e) {
        subscriptions = _subRepo.getAllLocal();
      }

      // 3. Fetch Plans
      try {
        _allPlans = _planRepo.getAllPlansLocal();
      } catch (e) {
        _allPlans = [];
      }

      // 4. Fetch Payments
      List<PaymentModel> payments = [];
      try {
        payments = await _paymentRepo.getAll();
      } catch (e) {
        payments = _paymentRepo.getAllLocal();
      }

      // 5. Fetch Attendance
      List<AttendanceModel> todaysAttendance = [];
      try {
        todaysAttendance = _attendanceRepo.getByDateLocal(DateTime.now());
      } catch (e) {
        todaysAttendance = [];
      }

      // Calculate Real-Time Metrics
      _totalMembersCount = members.length;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // Members who joined today
      _todaysMembersCount = members.where((m) =>
          m.joiningDate.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
          m.joiningDate.isBefore(todayEnd.add(const Duration(seconds: 1)))).length;

      // Active & Expired Count
      int activeCount = 0;
      int expiredCount = 0;

      // Map member subscriptions
      List<MemberSubscriptionItem> items = [];

      for (var member in members) {
        // Find subscription for member
        SubscriptionModel? activeSub;
        final memberSubs = subscriptions.where((s) => s.memberId == member.id).toList();
        if (memberSubs.isNotEmpty) {
          // Sort by endDate descending to get latest
          memberSubs.sort((a, b) => b.endDate.compareTo(a.endDate));
          activeSub = memberSubs.first;
        }

        // Find plan
        PlanModel? plan;
        if (activeSub != null) {
          plan = _allPlans.where((p) => p.id == activeSub!.planId).firstOrNull;
        }
        plan ??= _allPlans.where((p) => p.planName.toLowerCase() == member.planName.toLowerCase()).firstOrNull;

        final item = MemberSubscriptionItem(
          member: member,
          subscription: activeSub,
          plan: plan,
        );

        items.add(item);

        if (item.status == 'active' || item.status == 'expiring_soon') {
          activeCount++;
        } else if (item.status == 'expired' || item.status == 'cancelled') {
          expiredCount++;
        }
      }

      _activeMembershipsCount = activeCount;
      _expiredMembershipsCount = expiredCount;
      _memberSubscriptionItems = items;

      // Total & Today Revenue
      double totalRev = 0.0;
      double todayRev = 0.0;

      for (var p in payments) {
        if (p.status != 'refunded') {
          totalRev += p.amount;
          if (p.paymentDate.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
              p.paymentDate.isBefore(todayEnd.add(const Duration(seconds: 1)))) {
            todayRev += p.amount;
          }
        }
      }

      _totalRevenue = totalRev;
      _todayRevenue = todayRev;
      _attendanceTodayCount = todaysAttendance.length;

    } catch (e, stack) {
      debugPrint("❌ AdminDashboardProvider error: $e\n$stack");
      _errorMessage = "Failed to load dashboard data: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void setPlanFilter(String plan) {
    _selectedPlanFilter = plan;
    notifyListeners();
  }

  Future<void> refresh() async {
    await fetchDashboardData(silent: false);
  }
}
