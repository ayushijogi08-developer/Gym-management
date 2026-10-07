import 'package:flutter/material.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool expiryAlerts = true;
  bool paymentReminders = true;
  bool birthdayWishes = true;
  bool offers = true;
  bool announcements = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(title: const Text('Notification Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassContainer(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Membership Expiry Alerts'),
                  subtitle: const Text('When your plan is about to expire'),
                  value: expiryAlerts,
                  onChanged: (v) => setState(() => expiryAlerts = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Payment Reminders'),
                  subtitle: const Text('Pending or due payments'),
                  value: paymentReminders,
                  onChanged: (v) => setState(() => paymentReminders = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Birthday Wishes'),
                  subtitle: const Text('Special greetings on your birthday'),
                  value: birthdayWishes,
                  onChanged: (v) => setState(() => birthdayWishes = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Offers & Promotions'),
                  subtitle: const Text('Gym offers and discounts'),
                  value: offers,
                  onChanged: (v) => setState(() => offers = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Announcements'),
                  subtitle: const Text('Important gym updates'),
                  value: announcements,
                  onChanged: (v) => setState(() => announcements = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'You can always change these preferences later from Settings.',
            style: TextStyle(color: context.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}