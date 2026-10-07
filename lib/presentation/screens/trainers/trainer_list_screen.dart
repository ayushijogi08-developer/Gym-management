import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/trainer_provider.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/trainer_card.dart';
import 'add_edit_trainer_screen.dart';
import '../../../providers/auth_provider.dart';
import 'trainer_profile_screen.dart';
import 'package:gym_management_app/utils/route_helper.dart';

class TrainerListScreen extends StatefulWidget { // Changed from StatelessWidget
  const TrainerListScreen({super.key});

  @override
  State<TrainerListScreen> createState() => _TrainerListScreenState();
}

class _TrainerListScreenState extends State<TrainerListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch fresh data when the screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrainerProvider>().refreshTrainers();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;
            final crossAxisCount = constraints.maxWidth >= 1100 ? 3 : (constraints.maxWidth >= 700 ? 2 : 1);

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trainers',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: context.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: context.read<TrainerProvider>().search,
                    style: TextStyle(color: context.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search trainers...',
                      hintStyle: TextStyle(color: context.textMuted),
                      prefixIcon: Icon(Icons.search, color: context.textSecondary),
                      filled: true,
                      fillColor: context.surfaceAlt,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: context.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: context.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            BorderSide(color: context.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Consumer<TrainerProvider>(
                      builder: (context, provider, _) {
                        final trainers = provider.trainers;
                        if (trainers.isEmpty) {
                          return Center(child: Text("No trainers found", style: TextStyle(color: context.textSecondary)));
                        }
                        if (crossAxisCount == 1) {
        return ListView.separated(
          itemCount: trainers.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final trainer = trainers[index];
            return TrainerCard(
              trainer: trainer,
              onTap: () => Navigator.push(
                context,
                buildAppRoute(TrainerProfileScreen(trainer: trainer)),
              ),
            );
          },
        );
      }

                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: isWide ? 1.6 : 1.2,
                          ),
                          itemCount: trainers.length,
                          itemBuilder: (context, index) {
                            final trainer = trainers[index];
                            return TrainerCard(
                              trainer: trainer,
                              onTap: () => Navigator.push(
                                context,
                                buildAppRoute( TrainerProfileScreen(trainer: trainer)),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
     floatingActionButton: Consumer<AuthProvider>(
  builder: (context, auth, _) {
    if (!auth.hasPermission('canManageTrainers')) {
      return const SizedBox.shrink();
    }
    return FloatingActionButton.extended(
      backgroundColor: context.primary,
      icon: const Icon(Icons.person_add),
      label: const Text('Add Trainer'),
      onPressed: () => Navigator.push(
        context,
        buildAppRoute(const AddEditTrainerScreen()),
      ).then((_) => context.read<TrainerProvider>().loadTrainers()),
    );
  },
), 
    );
  }
}