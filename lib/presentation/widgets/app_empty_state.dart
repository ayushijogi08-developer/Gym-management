import 'package:flutter/material.dart';
import '../../../themes/app_colors.dart';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? actionButton;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: AppColors.textSecondary.withValues(alpha: 0.6)),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (actionButton != null) ...[
            const SizedBox(height: 32),
            actionButton!,
          ],
        ],
      ),
    );
  }
}