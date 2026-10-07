import 'dart:convert';

import '../data/local/sync_queue_repository.dart';
import '../data/network/api_client.dart';
import '../utils/connectivity_helper.dart';
import 'goal_recompute_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SyncService {
  final SyncQueueRepository _repo = SyncQueueRepository();
  final GoalRecomputeService _goalRecompute = GoalRecomputeService.instance;

  /// Endpoints whose payloads carry a `memberId` we're interested in
  /// for goal recalculation. When a queued item targets one of these
  /// endpoints, the sync drain collects the memberId and runs the
  /// metric-aware goal engine once at the end of the drain.
  ///
  /// Phase 3: this is now broader than body-progress — workout logs,
  /// attendance, and meal logs all participate in the automatic goal
  /// engine and need to be reflected on replay.
  static const _memberSources = {
    '/api/body-progress',
    '/api/workout-logs',
    '/api/attendance',
    '/api/meal-logs',
  };

  Future<void> startSync() async {
    final isOnline = await ConnectivityHelper.isConnected();
    if (!isOnline) return;

    final pending = _repo.getPending();
    // Track members whose metric-source entries were replayed so we can
    // re-run the metric-aware engine on their goals once. The set is
    // deduplicated to avoid redundant work when a member has multiple
    // queued entries.
    final affectedMembers = <String>{};

    for (var item in pending) {
      try {
        final data = item.payload.isEmpty ? null : item.payload;

        // FIX: Use named parameter 'data' for all API calls
        if (item.method == 'POST') {
          await ApiClient.post(
            item.endpoint,
            data: data,  // Changed to named parameter
          );
        } else if (item.method == 'PUT') {
          await ApiClient.put(
            item.endpoint,
            data: data,  // Changed to named parameter
          );
        } else if (item.method == 'DELETE') {
          await ApiClient.delete(item.endpoint);
        }

        await _repo.markSynced(item.id);

        // ── Metric-aware recompute ──
        // When a metric-source entry is replayed, fan out to that
        // member's active automatic goals so they pick up the new
        // value. Errors here are non-fatal — the sync drain already
        // succeeded for this row.
        final memberSource = _memberSources.firstWhere(
          (e) => item.endpoint.contains(e),
          orElse: () => '',
        );
        if (memberSource.isNotEmpty && data != null) {
          try {
            final payload = jsonDecode(data);
            if (payload is Map && payload['memberId'] is String) {
              affectedMembers.add(payload['memberId'] as String);
            }
          } catch (_) {
            // ignore parse errors — sync already succeeded
          }
        }
      } catch (e) {
        print('Sync failed for ${item.id}: $e');
        // Keep in queue for retry
      }
    }

    for (final memberId in affectedMembers) {
      try {
        await _goalRecompute.runForMember(memberId);
      } catch (e) {
        print('⚠️ Goal recompute failed for $memberId: $e');
      }
    }
  }

  // Call this when app comes online
  void init() {
    ConnectivityHelper.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        startSync();
      }
    });
  }
}