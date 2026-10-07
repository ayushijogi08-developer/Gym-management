import 'package:flutter/material.dart';
import 'package:gym_management_app/domain/entities/user_role.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/member_provider.dart';
import '../providers/plan_provider.dart';
import '../providers/trainer_provider.dart';
import '../data/models/search_result_model.dart';

class GlobalSearchService {
  List<SearchResultModel> search(String query, BuildContext context) {
    if (query.trim().isEmpty) return [];

    final auth = context.read<AuthProvider>();
    final results = <SearchResultModel>[];

    final q = query.toLowerCase();

    // Members - always searchable
    final members = context.read<MemberProvider>().members.where((m) =>
        m.fullName.toLowerCase().contains(q) ||
        m.phone.contains(q) ||
        m.email.toLowerCase().contains(q));

    results.addAll(members.map((m) => SearchResultModel(
          id: m.id,
          category: 'member',
          title: m.fullName,
          subtitle: m.phone,
          icon: Icons.person,
          relatedRecord: m,
        )));

    // Plans
    final plans = context.read<PlanProvider>().plans.where((p) =>
        p.planName.toLowerCase().contains(q));

    results.addAll(plans.map((p) => SearchResultModel(
          id: p.id,
          category: 'plan',
          title: p.planName,
          subtitle: p.durationType,
          icon: Icons.card_membership,
          relatedRecord: p,
        )));

    // Trainers (gated)
    if (auth.hasPermission('canManageTrainers') || auth.currentRole == UserRole.trainer) {
      final trainers = context.read<TrainerProvider>().trainers.where((t) =>
          t.fullName.toLowerCase().contains(q));

      results.addAll(trainers.map((t) => SearchResultModel(
            id: t.id,
            category: 'trainer',
            title: t.fullName,
            subtitle: t.specialization,
            icon: Icons.fitness_center,
            relatedRecord: t,
          )));
    }

    return results;
  }
}