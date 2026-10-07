import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/models/member_model.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';

class QrRevealScreen extends StatelessWidget {
  final MemberModel member;

  const QrRevealScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(title: const Text('Member QR Code')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: GlassContainer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: Text(member.fullName[0].toUpperCase(),
                        style: const TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(height: 16),
                  Text(member.fullName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(member.planName, style: TextStyle(color: context.textSecondary)),
                  const SizedBox(height: 32),

                  // QR Code
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: QrImageView(
                      data: member.qrData ?? 'No QR Data',
                      size: 260,
                      backgroundColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          // Share logic
                          await Share.share('Member QR Code for ${member.fullName}');
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Share QR'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Download as image (RepaintBoundary)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Download coming soon')),
                          );
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Done', style: TextStyle(fontSize: 16)),
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