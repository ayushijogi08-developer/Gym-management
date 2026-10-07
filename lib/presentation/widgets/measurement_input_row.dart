import 'package:flutter/material.dart';
import '../../themes/app_design_tokens.dart';

/// A themed numeric input row used on the "Log Body Progress" form.
///
/// The previous implementation hardcoded `Colors.white*` shades, which
/// rendered the field invisible against the light-mode surface. This
/// version uses the active theme so labels, placeholder text, the unit
/// suffix, and the input value are all clearly legible on both light
/// and dark backgrounds.
///
/// The label is rendered as a persistent *floating label* (always shown
/// above the field) and as a secondary hint inside the field when the
/// field is empty, so users always know what value is expected even
/// after they've started typing.
class MeasurementInputRow extends StatelessWidget {
  final String label;
  final String unit;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool isOptional;

  const MeasurementInputRow({
    super.key,
    required this.label,
    required this.unit,
    required this.controller,
    this.validator,
    this.isOptional = false,
  });

  @override
  Widget build(BuildContext context) {
    // Persist the placeholder so it always shows, even when the field
    // is focused or has a value. Together with a *floating* label this
    // gives the user two redundant cues about what the field expects.
    final hintText = isOptional ? '$label (optional)' : 'Enter $label';
    final unitHint = unit.isEmpty ? '' : ' ($unit)';

    return TextFormField(
      controller: controller,
      style: TextStyle(
        color: context.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: validator,
      decoration: InputDecoration(
        // Persistent label above the field — always visible in both
        // light and dark mode for high-contrast readability.
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: TextStyle(
          color: context.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        floatingLabelStyle: TextStyle(
          color: context.primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        // Secondary placeholder inside the field for additional clarity.
        hintText: '$hintText$unitHint',
        hintStyle: TextStyle(
          color: context.textMuted,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        // Visible surface so the field reads as a distinct input on a
        // light background instead of an invisible container.
        filled: true,
        fillColor: context.surfaceAlt,
        // Distinct border using the theme's outline token so it's
        // clearly visible against the light surface.
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.danger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.danger, width: 1.5),
        ),
        // Unit shown inside the field on the right with proper contrast.
        suffixText: unit.isEmpty ? null : unit,
        suffixStyle: TextStyle(
          color: context.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        // Slightly tighter padding so the field is comfortable but
        // compact for a numeric measurement form.
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}