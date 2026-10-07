import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/gym_config_provider.dart';
import '../../widgets/gradient_button.dart';

class WorkingHoursScreen extends StatefulWidget {
  const WorkingHoursScreen({super.key});

  @override
  State<WorkingHoursScreen> createState() => _WorkingHoursScreenState();
}

class _WorkingHoursScreenState extends State<WorkingHoursScreen> {
  List<String> selectedDays = [];
  TimeOfDay openingTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay closingTime = const TimeOfDay(hour: 22, minute: 0);

@override
  void initState() {
    super.initState();
    final config = context.read<GymConfigProvider>().config;
    
    // Check if config exists, otherwise use sensible defaults
    if (config != null) {
      selectedDays = List.from(config.workingDays);
      openingTime = TimeOfDay(
        hour: int.parse(config.openingTime.split(':')[0]),
        minute: int.parse(config.openingTime.split(':')[1]),
      );
      closingTime = TimeOfDay(
        hour: int.parse(config.closingTime.split(':')[0]),
        minute: int.parse(config.closingTime.split(':')[1]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Working Hours')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
                return FilterChip(
                  label: Text(day),
                  selected: selectedDays.contains(day),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedDays.add(day);
                      } else {
                        selectedDays.remove(day);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            ListTile(
              title: const Text('Opening Time'),
              trailing: Text(openingTime.format(context)),
              onTap: () async {
                final time = await showTimePicker(context: context, initialTime: openingTime);
                if (time != null) setState(() => openingTime = time);
              },
            ),
            ListTile(
              title: const Text('Closing Time'),
              trailing: Text(closingTime.format(context)),
              onTap: () async {
                final time = await showTimePicker(context: context, initialTime: closingTime);
                if (time != null) setState(() => closingTime = time);
              },
            ),
            const Spacer(),
            GradientButton(
    label: 'Save Hours',
    onPressed: () {
      final provider = context.read<GymConfigProvider>();
      final config = provider.config;
      
      // Ensure config is not null before updating
      if (config != null) {
        config.workingDays = selectedDays;
        config.openingTime = '${openingTime.hour}:${openingTime.minute.toString().padLeft(2, '0')}';
        config.closingTime = '${closingTime.hour}:${closingTime.minute.toString().padLeft(2, '0')}';
        provider.updateConfig(config);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuration error: Data not loaded.')),
        );
      }
    },
  ),
          ],
        ),
      ),
    );
  }
}