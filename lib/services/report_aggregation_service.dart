import 'package:flutter/material.dart';
import '../data/models/payment_model.dart';

class RevenueReportData {
  final double totalRevenue;
  final double totalRefunds;
  final int transactionCount;
  final Map<String, double> methodBreakdown;

  RevenueReportData({
    required this.totalRevenue,
    required this.totalRefunds,
    required this.transactionCount,
    required this.methodBreakdown,
  });
}

class ReportAggregationService {
  static RevenueReportData revenueSummary(List<PaymentModel> payments, DateTimeRange range) {
    final filtered = payments.where((p) =>
        p.paymentDate.isAfter(range.start) && p.paymentDate.isBefore(range.end)).toList();

    double total = 0;
    double refunds = 0;
    final methodBreakdown = <String, double>{};

    for (var p in filtered) {
      if (p.status == 'refunded') {
        refunds += p.amount;
      } else {
        total += p.amount;
        methodBreakdown[p.method] = (methodBreakdown[p.method] ?? 0) + p.amount;
      }
    }

    return RevenueReportData(
      totalRevenue: total,
      totalRefunds: refunds,
      transactionCount: filtered.length,
      methodBreakdown: methodBreakdown,
    );
  }

  }