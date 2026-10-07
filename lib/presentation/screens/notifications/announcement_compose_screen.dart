import 'package:flutter/material.dart';
import 'package:gym_management_app/data/models/notification_model.dart';
import 'package:provider/provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/gradient_button.dart';

class AnnouncementComposeScreen extends StatefulWidget {
  const AnnouncementComposeScreen({super.key});

  @override
  State<AnnouncementComposeScreen> createState() => _AnnouncementComposeScreenState();
}

class _AnnouncementComposeScreenState extends State<AnnouncementComposeScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String targetAudience = 'All Members';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.hasPermission('canSendAnnouncements')) {
      return const Scaffold(body: Center(child: Text('Access Denied')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('New Announcement')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppTextField(
              controller: _titleController,
              label: 'Announcement Title',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _bodyController,
              label: 'Message',
              maxLines: 6,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: targetAudience,
              items: const [
                DropdownMenuItem(value: 'All Members', child: Text('All Members')),
                DropdownMenuItem(value: 'All Staff', child: Text('All Staff')),
                DropdownMenuItem(value: 'Receptionists', child: Text('Receptionists')),
              ],
              onChanged: (v) => setState(() => targetAudience = v!),
              decoration: const InputDecoration(labelText: 'Target Audience'),
            ),
            const SizedBox(height: 32),
            GradientButton(
              label: 'Send Announcement',
              onPressed: () {
                final notificationProvider = context.read<NotificationProvider>();
                notificationProvider.addNotification(
                  NotificationModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    type: 'announcement',
                    title: _titleController.text,
                    body: _bodyController.text,
                    createdAt: DateTime.now(),
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}