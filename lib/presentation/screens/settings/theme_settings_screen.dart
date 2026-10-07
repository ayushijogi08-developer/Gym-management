import 'package:flutter/material.dart';
import 'package:gym_management_app/presentation/widgets/theme_toggle_button.dart';
import 'package:provider/provider.dart';

import '../../../providers/theme_provider.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_design_tokens.dart';

/// Settings screen for the theme. Real segmented control with live
/// preview swatches; persists choice via [ThemeProvider].
class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Theme')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _SectionHeader(
                  title: 'Appearance',
                  subtitle:
                      'Pick how the app looks. "System" follows your device setting.',
                ),
                const SizedBox(height: 16),
                _ThemePreviewGrid(active: provider.themeMode),
                const SizedBox(height: 24),
                _ModeSelector(active: provider.themeMode),
                const SizedBox(height: 32),
                _SectionHeader(
                  title: 'Quick Toggle',
                  subtitle:
                      'The sun/moon button in the top app bar cycles through the three modes. Your choice is remembered across launches.',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const ThemeToggleButton(),
                    const SizedBox(width: 12),
                    Text(
                      'Tap to switch',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: context.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Preview grid (2 swatches + 3-mode segmented control below)
// ─────────────────────────────────────────────────────────────────────────────

class _ThemePreviewGrid extends StatelessWidget {
  final ThemeMode active;
  const _ThemePreviewGrid({required this.active});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth >= 560;
      final tiles = <Widget>[
        _PreviewTile(
          mode: ThemeMode.light,
          active: active,
          wide: wide,
          bg: AppColors.lightBackground,
          card: AppColors.lightSurface,
          border: AppColors.lightBorder,
        ),
        _PreviewTile(
          mode: ThemeMode.dark,
          active: active,
          wide: wide,
          bg: AppColors.darkBackground,
          card: AppColors.darkSurface,
          border: AppColors.darkBorder,
        ),
      ];
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: tiles,
      );
    });
  }
}

class _PreviewTile extends StatelessWidget {
  final ThemeMode mode;
  final ThemeMode active;
  final bool wide;
  final Color bg;
  final Color card;
  final Color border;

  const _PreviewTile({
    required this.mode,
    required this.active,
    required this.wide,
    required this.bg,
    required this.card,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = active == mode;
    final width = wide ? 280.0 : double.infinity;
    return SizedBox(
      width: width,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: () => context.read<ThemeProvider>().setMode(mode),
        child: AnimatedContainer(
          duration: AppMotion.base,
          curve: AppMotion.ease,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: isActive ? context.colors.primary : border,
              width: isActive ? 2 : 1,
            ),
            boxShadow: AppShadows.of(context).elevation1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 110,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: border),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: bg.computeLuminance() > 0.5
                              ? Colors.black.withValues(alpha: 0.06)
                              : Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      top: 38,
                      bottom: 12,
                      width: 36,
                      child: Container(
                        decoration: BoxDecoration(
                          color: bg.computeLuminance() > 0.5
                              ? Colors.black.withValues(alpha: 0.06)
                              : Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 44,
                      left: 58,
                      right: 12,
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: border),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    mode == ThemeMode.light
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    size: 18,
                    color: isActive ? context.colors.primary : context.textPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    mode == ThemeMode.light ? 'Light' : 'Dark',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (isActive)
                    Icon(Icons.check_circle_rounded,
                        size: 18, color: context.colors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Segmented mode selector
// ─────────────────────────────────────────────────────────────────────────────

class _ModeSelector extends StatelessWidget {
  final ThemeMode active;
  const _ModeSelector({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: context.border),
      ),
      child: Row(
        children: [
          for (final mode in const [
            ThemeMode.light,
            ThemeMode.dark,
            ThemeMode.system
          ])
            Expanded(
              child: _ModeChip(
                mode: mode,
                active: active,
                onTap: () => context.read<ThemeProvider>().setMode(mode),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final ThemeMode mode;
  final ThemeMode active;
  final VoidCallback onTap;
  const _ModeChip({
    required this.mode,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = active == mode;
    final label = switch (mode) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      ThemeMode.system => 'System',
    };
    final icon = switch (mode) {
      ThemeMode.light => Icons.light_mode_rounded,
      ThemeMode.dark => Icons.dark_mode_rounded,
      ThemeMode.system => Icons.brightness_auto_rounded,
    };

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.base,
        curve: AppMotion.ease,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? context.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: isActive
              ? Border.all(color: context.border)
              : Border.all(color: Colors.transparent),
          boxShadow: isActive ? AppShadows.of(context).elevation1 : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? context.textPrimary : context.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? context.textPrimary : context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}