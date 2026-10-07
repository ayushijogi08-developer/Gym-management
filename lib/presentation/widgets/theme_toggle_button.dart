import 'package:flutter/material.dart';
import 'package:gym_management_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';

/// Top-app-bar theme toggle. Cycles the saved [ThemeMode] through
/// `light → dark → system → light …` and animates an icon swap so users
/// see an immediate signal that the theme flipped.
///
/// Drop this into any `AppBar.actions`:
/// ```dart
/// AppBar(actions: [ThemeToggleButton(), NotificationBellIcon()])
/// ```
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ThemeProvider>().themeMode;
    final isDark = mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return IconButton(
      tooltip: switch (mode) {
        ThemeMode.light => 'Theme: Light — tap for Dark',
        ThemeMode.dark => 'Theme: Dark — tap for System',
        ThemeMode.system => 'Theme: System — tap for Light',
      },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: Icon(
          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          key: ValueKey<bool>(isDark),
        ),
      ),
      onPressed: () {
        final provider = context.read<ThemeProvider>();
        final next = switch (provider.themeMode) {
          ThemeMode.light => ThemeMode.dark,
          ThemeMode.dark => ThemeMode.system,
          ThemeMode.system => ThemeMode.light,
        };
        provider.setMode(next);
      },
    );
  }
}
