import 'package:flutter/material.dart';
import 'skeleton_card.dart';

class SkeletonStatGrid extends StatelessWidget {
  const SkeletonStatGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.4,
      children: List.generate(6, (index) => const SkeletonCard(height: 110)),
    );
  }
}