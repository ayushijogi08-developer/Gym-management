import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import '../utils/platform_helper.dart';

class ReportExportService {
  static Future<void> exportToPDF({
    required String title,
    required String summary,
    required BuildContext context,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text(summary),
            pw.SizedBox(height: 20),
            pw.Text('Generated on: ${DateTime.now()}'),
          ],
        ),
      ),
    );

    final bytes = await pdf.save();
    final fileName = '$title-${DateTime.now().millisecondsSinceEpoch}.pdf';

 if (!context.mounted) return;

    // 2. Pass parameters exactly as your PlatformHelper expects
    await PlatformHelper.shareOrDownloadFile(
      bytes: bytes.toList(), // Ensure it's a List<int>
      filename: fileName,    // Matches 'filename' from your helper
      mimeType: 'application/pdf',
      // If your helper doesn't need context, remove it. 
      // If it DOES need it, update the helper's signature.
    );
  }

  static Future<void> exportToExcel({
    required String title,
    required BuildContext context,
  }) async {
    final csvContent = 'Date,Amount,Type\n2026-07-01,2500,Cash\n2026-07-03,1800,UPI\n';
    final bytes = csvContent.codeUnits;
    final fileName = '$title-${DateTime.now().millisecondsSinceEpoch}.csv';

    if (!context.mounted) return;

    await PlatformHelper.shareOrDownloadFile(
      bytes: bytes,
      filename: fileName,
      mimeType: 'text/csv',
    );
  }
}