import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/gym_config_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/gradient_button.dart';

class TaxCurrencyScreen extends StatefulWidget {
  const TaxCurrencyScreen({super.key});

  @override
  State<TaxCurrencyScreen> createState() => _TaxCurrencyScreenState();
}

class _TaxCurrencyScreenState extends State<TaxCurrencyScreen> {
  late TextEditingController _taxController;

  @override
  void initState() {
    super.initState();
    final config = context.read<GymConfigProvider>().config;
    _taxController = TextEditingController(text: (config?.taxPercent ?? 18.0).toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tax & Currency')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppTextField(controller: _taxController, label: 'Tax % (GST)'),
            const SizedBox(height: 32),
            GradientButton(
              label: 'Save',
             onPressed: () {
  final provider = context.read<GymConfigProvider>();
  final config = provider.config;

  // 1. Check for null explicitly.
  // Dart will promote 'config' from 'GymConfigModel?' to 'GymConfigModel'
  // for the remainder of this scope.
  if (config != null) {
    config.taxPercent = double.tryParse(_taxController.text) ?? 18.0;
    provider.updateConfig(config);
    Navigator.pop(context);
  } else {
    // Optional: Show an error if config is null
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuration not loaded yet!')),
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