import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gym_management_app/domain/entities/user_role.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../../providers/attendance_provider.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isScanning = true;
  String? _scannedData;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    
    // Check if user has permission to scan
    final canScan = auth.currentRole == UserRole.admin || 
                    auth.currentRole == UserRole.receptionist ||
                    auth.currentRole == UserRole.superAdmin;

    if (!canScan) {
      return Scaffold(
        backgroundColor: context.background,
        appBar: AppBar(
          title: const Text('QR Scanner'),
          backgroundColor: context.background,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: AppColors.danger),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, color: context.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Only admins and receptionists can scan QR codes',
                style: TextStyle(color: context.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // QR Scanner
          MobileScanner(
            onDetect: (capture) {
              if (_isScanning && !_isProcessing) {
                final List<Barcode> barcodes = capture.barcodes;
                for (var barcode in barcodes) {
                  final data = barcode.rawValue;
                  if (data != null) {
                    _handleScannedData(context, data);
                    break;
                  }
                }
              }
            },
          ),
          
          // Scanning Frame
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          // Overlay with instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: GlassContainer(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    size: 40,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Scan the QR code at the gym entrance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (_isProcessing)
                    const CircularProgressIndicator()
                  else if (_scannedData != null)
                    Text(
                      '✅ Scanned: ${_scannedData!.substring(0, 20)}...',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleScannedData(BuildContext context, String data) async {
    if (_isProcessing) return;
    
    setState(() {
      _isScanning = false;
      _isProcessing = true;
      _scannedData = data;
    });

    try {
      // Parse QR data
      final qrData = jsonDecode(data);
      final memberId = qrData['memberId'];
      final memberName = qrData['name'] ?? 'Member';

      if (memberId == null || memberId.isEmpty) {
        _showError('Invalid QR code: Member ID not found');
        return;
      }

      // Check if member exists
      final memberProvider = context.read<MemberProvider>();
      // Load members if not loaded
      await memberProvider.loadMembers();
      
      final exists = memberProvider.members.any((m) => m.id == memberId);
      
      if (!exists) {
        _showError('Member not found in the system');
        return;
      }

      // Mark attendance
      final attendanceProvider = context.read<AttendanceProvider>();
      await attendanceProvider.checkIn(
        memberId: memberId,
        memberName: memberName,
        gateId: 'Main Gate',
        entryType: 'checkIn',
        context: context,
      );

      // Show success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('✅ Attendance marked successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
          ),
        );
      }

      // Reset scanner after delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isScanning = true;
            _isProcessing = false;
            _scannedData = null;
          });
        }
      });

    } catch (e) {
      _showError('Error: ${e.toString()}');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.danger,
        duration: const Duration(seconds: 3),
      ),
    );

    // Reset scanner after error
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isScanning = true;
          _isProcessing = false;
          _scannedData = null;
        });
      }
    });
  }
}