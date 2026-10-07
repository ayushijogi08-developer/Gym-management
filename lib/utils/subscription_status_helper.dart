import 'package:flutter/material.dart';

import '../../data/models/subscription_model.dart';

class SubscriptionStatusHelper {
  static String computeStatus(SubscriptionModel? sub) {
    if (sub == null) return 'no_plan';

    if (sub.status == 'paused') return 'paused';
    if (sub.status == 'cancelled') return 'cancelled';

    final now = DateTime.now();
    if (now.isAfter(sub.endDate)) {
      final daysPast = now.difference(sub.endDate).inDays;
      if (daysPast <= sub.gracePeriodDays) return 'grace_period';
      return 'expired';
    }

    final daysToExpiry = sub.endDate.difference(now).inDays;
    if (daysToExpiry <= 7) return 'expiring_soon';
    return 'active';
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'expiring_soon':
        return Colors.orange;
      case 'grace_period':
        return Colors.amber;
      case 'expired':
      case 'cancelled':
        return Colors.red;
      case 'paused':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}