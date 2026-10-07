import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/auth_provider.dart'; // Add this import
import 'package:go_router/go_router.dart';

class NotificationBellIcon extends StatelessWidget {
  const NotificationBellIcon({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get the auth provider to retrieve the ID
    final auth = context.watch<AuthProvider>();
    final memberId = auth.currentUser?.linkedMemberId;

    // 2. Pass the memberId (String) instead of context
    final unread = context.watch<NotificationProvider>().getUnreadCount();

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => context.push('/notifications'),
        ),
        if (unread > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                unread > 9 ? '9+' : unread.toString(),
                style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}