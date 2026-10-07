import 'package:flutter/material.dart';
import '../../../themes/app_colors.dart';
import 'gradient_button.dart';

class AppErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 72, color: AppColors.danger),
          const SizedBox(height: 24),
          Text(
            'Something went wrong',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 32),
            GradientButton(
              label: 'Try Again',
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }
}