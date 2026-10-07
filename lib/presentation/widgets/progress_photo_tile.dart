import 'package:flutter/material.dart';
import 'package:gym_management_app/presentation/widgets/glass_container.dart';
import 'dart:io';
import '../../../themes/app_colors.dart';


class ProgressPhotoTile extends StatelessWidget {
  final String? imagePath;
  final String label; // "Front", "Side", "Back"
  final String date;
  final VoidCallback? onTap;

  const ProgressPhotoTile({
    super.key,
    this.imagePath,
    required this.label,
    required this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Container
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: imagePath != null
                    ? DecorationImage(
                        image: FileImage(File(imagePath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imagePath == null
                  ? const Center(
                      child: Icon(Icons.add_a_photo, size: 40, color: Colors.white54),
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}