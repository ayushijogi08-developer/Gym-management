import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_management_app/presentation/widgets/notification_bell_icon.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/member_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/theme_toggle_button.dart';
// Will be scoped later

class TrainerDashboardContent extends StatelessWidget {
  const TrainerDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final memberProvider = context.watch<MemberProvider>();
   final trainer = auth.currentTrainer;
final assignedMembers = memberProvider.members.where((m) => m.assignedTrainerId == trainer?.id).toList();

    return Scaffold(
      // --- ADDED APPBAR HERE ---
      appBar: AppBar(
        title: const Text('Trainer Dashboard'),
        actions:  [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/global-search'),
          ),
          NotificationBellIcon(), // <--- ADDED ACTION HERE
          ThemeToggleButton(),
          SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${trainer?.fullName.split(' ').first ?? "Trainer"}',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: context.textPrimary),
            ),
            Text('Your Assigned Members', style: TextStyle(color: context.textSecondary)),
            const SizedBox(height: 28),

            StatCard(
              label: "Assigned Members",
              value: assignedMembers.length.toString(),
              icon: Icons.people,
              iconColor: AppColors.primary,
            ),

            const SizedBox(height: 24),

            // REPLACE your current GlassContainer block (lines 35-59) with this:

GlassContainer(
  child: Material( // ADDED THIS
                color: Colors.transparent,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    
    children: [
      ListTile(
        title: const Text('My Assigned Members'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/members'),
      ),
      ListTile(
        title: const Text('Today\'s Schedule'),
        subtitle: Text('${trainer?.shiftStart} - ${trainer?.shiftEnd}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule view - Coming soon')),
        ),
      ),
      // Use ListTile directly instead of nesting a new GlassContainer
      ListTile(
        title: const Text('Diet Plans'),
        leading: const Icon(Icons.restaurant, color: AppColors.primary),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/diet-plans'), // Correct GoRouter navigation
      ),
      ListTile(
        title: const Text('Meal Reminders'),
        leading: const Icon(Icons.notifications, color: AppColors.accent),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/all-reminders'),
      ),
    ],
  ),
),
),
            const SizedBox(height: 16),

          LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth >= 1100 ? 4 : (constraints.maxWidth >= 700 ? 3 : 2);
                  final ratio = constraints.maxWidth >= 700 ? 1.3 : 1.05;

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: ratio,
                    children: [
                      _buildShortcutCard(
                        context,
                        icon: Icons.fitness_center,
                        color: Colors.blue,
                        title: 'Workout Plans',
                        subtitle: 'Manage training plans',
                        route: '/workout-plans',
                      ),
                      _buildShortcutCard(
                        context,
                        icon: Icons.flag,
                        color: Colors.purple,
                        title: 'Member Goals',
                        subtitle: "View members' goals",
                        route: '/all-member-goals',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ADDED: Helper Method ---
  Widget _buildShortcutCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return GlassContainer(
      onTap: () => context.push(route),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Fix: Prevents internal column overflow
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: context.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}