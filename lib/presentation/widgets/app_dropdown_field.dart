import 'package:flutter/material.dart';
import '../../themes/app_design_tokens.dart';

class AppDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?)? onChanged;
  final String? hint;
  final bool isRequired;

  const AppDropdownField({
    super.key,
    required this.label,
    this.value,
    required this.items,
    required this.itemLabel,
    this.onChanged,
    this.hint,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(color: context.textSecondary, fontSize: 14),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(color: context.danger),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T?>(
              value: value,
              hint: hint != null
                  ? Text(hint!, style: TextStyle(color: context.textMuted))
                  : null,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              dropdownColor: context.surface,
              style: TextStyle(color: context.textPrimary),
              icon: Icon(Icons.arrow_drop_down, color: context.textSecondary),
              items: [
                // Add "None" option for nullable types
                if (T != String)
                  DropdownMenuItem<T?>(
                    value: null,
                    child: Text(
                      'None',
                      style: TextStyle(color: context.textMuted),
                    ),
                  ),
                ...items.map((item) {
                  return DropdownMenuItem<T?>(
                    value: item,
                    child: Text(itemLabel(item)),
                  );
                }),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
