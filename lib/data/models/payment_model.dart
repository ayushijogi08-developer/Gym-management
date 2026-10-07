import 'package:hive/hive.dart';

part 'payment_model.g.dart';

@HiveType(typeId: 6)
class PaymentModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String memberId;

  @HiveField(2)
  String? subscriptionId;

  @HiveField(3)
  double amount;

  @HiveField(4)
  String method; // cash | upi | card | netBanking | wallet

  @HiveField(5)
  DateTime paymentDate;

  @HiveField(6)
  String status; // completed | refunded | pending

  @HiveField(7)
  String invoiceNumber;

  @HiveField(8)
  double gstAmount;

  @HiveField(9)
  double discountApplied;

  @HiveField(10)
  String? notes;

  @HiveField(11)
  String? refundReason;

  @HiveField(12)
  String? collectedByUserId;

 String? memberName;

  PaymentModel({
    required this.id,
    required this.memberId,
    this.subscriptionId,
    required this.amount,
    required this.method,
    required this.paymentDate,
    this.status = 'completed',
    required this.invoiceNumber,
    this.gstAmount = 0,
    this.discountApplied = 0,
    this.notes,
    this.refundReason,
    this.collectedByUserId,
      this.memberName,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'subscriptionId': subscriptionId,
      'amount': amount,
      'method': method,
      'paymentDate': paymentDate.toIso8601String(),
      'status': status,
      'invoiceNumber': invoiceNumber,
      'gstAmount': gstAmount,
      'discountApplied': discountApplied,
      'notes': notes,
      'refundReason': refundReason,
      'collectedByUserId': collectedByUserId,
    };
  }

 factory PaymentModel.fromJson(Map<String, dynamic> json) {
    // ✅ SKIP invalid entries (like the "seq" object in your response)
    if (json.containsKey('seq') && !json.containsKey('_id')) {
      // This is the invalid "seq" entry, skip it
      throw Exception('Invalid payment entry - skipping');
    }

    // Handle memberId
    String memberIdString;
    String? memberNameString;
    
    final memberIdData = json['memberId'];
    if (memberIdData is Map) {
      memberIdString = memberIdData['_id']?.toString() ?? '';
      memberNameString = memberIdData['fullName']?.toString();
    } else if (memberIdData is String) {
      memberIdString = memberIdData;
    } else {
      memberIdString = memberIdData?.toString() ?? '';
    }

    // Handle id
    String idString;
    final idData = json['id'] ?? json['_id'];
    if (idData is Map) {
      idString = idData['_id']?.toString() ?? idData['\$oid']?.toString() ?? '';
    } else {
      idString = idData?.toString() ?? '';
    }

    // ✅ Skip if no memberId or no amount
    if (memberIdString.isEmpty) {
      throw Exception('Invalid payment entry - no memberId');
    }

    return PaymentModel(
      id: idString,
      memberId: memberIdString,
      subscriptionId: json['subscriptionId']?.toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      method: json['method'] ?? 'cash',
      paymentDate: json['paymentDate'] != null 
          ? DateTime.tryParse(json['paymentDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: json['status'] ?? 'completed',
      invoiceNumber: json['invoiceNumber'] ?? 'INV-0000',
      gstAmount: (json['gstAmount'] as num?)?.toDouble() ?? 0.0,
      discountApplied: (json['discountApplied'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes']?.toString(),
      refundReason: json['refundReason']?.toString(),
      collectedByUserId: json['collectedByUserId']?.toString(),
      memberName: memberNameString ?? json['memberName']?.toString(),
    );
  }
}