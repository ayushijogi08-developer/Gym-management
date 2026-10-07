import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gym_management_app/data/models/payment_model.dart';
import 'package:gym_management_app/themes/app_colors.dart';
import 'package:gym_management_app/themes/app_design_tokens.dart';
import 'package:provider/provider.dart';
import '../../widgets/glass_container.dart';
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:gym_management_app/providers/gym_config_provider.dart';

class InvoicePreviewScreen extends StatefulWidget {
  final PaymentModel payment;

  const InvoicePreviewScreen({super.key, required this.payment});

  @override
  State<InvoicePreviewScreen> createState() => _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends State<InvoicePreviewScreen> {
  bool _isLoading = false;

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy');
    final gymConfig = context.read<GymConfigProvider>().config;
    final gymName = gymConfig?.gymName ?? 'Gym';
    final gymAddress = gymConfig?.address ?? '';
    final gymPhone = gymConfig?.contactPhone ?? 'N/A';

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        gymName.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        gymAddress,
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        widget.payment.invoiceNumber,
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Bill To:',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        widget.payment.memberName ?? 'Member ${widget.payment.memberId}',
                        style: pw.TextStyle(fontSize: 14),
                      ),
                      pw.Text(
                        'Phone: $gymPhone',
                        style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Date: ${dateFormat.format(widget.payment.paymentDate)}',
                        style: pw.TextStyle(fontSize: 14),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Status: ${widget.payment.status.toUpperCase()}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: widget.payment.status == 'completed'
                              ? PdfColors.green
                              : PdfColors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Table(
                border: pw.TableBorder(
                  horizontalInside: pw.BorderSide(
                    color: PdfColors.grey300,
                    width: 1,
                  ),
                ),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text(
                          'Description',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text(
                          'Amount',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text('Membership Fee'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text(
                          '₹${widget.payment.amount.toStringAsFixed(2)}',
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  if (widget.payment.gstAmount > 0)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Text('GST (18%)'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Text(
                            '₹${widget.payment.gstAmount.toStringAsFixed(2)}',
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Total',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '₹${(widget.payment.amount + widget.payment.gstAmount).toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Thank you for your payment!',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  Future<void> _sharePdf() async {
    setState(() => _isLoading = true);
    try {
      final pdfBytes = await _generatePdf();
      await Share.shareXFiles(
        [
          XFile.fromData(pdfBytes,
              mimeType: 'application/pdf',
              name: 'invoice_${widget.payment.invoiceNumber}.pdf')
        ],
        text: 'Invoice ${widget.payment.invoiceNumber}',
      );
    } catch (e) {
      debugPrint('Error sharing PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error sharing PDF: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _printPdf() async {
    setState(() => _isLoading = true);
    try {
      final pdfBytes = await _generatePdf();
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'invoice_${widget.payment.invoiceNumber}.pdf',
      );
    } catch (e) {
      debugPrint('Error printing PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error printing PDF: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final isMobile = MediaQuery.of(context).size.width < 600;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
        actions: [
          if (!isMobile)
            IconButton(
              icon: const Icon(Icons.print_rounded),
              onPressed: _printPdf,
              tooltip: 'Print',
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: context.colors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Generating PDF…',
                    style: TextStyle(color: context.textSecondary),
                  ),
                ],
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      GlassContainer(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (context.watch<GymConfigProvider>().config?.gymName ??
                                                'GYM MANAGEMENT')
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: context.colors.primary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        context
                                                .watch<GymConfigProvider>()
                                                .config
                                                ?.address ??
                                            '',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: context.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'INVOICE',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: context.colors.primary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.payment.invoiceNumber,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: context.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 30, color: context.border),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Bill To:',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: context.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        (widget.payment.memberName?.length ??
                                                    0) >
                                                20
                                            ? '${widget.payment.memberName!.substring(0, 20)}…'
                                            : widget.payment.memberName ??
                                                'Member',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: context.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'ID: ${widget.payment.memberId.length > 10 ? widget.payment.memberId.substring(0, 10) : widget.payment.memberId}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: context.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Date:',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: context.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        dateFormat
                                            .format(widget.payment.paymentDate),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: context.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Status:',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: context.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      _StatusPill(
                                        status: widget.payment.status,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: context.surfaceAlt,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Description',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: context.textSecondary,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Amount',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: context.textSecondary,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Membership Fee',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: context.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '₹${widget.payment.amount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: context.textPrimary,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (widget.payment.gstAmount > 0) ...[
                              Divider(height: 1, color: context.border),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        'GST',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: context.textSecondary,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '₹${widget.payment.gstAmount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: context.textSecondary,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            Divider(height: 16, color: context.border),

                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '₹${(widget.payment.amount + widget.payment.gstAmount).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: context.colors.primary,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            Divider(height: 1, color: context.border),
                            const SizedBox(height: 6),
                            Center(
                              child: Text(
                                'Thank you for your payment!',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: ElevatedButton.icon(
                                onPressed: _sharePdf,
                                icon: const Icon(Icons.share_rounded, size: 16),
                                label: const Text('Download / Share'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: OutlinedButton.icon(
                                onPressed: () => _showRefundDialog(context),
                                icon: const Icon(Icons.money_off_rounded,
                                    size: 16),
                                label: const Text('Refund'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: scheme.error,
                                  side: BorderSide(color: scheme.error),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void _showRefundDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.money_off_rounded,
            color: Theme.of(ctx).colorScheme.error, size: 32),
        title: const Text('Process Refund'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Refund payment of ₹${widget.payment.amount.toStringAsFixed(2)}?',
              style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Reason for refund',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.errorContainer,
              foregroundColor: Theme.of(ctx).colorScheme.onErrorContainer,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refund processed successfully')),
              );
            },
            child: const Text('Confirm Refund'),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final isCompleted = status.toLowerCase() == 'completed';
    final color =
        isCompleted ? Theme.of(context).colorScheme.tertiary : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}