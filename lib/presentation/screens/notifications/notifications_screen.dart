import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_management_app/providers/auth_provider.dart';
import 'package:gym_management_app/themes/app_colors.dart';
import 'package:gym_management_app/themes/app_design_tokens.dart';
import 'package:provider/provider.dart';
import '../../../providers/notification_provider.dart';
import '../../widgets/notification_tile.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
Widget build(BuildContext context) {
  final provider = context.watch<NotificationProvider>();
  
  // 1. Get the auth provider to retrieve the current user's ID
  final auth = context.watch<AuthProvider>();
  final memberId = auth.currentUser?.linkedMemberId;

  // 2. Pass the String? memberId instead of BuildContext
  final notifications = provider.getNotificationsForCurrentUser(memberId);

  return Scaffold(
    appBar: AppBar(
      title: const Text('Notifications'),
      actions: [
        TextButton(
          // 3. Update markAllRead to also use memberId if required by your provider
          onPressed: () => provider.markAllRead(), 
          child: const Text('Mark All Read'),
        ),
      ],
    ),
      body: Column(
        children: [
          // Header: Notification Preferences Link
          ListTile(
            leading: const Icon(Icons.settings, color: AppColors.primary),
            title: const Text('Notification Preferences'),
            subtitle: const Text('Manage what alerts you receive'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/notification-settings'),
          ),
          const Divider(height: 1),

          // Body: The List of Notifications
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Text(
                      'No notifications yet',
                      style: TextStyle(color: context.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return NotificationTile(
                        notification: notifications[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}