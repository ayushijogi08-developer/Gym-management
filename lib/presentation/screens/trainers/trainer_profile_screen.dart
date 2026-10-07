import 'package:flutter/material.dart';
import 'package:gym_management_app/domain/entities/user_role.dart';
import 'package:gym_management_app/providers/auth_provider.dart';
import 'package:gym_management_app/providers/trainer_provider.dart';
import 'package:provider/provider.dart';
import '../../../data/models/trainer_model.dart';
import '../../../providers/member_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/member_card.dart';
import 'add_edit_trainer_screen.dart';
import 'package:gym_management_app/utils/route_helper.dart';

class TrainerProfileScreen extends StatelessWidget {
  final TrainerModel trainer;

  const TrainerProfileScreen({super.key, required this.trainer});

  @override
  Widget build(BuildContext context) {
    final memberProvider = context.watch<MemberProvider>();
    final assignedMembers = memberProvider.members.where((m) => m.assignedTrainerId == trainer.id).toList();
    final auth = context.watch<AuthProvider>();
    
    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        title: const Text('Trainer Profile'),
        actions: [
          if (auth.currentRole != UserRole.trainer) // Only Admin/SuperAdmin can edit full profile
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.push(
                context,
                buildAppRoute(AddEditTrainerScreen(existingTrainer: trainer)),
              ).then((_) => context.read<TrainerProvider>().refreshTrainers()),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: Text(
                      trainer.fullName.isNotEmpty ? trainer.fullName[0].toUpperCase() : 'T',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: context.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    trainer.fullName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trainer.specialization,
                    style: TextStyle(
                      color: context.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(title: "Phone", value: trainer.phone),
                  _InfoRow(title: "Email", value: trainer.email),
                  _InfoRow(title: "Specialization", value: trainer.specialization),
                  _InfoRow(title: "Experience", value: "${trainer.experienceYears} years"),
                  _InfoRow(title: "Shift Hours", value: "${trainer.shiftStart} - ${trainer.shiftEnd}"),
                  _InfoRow(
                    title: "Working Days",
                    value: trainer.workingDays.isNotEmpty ? trainer.workingDays.join(', ') : 'None',
                  ),
                  _InfoRow(title: "Status", value: trainer.status.toUpperCase()),
                  if (trainer.bio != null && trainer.bio!.trim().isNotEmpty)
                    _InfoRow(title: "Bio", value: trainer.bio!),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text(
              "Assigned Members",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            if (assignedMembers.isEmpty)
              Text("No members assigned yet", style: TextStyle(color: context.textSecondary))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: assignedMembers.length,
                itemBuilder: (context, index) => MemberCard(member: assignedMembers[index]),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;
  const _InfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: context.textSecondary)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontWeight: FontWeight.w500, color: context.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}