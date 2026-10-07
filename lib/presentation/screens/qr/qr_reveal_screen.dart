import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gym_management_app/data/models/member_model.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/member_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';

class QRRevealScreen extends StatelessWidget {
  const QRRevealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final memberProvider = context.watch<MemberProvider>();

    final memberId = auth.currentUser?.linkedMemberId ?? '';
    final member = memberProvider.members.firstWhere(
      (m) => m.id == memberId,
      orElse: () => MemberModel(
        id: '',
        fullName: 'Member',
        gender: '',
        phone: '',
        email: '',
        membershipStatus: 'inactive',
        planName: 'No Plan',
        joiningDate: DateTime.now(),
        expiryDate: DateTime.now(),
      ),
    );

    // Generate QR data (member ID + name)
    final qrData = jsonEncode({
      'memberId': member.id,
      'name': member.fullName,
      'phone': member.phone,
      'email': member.email,
      'timestamp': DateTime.now().toIso8601String(),
    });

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        title: const Text('My QR Code'),
        backgroundColor: context.background,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Member Info
              GlassContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: Text(
                        member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : 'M',
                        style: TextStyle(fontSize: 36, color: context.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      member.fullName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    Text(
                      member.planName,
                      style: TextStyle(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // QR Code
              GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 250,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Show this QR code at the gym entrance',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Staff will scan to mark your attendance',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Member Details
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(context, 'Member ID', member.id),
                    _buildDetailRow(context, 'Name', member.fullName),
                    _buildDetailRow(context, 'Phone', member.phone),
                    _buildDetailRow(context, 'Email', member.email),
                    _buildDetailRow(context, 'Plan', member.planName),
                    _buildDetailRow(
                      context,
                      'Status',
                      member.membershipStatus,
                      color: member.membershipStatus.toLowerCase() == 'active'
                          ? AppColors.success
                          : AppColors.danger,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color ?? context.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}