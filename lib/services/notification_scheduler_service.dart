import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../providers/subscription_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/member_provider.dart';
import '../data/models/notification_model.dart';
import 'package:uuid/uuid.dart';

class NotificationSchedulerService {
  static Future<void> runDailyChecks(BuildContext context) async {
    final notificationProvider = context.read<NotificationProvider>();
    final subscriptionProvider = context.read<SubscriptionProvider>();
    final paymentProvider = context.read<PaymentProvider>();
    final memberProvider = context.read<MemberProvider>();

    // Expiry Alerts
    for (var sub in subscriptionProvider.getAll()) {
      final daysLeft = sub.endDate.difference(DateTime.now()).inDays;
      if (daysLeft <= 7 && daysLeft > 0) {
        notificationProvider.addNotification(
          NotificationModel(
            id: const Uuid().v4(),
            memberId: sub.memberId,
            type: 'expiry',
            title: 'Membership Expiring Soon',
            body: 'Your plan expires in $daysLeft days. Renew now!',
            createdAt: DateTime.now(),
          ),
        );
      }
    }

    // Payment Due Alerts
    for (var payment in paymentProvider.outstandingPayments) {
      notificationProvider.addNotification(
        NotificationModel(
          id: const Uuid().v4(),
          memberId: payment.memberId,
          type: 'payment_due',
          title: 'Payment Pending',
          body: '₹${payment.amount} is due. Please complete your payment.',
          createdAt: DateTime.now(),
        ),
      );
    }

    // Birthday Alerts
    final today = DateTime.now();
    for (var member in memberProvider.members) {
      if (member.dob != null &&
          member.dob!.month == today.month &&
          member.dob!.day == today.day) {
        notificationProvider.addNotification(
          NotificationModel(
            id: const Uuid().v4(),
            memberId: member.id,
            type: 'birthday',
            title: 'Happy Birthday!',
            body: 'Wishing you a fantastic year ahead 🎉',
            createdAt: DateTime.now(),
          ),
        );
      }
    }
  }
}