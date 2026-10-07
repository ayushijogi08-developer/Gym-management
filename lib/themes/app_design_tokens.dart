import 'package:flutter/material.dart';

/// Design-system tokens that don't fit cleanly on Material 3's ColorScheme:
///
/// * Shadow elevation levels (subtle SaaS-style).
/// * Motion durations + curves.
/// * Extended radius scale (xs/sm/md/lg + pill).
///
/// Access from anywhere with:
///
/// ```dart
/// final shadows = AppShadows.of(context);
/// final motion  = AppMotion.of(context);
/// final radii   = AppRadii.of(context);
/// ```
class AppShadows extends ThemeExtension<AppShadows> {
  final List<BoxShadow> elevation1; // cards at rest
  final List<BoxShadow> elevation2; // cards on hover / pressed
  final List<BoxShadow> elevation3; // popovers, menus, dropdowns
  final List<BoxShadow> elevation4; // modals, bottom sheets
  final List<BoxShadow> accentGlow; // signature neon-cyan halo on CTAs

  const AppShadows({
    required this.elevation1,
    required this.elevation2,
    required this.elevation3,
    required this.elevation4,
    required this.accentGlow,
  });

  static AppShadows of(BuildContext context) =>
      Theme.of(context).extension<AppShadows>() ?? AppShadows.lightDefaults();

