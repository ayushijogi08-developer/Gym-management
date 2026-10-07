import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Import only what you need
import '../presentation/screens/diet/add_edit_diet_plan_screen.dart';

// Create a wrapper function that returns the screen
Widget buildAddEditDietPlanRoute(BuildContext context, GoRouterState state) {
  final planId = state.uri.queryParameters['planId'];
  return AddEditDietPlanScreen(planId: planId);
}