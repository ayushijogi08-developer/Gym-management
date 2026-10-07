import 'package:flutter/material.dart';
import 'package:gym_management_app/data/models/body_progress_model.dart';
import 'package:gym_management_app/data/repositories/body_progress_repository.dart';
import 'package:gym_management_app/providers/timeline_provider.dart';
import 'package:gym_management_app/services/achievement_checker_service.dart';
import 'package:gym_management_app/services/goal_recalc_hook.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/auth_provider.dart';

class BodyProgressProvider extends ChangeNotifier {
  final BodyProgressRepository _repo = BodyProgressRepository();
  List<BodyProgressModel> _history = [];
  bool _isLoading = false;

  List<BodyProgressModel> get history => _history;
  bool get isLoading => _isLoading;

  // Get history for a member
  List<BodyProgressModel> getHistory(String memberId) {
    return _history.where((p) => p.memberId == memberId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get latest entry
  BodyProgressModel? getLatest(String memberId) {
    final history = getHistory(memberId);
    return history.isNotEmpty ? history.first : null;
  }

  // Get first entry (starting weight)
  BodyProgressModel? getFirstEntry(String memberId) {
    final history = getHistory(memberId);
    return history.isNotEmpty ? history.last : null;
  }

  // Load from local
  void loadFromLocal() {
    _history = _repo.box.values.toList();
    notifyListeners();
  }

  // Fetch from API
  Future<void> fetchForMember(String memberId) async {
    if (memberId.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final entries = await _repo.getHistoryByMember(memberId);
      _history = entries;
      print("✅ Fetched ${entries.length} body progress entries");
    } catch (e) {
      print("❌ Error fetching body progress: $e");
      _history = _repo.getHistoryByMemberLocal(memberId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add entry
  //
  // The [BuildContext] is captured *before* any `await` so the
  // post-save calls (timeline update, achievement check, error
  // snackbar) never reach for a deactivated widget. If the form
  // screen has been unmounted by the time the save completes, the
  // captured messenger/nav handles will simply be no-ops on the
  // next ancestor in the tree — no more
  // "Looking up a deactivated widget's ancestor is unsafe" error.
  //
  // After the entry is persisted, the provider fans out to any
  // active *automatic* goals the member has. The metric-aware
  // goal pipeline updates goal progress and emits milestone
  // celebrations; the form screen can surface them via the
  // [GoalProvider.pendingCelebrations] notifier.
  Future<void> addEntry(BodyProgressModel entry, BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (!auth.hasPermission('canUpdateBodyMeasurements')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied')),
      );
      return;
    }

    // Generate ID
    entry.id = const Uuid().v4();
    entry.loggedByTrainerId = auth.currentUser?.id;

    // Capture every context-dependent handle *before* the first await
    // so we never touch a deactivated widget after the future resolves.
    final messenger = ScaffoldMessenger.of(context);
    final timelineProvider = context.read<TimelineProvider>();

    try {
      // Save to repository (handles API + local)
      await _repo.addEntry(entry);

      // Refresh local list
      _history = _repo.box.values.toList();

      // Update timeline — use the handle captured above, not `context`.
      timelineProvider.logEvent(
        memberId: entry.memberId,
        eventType: 'measurement',
        title: 'Body Measurement Logged',
        subtitle: '${entry.weightKg} kg',
        iconAsset: 'assets/icons/measurement.png',
      );

      // CHECK ACHIEVEMENTS
      final latest = getLatest(entry.memberId);
      final first = getFirstEntry(entry.memberId);

      if (latest != null && first != null && latest != first) {
        try {
          await AchievementCheckerService.checkAfterBodyProgress(
            context,
            entry.memberId,
            latest.weightKg,
            first.weightKg,
          );
        } catch (achErr) {
          print("⚠️ Achievement check failed: $achErr");
        }
      }

      // AUTOMATIC GOAL UPDATES
      // Fire the post-save hook. The engine no-ops on goals whose
      // metricKind doesn't match this entry's unit, so a single
      // hook call covers weight, muscle, body fat, measurement,
      // and water goals in one shot.
      await GoalRecalcHook.instance.onMetricSourceSaved(
        memberId: entry.memberId,
        source: MetricSource.bodyProgress,
        context: context,
      );

      notifyListeners();

      print("✅ Body progress entry added successfully");
    } catch (e) {
      print("❌ Error adding body progress entry: $e");
      // Use the captured messenger rather than the original context.
      messenger.showSnackBar(
        SnackBar(content: Text('Error saving: ${e.toString()}')),
      );
      rethrow;
    }
  }

  // Update entry
  Future<void> updateEntry(BodyProgressModel entry, BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (!auth.hasPermission('canUpdateBodyMeasurements')) return;

    await _repo.updateEntry(entry);

    _history = _repo.box.values.toList();

    final latest = getLatest(entry.memberId);
    final first = getFirstEntry(entry.memberId);

    if (latest != null && first != null) {
      await AchievementCheckerService.checkAfterBodyProgress(
        context,
        entry.memberId,
        latest.weightKg,
        first.weightKg,
      );
    }

    // Re-apply automatic goals so a corrected entry ripples through.
    await GoalRecalcHook.instance.onMetricSourceSaved(
      memberId: entry.memberId,
      source: MetricSource.bodyProgress,
      context: context,
    );

    notifyListeners();
  }

  // Delete entry
  Future<void> deleteEntry(String entryId, String memberId) async {
    try {
      await _repo.deleteEntry(entryId, memberId);
      _history = _repo.box.values.toList();
      notifyListeners();
    } catch (e) {
      print("❌ Error deleting entry: $e");
      rethrow;
    }
  }

  // Get trend
  String getTrend(String memberId) {
    final history = getHistory(memberId);
    if (history.length < 2) return 'stable';

    final latest = history.first.weightKg;
    final previous = history[1].weightKg;

    if (latest < previous) return 'losing';
    if (latest > previous) return 'gaining';
    return 'stable';
  }

  // Get total change
  double getTotalChange(String memberId) {
    final history = getHistory(memberId);
    if (history.length < 2) return 0.0;

    final first = history.last.weightKg;
    final latest = history.first.weightKg;
    return latest - first;
  }
}