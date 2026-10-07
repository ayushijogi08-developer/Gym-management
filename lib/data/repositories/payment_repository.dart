import 'package:gym_management_app/data/local/hive_boxes.dart';
import 'package:gym_management_app/data/network/api_client.dart';
import 'package:gym_management_app/data/network/api_endpoints.dart';
import '../models/payment_model.dart';
import 'base_repository.dart';

class PaymentRepository extends BaseRepository<PaymentModel> {
  PaymentRepository() : super(HiveBoxes.payments, ApiEndpoints.payments);

  List<PaymentModel> getAllLocal() => box.values.toList();

  List<PaymentModel> getByMemberLocal(String memberId) =>
      box.values.where((p) => p.memberId == memberId).toList();

  List<PaymentModel> getOutstandingLocal() =>
      box.values.where((p) => p.status == 'pending').toList();

  String generateNextInvoiceNumber() {
    final all = box.values.toList();
    if (all.isEmpty) return 'INV-2026-0001';
    final numbers = all.map((p) => int.tryParse(p.invoiceNumber.split('-').last) ?? 0).toList();
    final next = (numbers.reduce((a, b) => a > b ? a : b) + 1).toString().padLeft(4, '0');
    return 'INV-2026-$next';
  }
  
  Future<List<PaymentModel>> getAll({String? status, String? memberId}) async {
    try {
      final Map<String, dynamic> params = {};
      if (status != null) params['status'] = status;
      if (memberId != null) params['memberId'] = memberId;

      final response = await ApiClient.get(endpoint, params: params);
      final List<dynamic> data = response.data['data'] ?? [];
      
      print('📊 Raw payment data from API: ${data.length} entries');
      
      final payments = <PaymentModel>[];
      for (var json in data) {
        try {
          final payment = PaymentModel.fromJson(json);
          payments.add(payment);
        } catch (e) {
          // Skip invalid entries (like the "seq" object)
          print('⚠️ Skipping invalid payment entry: $e');
        }
      }
      
      // Save to local
      for (var p in payments) {
        await box.put(p.id, p);
      }
      
      print('✅ Saved ${payments.length} valid payments to local');
      return payments;
    } catch (e) {
      print('Error fetching payments, returning cached: $e');
      return box.values.toList();
    }
  }

  Future<PaymentModel?> getById(String id) async {
    try {
      final response = await ApiClient.get('$endpoint/$id');
      final p = PaymentModel.fromJson(response.data['data']);
      await box.put(p.id, p);
      return p;
    } catch (e) {
      return box.get(id);
    }
  }

  Future<void> addPayment(PaymentModel payment) async {
    await add(payment, id: payment.id);
  }

  Future<void> updatePayment(PaymentModel payment) async {
    await update(payment, id: payment.id);
  }

  Future<void> deletePayment(String id) async {
    await delete(id);
  }
}