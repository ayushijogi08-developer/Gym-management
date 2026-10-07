import 'package:flutter/widgets.dart';
import 'package:gym_management_app/domain/services/goal_metric_context.dart';
import 'package:gym_management_app/providers/goal_provider.dart';
import 'package:provider/provider.dart';

/// Identifies which kind of source just got persisted. Used for
/// logging and for letting future filters target a single source
/// (e.g. "only run recalc after a workout save").
enum MetricSource { bodyProgress, workout, meal, attendance }

/// Post-save hook that runs the metric-aware goal engine whenever
/// any metric source is persisted. Centralizes the fan-out that
/// was previously inline in each provider, so every save site
/// (including the ones added later) gets goal recalculation for
/// free.
///
/// The hook is intentionally BuildContext-agnostic. When the
/// caller has a mounted widget tree it can pass [BuildContext] so
/// the snapshot can read from in-memory providers (cheaper than
/// going to Hive). When the hook runs from a background sync
/// drain there's no widget tree, so it falls back to the
/// repositories directly via [GoalMetricContext.empty].
class GoalRecalcHook {
  GoalRecalcHook._();

  static final GoalRecalcHook instance = GoalRecalcHook._();

  /// Fired after a metric source has been persisted. Returns the
  /// newly-achieved milestone events so the calling screen can
  /// surface a celebration. Returns an empty list when there is
  /// nothing to celebrate or when no automatic goals match the
  /// member's metric sources.
  ///
  /// Errors are logged and swallowed — the metric engine is a
  /// side-effect of saving the source; a failed recalculation
  /// must not block the user from saving their workout / body
  /// progress / meal log. The next save will retry naturally.
  Future<List<MilestoneEvent>> onMetricSourceSaved({
    required String memberId,
    required MetricSource source,
    BuildContext? context,
  }) async {
    if (memberId.isEmpty) return const [];

    try {
      final ctx = _buildContext(memberId, context);
      final goalProvider = _resolveGoalProvider(context);
      final events = await goalProvider.recalcAutomaticGoals(memberId, ctx);
      if (events.isNotEmpty) {
        goalProvider.queueCelebrations(events);
      }
      return events;
    } catch (e) {
      // Logging only — the save itself already succeeded; failing
      // to recalculate goals must not roll back the user's data.
      // ignore: avoid_print
      print('⚠️ GoalRecalcHook failed for $source on $memberId: $e');
      return const [];
    }
  }

  /// Resolves a [GoalProvider] either from the in-memory provider
  /// tree (when a [BuildContext] is supplied) or via a fresh
  /// instance backed by the goal repository. The latter path is
  /// only safe for read-only recalculation; celebration queueing
  /// is a no-op when there's no UI listening.
  GoalProvider _resolveGoalProvider(BuildContext? context) {
    if (context != null) {
      try {
        return context.read<GoalProvider>();
      } catch (_) {
        // Fall through to a fresh instance if the context isn't
        // mounted above a [MultiProvider] — happens during early
        // boot or in unit tests.
      }
    }
    return GoalProvider();
  }

  /// Builds the metric context. With a widget tree we read the
  /// in-memory providers (which may include fresh writes not yet
  /// flushed to Hive); without one we read directly from the
  /// repos. Both paths produce the same shape — the engine
  /// doesn't care which one built it.
  GoalMetricContext _buildContext(String memberId, BuildContext? context) {
    if (context != null) {
      return GoalMetricContext.fromProviders(context, memberId: memberId);
    }
    return GoalMetricContext.empty(memberId);
  }
}