import 'package:flutter/material.dart';
import '../../../themes/app_colors.dart';

class AiConsentDialog extends StatefulWidget {
  const AiConsentDialog({super.key});

  @override
  State<AiConsentDialog> createState() => _AiConsentDialogState();
}

class _AiConsentDialogState extends State<AiConsentDialog> {
  bool includeMedical = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text('AI Assistant Privacy', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'The AI can use your diet, workout, and goals for better recommendations.\n\n'
            'Would you also like to include medical conditions?',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Include Medical Conditions', style: TextStyle(color: Colors.white)),
            value: includeMedical,
            onChanged: (v) => setState(() => includeMedical = v),
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Decline'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, {
            'includeMedical': includeMedical,
          }),
          child: const Text('Accept', style: TextStyle(color: AppColors.primary)),
        ),
      ],
    );
  }
}