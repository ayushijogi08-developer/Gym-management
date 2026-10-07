import 'package:flutter/material.dart';
import '../../widgets/glass_container.dart';

class MembershipStatusCard extends StatelessWidget {
  final String planName;
  final String expiryDate;
  final String status;

  const MembershipStatusCard({
    super.key,
    required this.planName,
    required this.expiryDate,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status.toLowerCase() == 'active';

    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.card_membership, size: 48, color: isActive ? Colors.green : Colors.orange),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(planName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Expires: $expiryDate'),
                ],
              ),
            ),
            Flexible(
              fit: FlexFit.loose,
              child: Chip(
                label: Text(
                  status.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
                backgroundColor: isActive ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                labelStyle: TextStyle(color: isActive ? Colors.green : Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}