import 'package:gym_management_app/providers/timeline_provider.dart';
import 'package:gym_management_app/services/achievement_checker_service.dart';
import 'package:gym_management_app/services/goal_recalc_hook.dart';
import 'package:provider/provider.dart';
import '../data/models/attendance_model.dart';
import '../data/models/member_model.dart';
import '../data/repositories/attendance_repository.dart';
import 'package:flutter/material.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceRepository _repository = AttendanceRepository();

  List<AttendanceModel> _allAttendance = []; 
  List<AttendanceModel> _allRecords = [];
  List<AttendanceModel> _filteredRecords = [];
  DateTime selectedDate = DateTime.now();
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;
  
  // Pagination
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  List<AttendanceModel> get allAttendance => _allAttendance;
  List<AttendanceModel> get allRecords => _allRecords;
  List<AttendanceModel> get filteredRecords => _filteredRecords;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;

  List<AttendanceModel> get todaysAttendance => 
      _repository.getByDateLocal(DateTime.now());

  List<AttendanceModel> get attendanceForSelectedDate => 
      _repository.getByDateLocal(selectedDate);

  AttendanceProvider() {
    // Defer initial load to a post-frame callback so the synchronous
    // notifyListeners() inside loadAttendance() never fires while a parent
    // widget is still mounting/building. Without this, Provider can throw
    // "setState() or markNeedsBuild() called during build".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadAttendance();
    });
  }

  void loadAttendance() {
    _allAttendance = _repository.getAllLocal();
    _allRecords = _repository.getAllLocal();
    _applyFilters();
    _safeNotify();
  }

  /// Wraps [notifyListeners] so it never runs synchronously during a
  /// build phase. If we're already inside an active frame, schedule the
  /// notification for after the next frame; otherwise notify immediately.
  void _safeNotify() {
    final binding = WidgetsBinding.instance;
    // transientCallbackCount > 0 means we're currently inside a frame's
    // build/layout/paint phase. Defer to avoid the
    // "setState() or markNeedsBuild() called during build" assertion.
    if (binding.transientCallbackCount > 0) {
      binding.addPostFrameCallback((_) => notifyListeners());
    } else {
      notifyListeners();
    }
  }

  // ✅ Apply filters and pagination
  void _applyFilters() {
    var records = _allRecords;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      records = records.where((a) =>
        a.memberName.toLowerCase().contains(query)
      ).toList();
    }
    
    _filteredRecords = records;
  }

  // ✅ Search with debounce
  void search(String query) {
    _searchQuery = query;
    _currentPage = 0;
    _applyFilters();
    _safeNotify();
  }

  // ✅ Fetch all attendance records with pagination
  Future<void> fetchAllAttendance({bool reset = true}) async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    if (reset) {
      _allRecords = [];
      _currentPage = 0;
      _hasMore = true;
    }
    notifyListeners();

    try {
      print('🌐 Fetching all attendance from API...');
      final records = await _repository.getAll();
      
      if (records.isNotEmpty) {
        _allRecords = records;
        _applyFilters();
        print('✅ Loaded ${_allRecords.length} records');
      } else {
        _allRecords = _repository.getAllLocal();
        _applyFilters();
      }
    } catch (e) {
      _error = e.toString();
      print('❌ Error fetching all attendance: $e');
      _allRecords = _repository.getAllLocal();
      _applyFilters();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Get paginated records for display
  List<AttendanceModel> getPaginatedRecords() {
    final start = 0;
    final end = _pageSize;
    if (start >= _filteredRecords.length) return [];
    return _filteredRecords.sublist(start, end.clamp(0, _filteredRecords.length));
  }

  // ✅ Load more records (infinite scroll)
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    
    _isLoadingMore = true;
    notifyListeners();
    
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    _currentPage++;
    _hasMore = (_currentPage + 1) * _pageSize < _filteredRecords.length;
    _isLoadingMore = false;
    notifyListeners();
  }

  // Fetch for a specific member
  Future<void> fetchForMember(String memberId) async {
    if (memberId.isEmpty) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final records = await _repository.fetchByMember(memberId);
      _allAttendance = records;
      _allRecords = records;
      _applyFilters();
      print("✅ Loaded ${records.length} attendance records for member");
    } catch (e) {
      print("❌ Error fetching attendance: $e");
      _allAttendance = _repository.getByMemberLocal(memberId);
      _allRecords = _repository.getByMemberLocal(memberId);
      _applyFilters();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recordCheckIn(MemberModel member) async {
    final record = AttendanceModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      memberId: member.id,
      memberName: member.fullName,
      timestamp: DateTime.now(),
      gateId: 'Main Gate',
      entryType: 'checkIn',
    );
    await _repository.addAttendance(record);
    _allAttendance = _repository.getAllLocal();
    _allRecords = _repository.getAllLocal();
    _applyFilters();
    notifyListeners();
  }

  Future<void> checkIn({
    required String memberId,
    required String memberName,
    required String gateId,
    required String entryType,
    required BuildContext context,
  }) async {
    if (memberId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member ID not found')),
      );
      return;
    }

    final attendance = AttendanceModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      memberId: memberId,
      memberName: memberName,
      timestamp: DateTime.now(),
      gateId: gateId,
      entryType: entryType,
    );

    try {
      await _repository.addAttendance(attendance);
      _allAttendance = _repository.getAllLocal();
      _allRecords = _repository.getAllLocal();
      _applyFilters();
      notifyListeners();

      context.read<TimelineProvider>().logEvent(
        memberId: memberId,
        eventType: 'attendance',
        title: 'Gym Check-in',
        subtitle: 'Entry: $entryType at $gateId',
        iconAsset: 'assets/icons/attendance.png',
      );

      await AchievementCheckerService.checkAfterAttendance(context, memberId);

      // AUTOMATIC GOAL UPDATES
      // Fan out to attendance goals via the centralized post-save
      // hook. This was the gap before Phase 3 — attendance goals
      // never updated from a check-in because no fan-out existed.
      await GoalRecalcHook.instance.onMetricSourceSaved(
        memberId: memberId,
        source: MetricSource.attendance,
        context: context,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Check-in successful for $memberName'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("❌ Check-in error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void setSelectedDate(DateTime date) {
    selectedDate = date;
    _safeNotify();
  }

  int totalVisits(String memberId) {
    return allAttendance.where((a) => a.memberId == memberId).length;
  }

  int getAllVisits() {
    return _allRecords.length;
  }

  int getTodayVisits() {
    final today = DateTime.now();
    return _allRecords.where((a) =>
      a.timestamp.year == today.year &&
      a.timestamp.month == today.month &&
      a.timestamp.day == today.day
    ).length;
  }

  List<AttendanceModel> getByDateRange(DateTime start, DateTime end) {
    return _allRecords.where((a) =>
      a.timestamp.isAfter(start.subtract(const Duration(days: 1))) &&
      a.timestamp.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }

  int currentStreak(String memberId) {
    final logs = allAttendance
        .where((a) => a.memberId == memberId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (logs.isEmpty) return 0;

    int streak = 0;
    DateTime current = DateTime.now();
    for (var log in logs) {
      final logDate = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
      final expectedDate = current.subtract(Duration(days: streak));
      if (logDate.isAtSameMomentAs(expectedDate)) {
        streak++;
      } else if (logDate.isBefore(expectedDate)) {
        break;
      }
    }
    return streak;
  }

  int longestStreak(String memberId) {
    final logs = allAttendance.where((a) => a.memberId == memberId).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (logs.isEmpty) return 0;

    int maxStreak = 1;
    int currentStreak = 1;
    DateTime? prevDate;

    for (var log in logs) {
      final date = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
      if (prevDate != null && date.difference(prevDate).inDays == 1) {
        currentStreak++;
        maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;
      } else if (prevDate != null && date.difference(prevDate).inDays > 1) {
        currentStreak = 1;
      }
      prevDate = date;
    }
    return maxStreak;
  }

  int daysWithoutVisitThisMonth(String memberId) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    int missed = 0;

    for (int i = 0; i < now.day; i++) {
      final day = firstDayOfMonth.add(Duration(days: i));
      final hasVisit = allAttendance.any((a) =>
          a.memberId == memberId &&
          a.timestamp.year == day.year &&
          a.timestamp.month == day.month &&
          a.timestamp.day == day.day);
      if (!hasVisit) missed++;
    }
    return missed;
  }

  Future<void> clearAll() async {
    await _repository.box.clear();
    _allAttendance = [];
    _allRecords = [];
    _applyFilters();
    _safeNotify();
  }
}