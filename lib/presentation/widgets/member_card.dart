import 'package:flutter/material.dart';
import '../../data/models/member_model.dart';
import '../../themes/app_colors.dart';
import 'glass_container.dart';

/// Card showing a single member's summary — used in list and grid layouts.
class MemberCard extends StatelessWidget {
  final MemberModel member;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool canDelete;

  const MemberCard({super.key, required this.member, this.onTap,this.onDelete,this.canDelete = false,});

  Color get _statusColor {
    switch (member.membershipStatus) {
      case 'active':
        return AppColors.success;
      case 'expiringSoon':
        return AppColors.accent;
      case 'expired':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  String get _statusLabel {
    switch (member.membershipStatus) {
      case 'active':
        return 'Active';
      case 'expiringSoon':
        return 'Expiring Soon';
      case 'expired':
        return 'Expired';
      default:
        return member.membershipStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Text(
                member.fullName.isNotEmpty
                    ? member.fullName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    member.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    member.planName,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              fit: FlexFit.loose,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            ),
            if (canDelete) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                onPressed: () {
                  // Implement your delete logic here or via callback
                  onDelete?.call();
                },
                tooltip: 'Delete Member',
              ),
            ],
          ],
        ),
      ),
    );
  }
}