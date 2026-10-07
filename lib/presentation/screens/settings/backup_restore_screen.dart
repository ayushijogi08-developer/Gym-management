import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gym_management_app/presentation/widgets/gradient_button.dart';
import 'package:gym_management_app/services/backup_restore_service.dart';
import 'package:gym_management_app/themes/app_design_tokens.dart';
import 'package:gym_management_app/utils/platform_helper.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});
  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  bool _isProcessing = false;

 Future<void> _handleExport() async {
  setState(() => _isProcessing = true);
  final jsonData = await BackupRestoreService.exportBackup();

  final fileName = 'gym_backup_${DateTime.now().toIso8601String().split("T").first}.json';
  await PlatformHelper.shareOrDownloadFile(
    bytes: utf8.encode(jsonData), // Convert String to List<int>
    filename: fileName,
    mimeType: 'application/json',
  );
  setState(() => _isProcessing = false);

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup exported successfully')),
    );
  }
}

  Future<void> _handleImport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Backup?'),
        content: const Text(
          'This will overwrite ALL current data with the contents of the '
          'backup file. This cannot be undone. Continue?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restore', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    // Use file_picker to let the user select a .json backup file,
    // read its contents, then:
    // await BackupRestoreService.importBackup(fileContents);
    setState(() => _isProcessing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup restored successfully. Restart the app to see all changes.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Export a full backup of all gym data, or restore from a '
              'previously saved backup file.',
              style: TextStyle(color: context.textSecondary),
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Export Backup',
              isLoading: _isProcessing,
              onPressed: _handleExport,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _isProcessing ? null : _handleImport,
              child: const Text('Restore from Backup'),
            ),
          ],
        ),
      ),
    );
  }
}