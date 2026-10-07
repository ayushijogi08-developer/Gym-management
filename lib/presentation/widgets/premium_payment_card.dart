import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gym_management_app/data/models/payment_model.dart';
import 'package:gym_management_app/themes/app_colors.dart';

class PremiumPaymentCard extends StatelessWidget {
  final PaymentModel payment;
  final VoidCallback onTap;
  final VoidCallback? onMoreTap;

  const PremiumPaymentCard({
    super.key,
    required this.payment,
    required this.onTap,
    this.onMoreTap,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'refunded':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }

  IconData _getMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'card':
        return Icons.credit_card;
      case 'upi':
        return Icons.qr_code_scanner;
      case 'netbanking':
        return Icons.account_balance;
      case 'wallet':
        return Icons.wallet;
      default:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(payment.status);
    final methodIcon = _getMethodIcon(payment.method);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.card,
              AppColors.card.withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        payment.memberId.isNotEmpty
                            ? payment.memberId.substring(0, 1).toUpperCase()
                            : 'M',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Member #${payment.memberId.substring(0, payment.memberId.length > 8 ? 8 : payment.memberId.length)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getStatusLabel(payment.status),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          payment.invoiceNumber,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              methodIcon,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              payment.method.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd MMM yyyy').format(payment.paymentDate),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.3),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${payment.amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (payment.gstAmount > 0)
                        Text(
                          '+ GST ₹${payment.gstAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                  
                  // More Menu
                  if (onMoreTap != null)
                    IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.white.withValues(alpha: 0.3),
                        size: 20,
                      ),
                      onPressed: onMoreTap,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}