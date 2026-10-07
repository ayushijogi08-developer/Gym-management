import 'package:flutter/material.dart';
import 'package:gym_management_app/presentation/screens/members/member_list_screen.dart';
import '../../../services/global_search_service.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/glass_container.dart';
import '../members/add_edit_member_screen.dart';
import 'package:gym_management_app/utils/route_helper.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final _searchController = TextEditingController();
  final GlobalSearchService _searchService = GlobalSearchService();
  List<dynamic> _results = [];

  void _performSearch(String query) {
    setState(() {
      _results = _searchService.search(query, context);
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _performSearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        title: const Text('Global Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(color: context.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search anything...',
                prefixIcon: Icon(Icons.search, color: context.textSecondary),
                filled: true,
                fillColor: context.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _results.isEmpty && _searchController.text.isEmpty
          ? Center(
              child: Text(
                'Start typing to search members, plans, trainers...',
                style: TextStyle(color: context.textSecondary),
              ),
            )
          : _results.isEmpty
              ? Center(
                  child: Text('No results found', style: TextStyle(color: context.textSecondary)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final result = _results[index];
                    return GlassContainer(
                      padding: const EdgeInsets.all(12),
                      child: ListTile(
                        leading: Icon(result.icon, color: AppColors.primary, size: 32),
                        title: Text(result.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(result.subtitle ?? '', style: TextStyle(color: context.textSecondary)),
                       onTap: () {
  if (result.category == 'member') {
    Navigator.push(
      context,
      buildAppRoute(
        AddEditMemberScreen(existingMember: result.relatedRecord),
      ),
    );
  } else if (result.category == 'plan') {
    // Open Member List filtered by this plan
    final plan = result.relatedRecord;
    Navigator.push(
      context,
      buildAppRoute(
         MemberListScreen(initialPlanFilter: plan.planName),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opened ${result.category}')),
    );
  }
},
                      ),
                    );
                  },
                ),
    );
  }
}