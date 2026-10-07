import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_design_tokens.dart';

/// App-wide ThemeData. Two clean, fitness-forward palettes built on
/// Material 3 + ColorScheme + custom [ThemeExtension]s so widgets that read
/// from [Theme.of(context)] automatically switch between light and dark.
///
/// Migration note: legacy hardcoded `AppColors.background` / `textPrimary`
/// constants are `@Deprecated` and now point at dark values. Widgets that
/// still reference them will keep compiling but won't flip with the theme.
/// Use the `BuildContext` extension (`context.surface`, `context.textPrimary`)
/// or `Theme.of(context).colorScheme.*` going forward.
class AppTheme {
  AppTheme._();

  // ─────────────────────────  COLOR SCHEMES  ─────────────────────────

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF312E81), // indigo-900
    onPrimaryContainer: Color(0xFFE0E7FF),
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFF164E63),
    onSecondaryContainer: Color(0xFFCFFAFE),
    tertiary: AppColors.success,
    onTertiary: Colors.white,
    error: AppColors.danger,
    onError: Colors.white,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkTextPrimary,
    surfaceContainerHighest: AppColors.darkSurfaceAlt,
    onSurfaceVariant: AppColors.darkTextSecondary,
    outline: AppColors.darkBorder,
    outlineVariant: Color(0xFF323849),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: AppColors.lightTextPrimary,
    onInverseSurface: AppColors.darkBackground,
    inversePrimary: AppColors.primaryMuted,
  );

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFE0E7FF),
    onPrimaryContainer: Color(0xFF312E81),
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFCFFAFE),
    onSecondaryContainer: Color(0xFF164E63),
    tertiary: AppColors.success,
    onTertiary: Colors.white,
    error: AppColors.danger,
    onError: Colors.white,
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightTextPrimary,
    surfaceContainerHighest: AppColors.lightSurfaceAlt,
    onSurfaceVariant: AppColors.lightTextSecondary,
    outline: AppColors.lightBorder,
    outlineVariant: Color(0xFFCBD5E1),
    shadow: Color(0x140B1220),
    scrim: Color(0x73000000),
    inverseSurface: AppColors.darkTextPrimary,
    onInverseSurface: AppColors.darkBackground,
    inversePrimary: AppColors.primaryActive,
  );

  // ─────────────────────────  TYPOGRAPHY  ─────────────────────────

  static TextTheme _textTheme(ColorScheme scheme) {
    final base = GoogleFonts.poppinsTextTheme();
    final muted = scheme.onSurfaceVariant;
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
        color: scheme.onSurface,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: scheme.onSurface,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        color: scheme.onSurface,
        height: 1.5,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: scheme.onSurface,
        height: 1.5,
      ),
      bodySmall: base.bodySmall?.copyWith(
        color: muted,
        height: 1.4,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      labelMedium: base.labelMedium?.copyWith(
        color: muted,
      ),
      labelSmall: base.labelSmall?.copyWith(
        color: muted,
      ),
    );
  }

  // ──────────────────────  COMPONENT THEMES  ──────────────────────

  static AppBarTheme _appBarTheme(ColorScheme scheme) => AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
        actionsIconTheme: IconThemeData(color: scheme.onSurface),
        surfaceTintColor: Colors.transparent,
      );

  static CardThemeData _cardTheme(ColorScheme scheme) => CardThemeData(
        color: scheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: scheme.outline, width: 1),
        ),
      );

  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme scheme) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.primary.withValues(alpha: 0.4),
          disabledForegroundColor: scheme.onPrimary.withValues(alpha: 0.7),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md + 2,
          ),
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          elevation: 0,
        ),
      );

  static TextButtonThemeData _textButtonTheme(ColorScheme scheme) =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme scheme) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md + 2,
          ),
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      );

  static InputDecorationTheme _inputTheme(ColorScheme scheme) =>
      InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        hintStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: 14,
        ),
        floatingLabelStyle: TextStyle(
          color: scheme.primary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md + 4,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: scheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      );

  static DividerThemeData _dividerTheme(ColorScheme scheme) => DividerThemeData(
        color: scheme.outline,
        thickness: 1,
        space: 1,
      );

  static BottomNavigationBarThemeData _bottomNavTheme(ColorScheme scheme) =>
      BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      );

  static NavigationRailThemeData _navRailTheme(ColorScheme scheme) =>
      NavigationRailThemeData(
        backgroundColor: scheme.surface,
        selectedIconTheme: IconThemeData(color: scheme.primary),
        unselectedIconTheme:
            IconThemeData(color: scheme.onSurfaceVariant),
        selectedLabelTextStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: scheme.primary,
        ),
        unselectedLabelTextStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: scheme.onSurfaceVariant,
        ),
        indicatorColor: scheme.primary.withValues(alpha: 0.12),
        useIndicator: true,
      );

  static ChipThemeData _chipTheme(ColorScheme scheme) => ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        side: BorderSide(color: scheme.outline),
        labelStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      );

  static DialogThemeData _dialogTheme(ColorScheme scheme) => DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: scheme.onSurface,
        ),
      );

  static SnackBarThemeData _snackBarTheme(ColorScheme scheme) =>
      SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        actionTextColor: scheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      );

  static ProgressIndicatorThemeData _progressTheme(ColorScheme scheme) =>
      ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: scheme.surfaceContainerHighest,
      );

  static IconButtonThemeData _iconButtonTheme(ColorScheme scheme) =>
      IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      );

  static FloatingActionButtonThemeData _fabTheme(ColorScheme scheme) =>
      FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button + 4),
        ),
        extendedTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: scheme.onPrimary,
        ),
      );

  static PopupMenuThemeData _popupMenuTheme(ColorScheme scheme) =>
      PopupMenuThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          side: BorderSide(color: scheme.outline),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: scheme.onSurface,
        ),
      );

  // ─────────────────────────  PUBLIC THEMES  ───────────────────────

  static ThemeData get darkTheme => _buildTheme(_darkScheme);
  static ThemeData get lightTheme => _buildTheme(_lightScheme);

  static ThemeData _buildTheme(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final base = isDark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      textTheme: _textTheme(scheme),
      appBarTheme: _appBarTheme(scheme),
      cardTheme: _cardTheme(scheme),
      elevatedButtonTheme: _elevatedButtonTheme(scheme),
      textButtonTheme: _textButtonTheme(scheme),
      outlinedButtonTheme: _outlinedButtonTheme(scheme),
      inputDecorationTheme: _inputTheme(scheme),
      dividerTheme: _dividerTheme(scheme),
      bottomNavigationBarTheme: _bottomNavTheme(scheme),
      navigationRailTheme: _navRailTheme(scheme),
      chipTheme: _chipTheme(scheme),
      dialogTheme: _dialogTheme(scheme),
      snackBarTheme: _snackBarTheme(scheme),
      progressIndicatorTheme: _progressTheme(scheme),
      iconButtonTheme: _iconButtonTheme(scheme),
      floatingActionButtonTheme: _fabTheme(scheme),
      popupMenuTheme: _popupMenuTheme(scheme),
      iconTheme: IconThemeData(color: scheme.onSurface),
      splashColor: scheme.primary.withValues(alpha: 0.08),
      highlightColor: scheme.primary.withValues(alpha: 0.04),
      visualDensity: VisualDensity.standard,
      extensions: [
        isDark ? AppShadows.darkDefaults() : AppShadows.lightDefaults(),
        isDark
            ? AppSemanticColors.darkDefaults()
            : AppSemanticColors.lightDefaults(),
      ],
    );
  }

  // ──────────────────────  SYSTEM UI OVERLAY  ──────────────────────
  // Sets the status / nav bar to match the scaffold background so the
  // chrome doesn't flash white during theme switches on Android/iOS.

  static SystemUiOverlayStyle overlayStyleFor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: AppColors.darkBackground,
            systemNavigationBarIconBrightness: Brightness.light,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: AppColors.lightBackground,
            systemNavigationBarIconBrightness: Brightness.dark,
          );
  }
}