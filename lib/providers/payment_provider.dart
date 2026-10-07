import 'package:flutter/widgets.dart';
import 'package:gym_management_app/data/models/notification_model.dart';
import 'package:gym_management_app/data/models/payment_model.dart';
import 'package:gym_management_app/data/repositories/subscription_repository.dart';
import 'package:gym_management_app/providers/auth_provider.dart';
import 'package:gym_management_app/providers/notification_provider.dart';
import 'package:gym_management_app/providers/timeline_provider.dart';
import 'package:provider/provider.dart';
import 'package:gym_management_app/data/repositories/payment_repository.dart'; // ✅ IMPORT THIS
import 'package:uuid/uuid.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _repo = PaymentRepository();
  final SubscriptionRepository _subRepo = SubscriptionRepository();
  
  List<PaymentModel> _allPayments = [];
  bool _isLoading = false;

List<PaymentModel> get allPayments {
  print('📊 allPayments getter called, returning ${_allPayments.length} payments');
  return _allPayments;
}
  bool get isLoading => _isLoading;

  List<PaymentModel> get outstandingPayments => 
      _allPayments.where((p) => p.status == 'pending').toList();

  List<PaymentModel> getPaymentsForMember(String memberId) =>
      _allPayments.where((p) => p.memberId == memberId).toList();

  void loadFromLocal() {
    _allPayments = _repo.getAllLocal();
    notifyListeners();
  }

  Future<void> fetchPayments({String? status, String? memberId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _allPayments = await _repo.getAll(status: status, memberId: memberId);
      print('✅ Loaded ${_allPayments.length} payments from API');
    } catch (e) {
      print('❌ Error fetching payments: $e');
      _allPayments = _repo.getAllLocal();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<PaymentModel> getTodayPayments() {
    final today = DateTime.now();
    return _allPayments.where((p) =>
      p.paymentDate.year == today.year &&
      p.paymentDate.month == today.month &&
      p.paymentDate.day == today.day
    ).toList();
  }

  double getTodayTotal() {
    return getTodayPayments().fold(0.0, (sum, p) => sum + p.amount);
  }

  Future<void> recordPayment({
    required String memberId,
    String? subscriptionId,
    required double amount,
    required String method,
    double gstAmount = 0,
    double discountApplied = 0,
    String? notes,
    required String status,
    required AuthProvider auth,
    required BuildContext context,
  }) async {
    final invoiceNo = _repo.generateNextInvoiceNumber();

    final payment = PaymentModel(
      id: const Uuid().v4(),
      memberId: memberId,
      subscriptionId: subscriptionId,
      amount: amount,
      method: method,
      paymentDate: DateTime.now(),
      invoiceNumber: invoiceNo,
      gstAmount: gstAmount,
      discountApplied: discountApplied,
      notes: notes,
      collectedByUserId: auth.currentUser?.id,
      status: status,
    );

    await _repo.addPayment(payment);
    await fetchPayments();

    context.read<TimelineProvider>().logEvent(
      memberId: memberId,
      eventType: 'payment',
      title: 'Payment Made',
      subtitle: '₹$amount via $method',
      iconAsset: 'assets/icons/payment.png',
    );

    context.read<NotificationProvider>().addNotification(
      NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        memberId: memberId,
        type: 'payment_success',
        title: 'Payment Recorded',
        body: '₹$amount paid successfully via $method',
        createdAt: DateTime.now(),
      ),
    );

    if (subscriptionId != null) {
      final sub = await _subRepo.getById(subscriptionId);
      if (sub != null) {
        await _subRepo.update(sub, id: sub.id);
      }
    }

    notifyListeners();
  }

  Future<void> recordRefund(String paymentId, String reason) async {
    final payment = await _repo.getById(paymentId);
    if (payment == null) return;

    payment.status = 'refunded';
    payment.refundReason = reason;
    await _repo.updatePayment(payment);
    await fetchPayments();
    notifyListeners();
  }

  Future<void> markAsPending(String paymentId) async {
    final payment = await _repo.getById(paymentId);
    if (payment == null) return;
    payment.status = 'pending';
    await _repo.updatePayment(payment);
    await fetchPayments();
    notifyListeners();
  }
}