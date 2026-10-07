import 'package:flutter/material.dart';
import 'package:gym_management_app/presentation/widgets/glass_container.dart';
import 'package:gym_management_app/providers/notification_provider.dart';
import 'package:provider/provider.dart';
import '../../../data/models/notification_model.dart';


class NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const NotificationTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: ListTile(
        leading: Icon(
          _getIconForType(notification.type),
          color: _getColorForType(notification.type),
        ),
        title: Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(notification.body),
        trailing: Text(
          notification.createdAt.toString().split(' ')[0],
          style: const TextStyle(fontSize: 12, color: Colors.white54),
        ),
        onTap: () {
          // Mark as read
          context.read<NotificationProvider>().markAsRead(notification.id);
          // TODO: Deep link based on type
        },
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'expiry':
        return Icons.warning;
      case 'payment_due':
        return Icons.payment;
      case 'birthday':
        return Icons.cake;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'expiry':
        return Colors.orange;
      case 'payment_due':
        return Colors.red;
      case 'birthday':
        return Colors.pink;
      default:
        return Colors.blue;
    }
  }
}