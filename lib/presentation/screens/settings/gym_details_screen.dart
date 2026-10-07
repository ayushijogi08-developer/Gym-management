import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/gym_config_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/gradient_button.dart';

class GymDetailsScreen extends StatefulWidget {
  const GymDetailsScreen({super.key});

  @override
  State<GymDetailsScreen> createState() => _GymDetailsScreenState();
}

class _GymDetailsScreenState extends State<GymDetailsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final config = context.read<GymConfigProvider>().config;
    _nameController = TextEditingController(text: config?.gymName ?? '');
    _addressController = TextEditingController(text: config?.address ?? '');
    _phoneController = TextEditingController(text: config?.contactPhone ?? '');
    _emailController = TextEditingController(text: config?.contactEmail ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GymConfigProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Gym Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppTextField(controller: _nameController, label: 'Gym Name'),
            const SizedBox(height: 16),
            AppTextField(controller: _addressController, label: 'Address', maxLines: 3),
            const SizedBox(height: 16),
            AppTextField(controller: _phoneController, label: 'Contact Phone'),
            const SizedBox(height: 16),
            AppTextField(controller: _emailController, label: 'Contact Email'),
            const SizedBox(height: 32),
            GradientButton(
              label: 'Save Changes',
              onPressed: () {
                final currentConfig = provider.config;
                currentConfig?.gymName = _nameController.text;
                currentConfig?.address = _addressController.text;
                currentConfig?.contactPhone = _phoneController.text;
                currentConfig?.contactEmail = _emailController.text;
                provider.updateConfig(currentConfig!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}