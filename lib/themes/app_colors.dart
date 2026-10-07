import 'package:flutter/material.dart';

/// Centralized color palette.
///
/// **Preferred:** widgets should read colors from `Theme.of(context).colorScheme`
/// or the `BuildContext` extension in `app_design_tokens.dart`. These
/// constants exist for:
///   1. Brand color values that don't change between light/dark.
///   2. The ColorScheme itself (built once, used everywhere).
///   3. Legacy aliases kept so older widgets still compile during the
///      theme migration. New code should ignore them.
///
/// **Avoid** the legacy aliases (`AppColors.background`, `AppColors.card`,
/// `AppColors.textPrimary`, etc.) — they're now `@Deprecated` and the
/// non-deprecated replacements are *context-aware* (`AppColors.backgroundOf(ctx)`).
class AppColors {
  AppColors._();

  // ─────────────────────────  BRAND  ─────────────────────────
  static const Color primary = Color(0xFF4F46E5); // indigo-600
  static const Color primaryHover = Color(0xFF4338CA); // indigo-700
  static const Color primaryActive = Color(0xFF3730A3); // indigo-800
  static const Color primaryMuted = Color(0xFF818CF8); // indigo-400 (light-mode hover tint)
  static const Color secondary = Color(0xFF06B6D4); // cyan-500
  static const Color accent = Color(0xFF22D3EE); // cyan-400 (vibrant accent)
  static const Color accentMuted = Color(0xFF0891B2); // cyan-600

  // ───────────────────────  SEMANTIC  ────────────────────────
  static const Color success = Color(0xFF16A34A); // green-600
  static const Color warning = Color(0xFFD97706); // amber-600
  static const Color danger = Color(0xFFDC2626); // red-600
  static const Color info = Color(0xFF2563EB); // blue-600

  // ───────────────  LIGHT SURFACES (palette)  ────────────────
  static const Color lightBackground = Color(0xFFF7F8FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFEEF1F6);
  static const Color lightSurfaceSunken = Color(0xFFF2F4F8);
  static const Color lightBorder = Color(0xFFE5E9F0);
  static const Color lightBorderStrong = Color(0xFFCBD5E1);
  static const Color lightTextPrimary = Color(0xFF0B1220);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // ───────────────  DARK SURFACES (palette)  ─────────────────
  static const Color darkBackground = Color(0xFF07090F);
  static const Color darkSurface = Color(0xFF0F1422);
  static const Color darkSurfaceAlt = Color(0xFF161C2E);
  static const Color darkSurfaceSunken = Color(0xFF0B0F1A);
  static const Color darkBorder = Color(0xFF1F2638);
  static const Color darkBorderStrong = Color(0xFF2C344A);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // ───────────────  LEGACY ALIASES (deprecated)  ─────────────
  // These used to be the only definition; they pointed at the dark
  // values. New code should use `backgroundOf(ctx)` / `surfaceOf(ctx)` /
  // `textPrimaryOf(ctx)` etc. so the value tracks the active theme.
  @Deprecated('Use AppSemanticColors.of(context).surfaceSunken in dark, '
      'or context.surfaceAlt in light. Kept for legacy widgets.')
  static const Color background = darkBackground;
  @Deprecated('Use AppSemanticColors / context.surface instead.')
  static const Color card = darkSurface;
  @Deprecated('Use context.border instead.')
  static const Color border = darkBorder;
  @Deprecated('Use context.textPrimary instead.')
  static const Color textPrimary = darkTextPrimary;
  @Deprecated('Use context.textSecondary instead.')
  static const Color textSecondary = darkTextSecondary;

  // ──────────────────────  CONTEXT GETTERS  ───────────────────
  // Read these at the call site so the value matches the active theme.
  // The legacy constants above stay so older files still compile.

  /// Background of the active scaffold. Light: `#F7F8FB`, Dark: `#07090F`.
  static Color backgroundOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  /// Card / sheet surface. Light: `#FFFFFF`, Dark: `#0F1422`.
  static Color surfaceOf(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  /// Hover rows, table headers, secondary fills.
  static Color surfaceAltOf(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHighest;

  static Color borderOf(BuildContext context) =>
      Theme.of(context).colorScheme.outline;

  static Color textPrimaryOf(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color textSecondaryOf(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  // ────────────────────────  GRADIENTS  ───────────────────────
  /// Brand gradient — used sparingly for hero CTAs and stat-card accents.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Premium "glass" wash for hero cards. Slight cyan-tinted highlight on top.
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x14FFFFFF), Color(0x06FFFFFF)],
  );
}
