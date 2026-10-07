import 'package:flutter/material.dart';
import '../../../data/models/search_result_model.dart';
import '../../../themes/app_colors.dart';
import '../../widgets/glass_container.dart';

class SearchResultTile extends StatelessWidget {
  final SearchResultModel result;

  const SearchResultTile({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
          child: Icon(result.icon, color: AppColors.primary),
        ),
        title: Text(
          result.title,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        subtitle: Text(
          result.subtitle ?? '',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            result.category.toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          // Navigation logic handled in GlobalSearchScreen
        },
      ),
    );
  }
}