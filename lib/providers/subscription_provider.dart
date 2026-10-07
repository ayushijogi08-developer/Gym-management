import 'package:gym_management_app/data/models/notification_model.dart';
import 'package:gym_management_app/providers/notification_provider.dart';
import 'package:gym_management_app/providers/timeline_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../data/models/subscription_model.dart';
import '../data/models/plan_model.dart';
import '../data/repositories/subscription_repository.dart';
import '../data/repositories/member_repository.dart';
import '../data/repositories/plan_repository.dart';
import 'package:flutter/material.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionRepository _repo = SubscriptionRepository();
  final MemberRepository _memberRepo = MemberRepository();
  final PlanRepository _planRepo = PlanRepository();
  
  List<SubscriptionModel> getAll() => _repo.getAllLocal();

  SubscriptionModel? getActiveForMember(String memberId) {
    final subs = _repo.getByMemberLocal(memberId);
    return subs.where((s) => s.status == 'active' || s.status == 'paused').firstOrNull;
  }

  PlanModel? _getPlanById(String planId) {
    return _planRepo.getAllPlansLocal().where((p) => p.id == planId).firstOrNull;
  }

  // ✅ ADD THIS METHOD - Create Subscription
  Future<void> createSubscription({
    required String memberId,
    required String planId,
    required DateTime startDate,
    required DateTime endDate,
    required String status,
    required BuildContext context,
  }) async {
    try {
      final plan = _getPlanById(planId);
      
      final subscription = SubscriptionModel(
        id: const Uuid().v4(),
        memberId: memberId,
        planId: planId,
        startDate: startDate,
        endDate: endDate,
        status: status,
      );

      await _repo.addSubscription(subscription);
      await _syncMemberSummary(memberId, plan?.planName ?? 'Active Plan');

      context.read<TimelineProvider>().logEvent(
        memberId: memberId,
        eventType: 'subscription_created',
        title: 'Subscription Created',
        subtitle: '${plan?.planName ?? 'Plan'} • Active',
        iconAsset: 'assets/icons/subscription.png',
      );

      context.read<NotificationProvider>().addNotification(
        NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          memberId: memberId,
          type: 'subscription',
          title: 'Subscription Created',
          body: 'Your ${plan?.planName ?? 'Plan'} subscription has been activated.',
          createdAt: DateTime.now(),
        ),
      );

      notifyListeners();
      print('✅ Subscription created successfully for member: $memberId');
    } catch (e) {
      print('❌ Error creating subscription: $e');
      rethrow;
    }
  }

  Future<void> purchaseSubscription(String memberId, String planId, PlanModel plan, BuildContext context) async {
    final now = DateTime.now();
    final sub = SubscriptionModel(
      id: const Uuid().v4(),
      memberId: memberId,
      planId: planId,
      startDate: now,
      endDate: now.add(Duration(days: plan.durationInDays)),
      status: 'active',
    );

    await _repo.addSubscription(sub);
    await _syncMemberSummary(memberId, plan.planName);

    context.read<TimelineProvider>().logEvent(
      memberId: memberId,
      eventType: 'purchased',
      title: 'Membership Purchased',
      subtitle: '${plan.planName} • ₹${plan.price}',
      iconAsset: 'assets/icons/renewed.png',
    );
    context.read<NotificationProvider>().addNotification(
      NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        memberId: memberId,
        type: 'subscription',
        title: 'Membership Purchased',
        body: 'Welcome! Your ${plan.planName} subscription is now active.',
        createdAt: DateTime.now(),
      ),
    );
    
    notifyListeners();
  }

  Future<void> renewSubscription(String memberId, PlanModel plan, BuildContext context) async {
    final active = getActiveForMember(memberId);
    final now = DateTime.now();

    final newSub = SubscriptionModel(
      id: const Uuid().v4(),
      memberId: memberId,
      planId: active?.planId ?? plan.id,
      startDate: active != null && active.endDate.isAfter(now) ? active.endDate : now,
      endDate: (active != null && active.endDate.isAfter(now) ? active.endDate : now).add(Duration(days: plan.durationInDays)),
      status: 'active',
      previousSubscriptionId: active?.id,
    );

    if (active != null) {
      active.status = 'expired';
      await _repo.updateSubscription(active);
    }
    await _repo.addSubscription(newSub);
    await _syncMemberSummary(memberId, plan.planName);

    context.read<TimelineProvider>().logEvent(
      memberId: memberId,
      eventType: 'renewed',
      title: 'Membership Renewed',
      subtitle: '${plan.planName} • ₹${plan.price}',
      iconAsset: 'assets/icons/renewed.png',
    );
    context.read<NotificationProvider>().addNotification(
      NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        memberId: memberId,
        type: 'subscription',
        title: 'Membership Renewed',
        body: 'Your subscription has been renewed successfully!',
        createdAt: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  Future<void> upgradeSubscription(String memberId, String newPlanId, PlanModel newPlan, BuildContext context) async {
    final active = getActiveForMember(memberId);
    final now = DateTime.now();

    if (active != null) {
      active.status = 'cancelled';
      await _repo.updateSubscription(active);
    }

    final newSub = SubscriptionModel(
      id: const Uuid().v4(),
      memberId: memberId,
      planId: newPlanId,
      startDate: now,
      endDate: now.add(Duration(days: newPlan.durationInDays)),
      status: 'active',
      previousSubscriptionId: active?.id,
    );

    await _repo.addSubscription(newSub);
    await _syncMemberSummary(memberId, newPlan.planName);

    context.read<TimelineProvider>().logEvent(
      memberId: memberId,
      eventType: 'upgraded',
      title: 'Membership Upgraded',
      subtitle: '${newPlan.planName} • ₹${newPlan.price}',
      iconAsset: 'assets/icons/renewed.png',
    );
    context.read<NotificationProvider>().addNotification(
      NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        memberId: memberId,
        type: 'subscription',
        title: 'Membership Upgraded',
        body: 'You have successfully upgraded to the ${newPlan.planName} plan!',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  Future<void> pauseSubscription(String memberId) async {
    final active = getActiveForMember(memberId);
    if (active == null || active.status != 'active') return;

    final plan = _getPlanById(active.planId);
    active.status = 'paused';
    active.pausedOn = DateTime.now();
    await _repo.updateSubscription(active);
    await _syncMemberSummary(memberId, plan?.planName ?? 'Unknown');
    notifyListeners();
  }

  Future<void> resumeSubscription(String memberId) async {
    final active = getActiveForMember(memberId);
    if (active == null || active.status != 'paused' || active.pausedOn == null) return;

    final plan = _getPlanById(active.planId);
    final pausedDuration = DateTime.now().difference(active.pausedOn!);
    active.endDate = active.endDate.add(pausedDuration);
    active.status = 'active';
    active.resumedOn = DateTime.now();
    await _repo.updateSubscription(active);
    await _syncMemberSummary(memberId, plan?.planName ?? 'Unknown');
    notifyListeners();
  }

  Future<void> cancelSubscription(String memberId) async {
    final active = getActiveForMember(memberId);
    if (active == null) return;
    final plan = _getPlanById(active.planId);
    active.status = 'cancelled';
    await _repo.updateSubscription(active);
    await _syncMemberSummary(memberId, plan?.planName ?? 'Cancelled');
    notifyListeners();
  }

  Future<void> _syncMemberSummary(String memberId, String planName) async {
    final active = getActiveForMember(memberId);
    final member = await _memberRepo.getMemberById(memberId);
    if (member != null && active != null) {
      member.planName = planName;
      member.expiryDate = active.endDate;
      await _memberRepo.updateMember(member);
    }
  }
}