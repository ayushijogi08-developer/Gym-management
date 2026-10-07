import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/timeline_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../themes/app_design_tokens.dart';
import '../../widgets/timeline_entry_tile.dart';
import '../../widgets/timeline_year_divider.dart';

class PersonalTimelineScreen extends StatefulWidget {
  const PersonalTimelineScreen({super.key});

  @override
  State<PersonalTimelineScreen> createState() => _PersonalTimelineScreenState();
}

class _PersonalTimelineScreenState extends State<PersonalTimelineScreen> {
  bool _isLoading = true;
  String _selectedYear = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTimeline();
    });
  }

  Future<void> _loadTimeline() async {
    setState(() => _isLoading = true);
    
    final auth = context.read<AuthProvider>();
    final timelineProvider = context.read<TimelineProvider>();
    final memberId = auth.currentUser?.linkedMemberId ?? '';

    // First load from local
    timelineProvider.loadFromLocal();
    
    // Then fetch from API
    if (memberId.isNotEmpty) {
      await timelineProvider.fetchForMember(memberId);
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final timelineProvider = context.watch<TimelineProvider>();

    final memberId = auth.currentUser?.linkedMemberId ?? '';
    final events = timelineProvider.getTimelineForMember(memberId);

    // Group events by year
    final groupedEvents = <String, List<dynamic>>{};
    for (var event in events) {
      final year = event.date.year.toString();
      if (!groupedEvents.containsKey(year)) {
        groupedEvents[year] = [];
      }
      groupedEvents[year]!.add(event);
    }

    final sortedYears = groupedEvents.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        title: const Text('My Timeline'),
        backgroundColor: context.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTimeline,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _selectedYear = value);
            },
            itemBuilder: (context) {
              final years = sortedYears.isNotEmpty ? sortedYears : [DateTime.now().year.toString()];
              return [
                const PopupMenuItem(value: 'all', child: Text('All Years')),
                ...years.map((year) => PopupMenuItem(
                  value: year,
                  child: Text(year),
                )),
              ];
            },
          ),
        ],
      ),
      // REMOVED: FloatingActionButton for test events
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timeline,
                        size: 80,
                        color: context.textMuted,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No timeline events yet',
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your fitness journey will appear here! 🏃',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedYears.length,
                  itemBuilder: (context, yearIndex) {
                    final year = sortedYears[yearIndex];
                    
                    if (_selectedYear != 'all' && year != _selectedYear) {
                      return const SizedBox.shrink();
                    }
                    
                    final yearEvents = groupedEvents[year]!;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TimelineYearDivider(year: year),
                        const SizedBox(height: 8),
                        ...yearEvents.map((event) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TimelineEntryTile(event: event),
                        )),
                      ],
                    );
                  },
                ),
    );
  }
}