  /// Light-mode defaults — soft slate-900 shadows, low alpha.
  factory AppShadows.lightDefaults() => const AppShadows(
        elevation1: [
          BoxShadow(
            color: Color(0x0F0B1220), // slate-900 @ 6%
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
        elevation2: [
          BoxShadow(
            color: Color(0x140B1220), // 8%
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
          BoxShadow(
            color: Color(0x0A0B1220), // 4%
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
        elevation3: [
          BoxShadow(
            color: Color(0x1A0B1220), // 10%
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: Color(0x0F0B1220),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
        elevation4: [
          BoxShadow(
            color: Color(0x1F0B1220), // 12%
            blurRadius: 16,
            offset: Offset(0, 12),
          ),
          BoxShadow(
            color: Color(0x140B1220),
            blurRadius: 40,
            offset: Offset(0, 24),
          ),
        ],
        accentGlow: [
          BoxShadow(
            color: Color(0x3322D3EE), // cyan-400 @ 20%
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      );

  /// Dark-mode defaults — pure black shadows, stronger alpha for same
  /// perceived depth on dark surfaces.
  factory AppShadows.darkDefaults() => const AppShadows(
        elevation1: [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
        elevation2: [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
        elevation3: [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
        elevation4: [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 16,
            offset: Offset(0, 12),
          ),
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 40,
            offset: Offset(0, 24),
          ),
        ],
        accentGlow: [
          BoxShadow(
            color: Color(0x6622D3EE), // cyan-400 @ 40%
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      );

  @override
  AppShadows copyWith({
    List<BoxShadow>? elevation1,
    List<BoxShadow>? elevation2,
    List<BoxShadow>? elevation3,
    List<BoxShadow>? elevation4,
    List<BoxShadow>? accentGlow,
  }) {
    return AppShadows(
      elevation1: elevation1 ?? this.elevation1,
      elevation2: elevation2 ?? this.elevation2,
      elevation3: elevation3 ?? this.elevation3,
      elevation4: elevation4 ?? this.elevation4,
      accentGlow: accentGlow ?? this.accentGlow,
    );
  }

  @override
  AppShadows lerp(ThemeExtension<AppShadows>? other, double t) {
    if (other is! AppShadows) return this;
    return AppShadows(
      elevation1: BoxShadow.lerpList(elevation1, other.elevation1, t)!,
      elevation2: BoxShadow.lerpList(elevation2, other.elevation2, t)!,
      elevation3: BoxShadow.lerpList(elevation3, other.elevation3, t)!,
      elevation4: BoxShadow.lerpList(elevation4, other.elevation4, t)!,
      accentGlow: BoxShadow.lerpList(accentGlow, other.accentGlow, t)!,
    );
  }
}

/// Motion tokens. Standardize every Duration + curve in the app.
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 320);
  static const Duration page = Duration(milliseconds: 280);

  static const Curve ease = Curves.easeOutCubic;
  static const Curve easeIn = Curves.easeInCubic;
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
}

/// Extended radius scale. Distinct from `AppRadius` (which is the
/// shorthand used inside the theme) — this is the canonical set.
class AppRadii {
  AppRadii._();

  static const double xxs = 4;
  static const double xs = 6;
  static const double sm = 10; // inputs, buttons
  static const double md = 14; // cards
  static const double lg = 20; // sheets
  static const double xl = 28; // hero panels
  static const double pill = 999;
}

/// Semantic color accessors that resolve from the active theme.
///
/// Use these instead of reading `ColorScheme` directly so widgets stay
/// readable (`context.surface` reads better than
/// `Theme.of(context).colorScheme.surface`). Also exposes colors that
/// aren't on ColorScheme (e.g. `accent`, `surfaceSunken`).
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color accent; // neon cyan
  final Color accentMuted; // darker accent on light bg
  final Color surfaceSunken; // inset wells
  final Color borderStrong; // input borders
  final Color textMuted; // disabled / caption

  const AppSemanticColors({
    required this.accent,
    required this.accentMuted,
    required this.surfaceSunken,
    required this.borderStrong,
    required this.textMuted,
  });

  static AppSemanticColors of(BuildContext context) =>
      Theme.of(context).extension<AppSemanticColors>() ??
      AppSemanticColors.lightDefaults();

  factory AppSemanticColors.lightDefaults() => const AppSemanticColors(
        accent: Color(0xFF22D3EE), // cyan-400
        accentMuted: Color(0xFF0891B2), // cyan-600
        surfaceSunken: Color(0xFFF2F4F8),
        borderStrong: Color(0xFFCBD5E1),
        textMuted: Color(0xFF94A3B8),
      );

  factory AppSemanticColors.darkDefaults() => const AppSemanticColors(
        accent: Color(0xFF22D3EE),
        accentMuted: Color(0xFF67E8F9), // cyan-300
        surfaceSunken: Color(0xFF0B0F1A),
        borderStrong: Color(0xFF2C344A),
        textMuted: Color(0xFF64748B),
      );

  @override
  AppSemanticColors copyWith({
    Color? accent,
    Color? accentMuted,
    Color? surfaceSunken,
    Color? borderStrong,
    Color? textMuted,
  }) {
    return AppSemanticColors(
      accent: accent ?? this.accent,
      accentMuted: accentMuted ?? this.accentMuted,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      borderStrong: borderStrong ?? this.borderStrong,
      textMuted: textMuted ?? this.textMuted,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      accent: Color.lerp(accent, other.accent, t)!,
      accentMuted: Color.lerp(accentMuted, other.accentMuted, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
    );
  }
}

/// Convenience extension so widgets can write:
/// `context.surface`, `context.textPrimary`, etc.
extension AppThemeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;

  // Surfaces
  Color get background => Theme.of(this).scaffoldBackgroundColor;
  Color get surface => colors.surface;
  Color get surfaceAlt => colors.surfaceContainerHighest;
  Color get surfaceSunken => AppSemanticColors.of(this).surfaceSunken;

  // Borders
  Color get border => colors.outline;
  Color get borderStrong => AppSemanticColors.of(this).borderStrong;

  // Text
  Color get textPrimary => colors.onSurface;
  Color get textSecondary => colors.onSurfaceVariant;
  Color get textMuted => AppSemanticColors.of(this).textMuted;

  // Brand
  Color get primary => colors.primary;
  Color get accent => AppSemanticColors.of(this).accent;
  Color get accentMuted => AppSemanticColors.of(this).accentMuted;

  // Semantic
  Color get success => colors.tertiary;
  Color get warning => Color.alphaBlend(
        colors.tertiary.withValues(alpha: 0.0),
        const Color(0xFFD97706),
      );
  Color get danger => colors.error;
  Color get info => colors.primary;

  // Shadows
  AppShadows get shadows => AppShadows.of(this);

  // Motion
  Duration get motionFast => AppMotion.fast;
  Duration get motionBase => AppMotion.base;
  Duration get motionSlow => AppMotion.slow;
  Curve get motionCurve => AppMotion.ease;
}
