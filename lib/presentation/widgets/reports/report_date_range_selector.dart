import 'package:flutter/material.dart';
import 'package:gym_management_app/themes/app_design_tokens.dart';

class ReportDateRangeSelector extends StatelessWidget {
  final DateTimeRange selectedRange;
  final ValueChanged<DateTimeRange> onRangeChanged;

  const ReportDateRangeSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
  });

  Future<void> _pickRange(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedRange.start,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked == null || !context.mounted) return;
    final end = await showDatePicker(
      context: context,
      initialDate: selectedRange.end,
      firstDate: picked,
      lastDate: DateTime.now(),
    );
    if (end == null || !context.mounted) return;
    onRangeChanged(DateTimeRange(start: picked, end: end));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _pickRange(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        color: scheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${selectedRange.start.day}/${selectedRange.start.month}/${selectedRange.start.year} - '
                        '${selectedRange.end.day}/${selectedRange.end.month}/${selectedRange.end.year}',
                        style: TextStyle(
                            color: context.textPrimary, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: context.textMuted),
                  ],
                ),
              ),
            ),
          ),
          // Quick Filters
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: context.surfaceAlt,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildQuickFilter(context, 'Today', 0),
                _buildQuickFilter(context, 'Week', 7),
                _buildQuickFilter(context, 'Month', 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilter(BuildContext context, String label, int days) {
    final scheme = Theme.of(context).colorScheme;
    final isSelected = days == 0
        ? selectedRange.start.day == DateTime.now().day &&
            selectedRange.start.month == DateTime.now().month
        : selectedRange.end.difference(selectedRange.start).inDays == days;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: () {
          final now = DateTime.now();
          final start = days == 0
              ? DateTime(now.year, now.month, now.day)
              : now.subtract(Duration(days: days));
          final end = now;
          onRangeChanged(DateTimeRange(start: start, end: end));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? scheme.primary.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isSelected ? Border.all(color: scheme.primary) : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? scheme.primary : context.textSecondary,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
