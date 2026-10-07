import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isPermissionGranted = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // ✅ Request permission only when scanner is opened
    final status = await Permission.camera.request();

    // The widget may have been disposed while the permission dialog was
    // up. Bail out before calling setState to avoid
    // "setState() called after dispose()" crashes.
    if (!mounted) return;

    if (status.isGranted) {
      setState(() {
        _isPermissionGranted = true;
        _isLoading = false;
      });
    } else if (status.isDenied) {
      setState(() {
        _isPermissionGranted = false;
        _isLoading = false;
        _errorMessage = 'Camera permission is required to scan QR codes.';
      });
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _isPermissionGranted = false;
        _isLoading = false;
        _errorMessage = 'Camera permission is permanently denied. Please enable it in settings.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Requesting camera permission...',
                style: TextStyle(color: context.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isPermissionGranted) {
      return Scaffold(
        backgroundColor: context.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 64,
                  color: context.textMuted,
                ),
                const SizedBox(height: 24),
                Text(
                  'Camera Access Required',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage ?? 'Please grant camera permission to scan QR codes.',
                  style: TextStyle(
                    fontSize: 16,
                    color: context.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _requestCameraPermission,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Grant Permission'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Open app settings
                    openAppSettings();
                  },
                  child: Text(
                    'Open Settings',
                    style: TextStyle(color: context.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ✅ Camera is granted, show the scanner
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () {
              // Toggle flash functionality
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // QR Scanner
          MobileScanner(
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (var barcode in barcodes) {
                final data = barcode.rawValue;
                if (data != null) {
                  _handleScannedData(context, data);
                  break;
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
          
          // Instructions
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'Place QR code inside the frame',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'To scan member QR code for check-in',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleScannedData(BuildContext context, String data) {
    // The onDetect stream can fire after the widget is unmounted (e.g.
    // the user navigated away while the scanner was still processing a
    // frame). Skip any work in that case.
    if (!mounted) return;

    // Handle the scanned data
    debugPrint('Scanned: $data');

    // You can add your QR code handling logic here
    // For example: parse the data, find member, mark attendance
  }
}