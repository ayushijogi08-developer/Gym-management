import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gym_management_app/data/models/payment_model.dart';
import 'package:gym_management_app/themes/app_colors.dart';
import 'package:gym_management_app/themes/app_design_tokens.dart';
import 'glass_container.dart';

class PaymentCard extends StatelessWidget {
  final PaymentModel payment;
  final VoidCallback onTap;

  const PaymentCard({
    super.key,
    required this.payment,
    required this.onTap,
  });

  // Map status to semantic theme colors so the pill reads correctly in
  // both light and dark mode. We avoid raw Colors.green/orange/red because
  // they clash with the light surface tokens.
  static ({Color bg, Color fg}) _statusPalette(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return (
          bg: AppColors.success.withValues(alpha: 0.12),
          fg: AppColors.success,
        );
      case 'pending':
        return (
          bg: AppColors.warning.withValues(alpha: 0.14),
          fg: AppColors.warning,
        );
      case 'refunded':
        return (
          bg: AppColors.danger.withValues(alpha: 0.12),
          fg: AppColors.danger,
        );
      default:
        return (
          bg: context.textMuted.withValues(alpha: 0.14),
          fg: context.textSecondary,
        );
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
    final palette = _statusPalette(context, payment.status);
    final methodIcon = _getMethodIcon(payment.method);

    // Use memberName from payment or fallback to memberId
    final displayName = payment.memberName ??
        'Member ${payment.memberId.substring(0, payment.memberId.length > 8 ? 8 : payment.memberId.length)}';

    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
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
                    context.primary,
                    context.primary.withValues(alpha: 0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : 'M',
                  style: TextStyle(
                    color: context.colors.onPrimary,
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
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          displayName,
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: palette.bg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          payment.status.toUpperCase(),
                          style: TextStyle(
                            color: palette.fg,
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
                      color: context.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        methodIcon,
                        size: 14,
                        color: context.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        payment.method.toUpperCase(),
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: context.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMM yyyy').format(payment.paymentDate),
                        style: TextStyle(
                          color: context.textSecondary,
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                if (payment.gstAmount > 0)
                  Text(
                    'GST ₹${payment.gstAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}