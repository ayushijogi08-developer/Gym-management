import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/local/hive_boxes.dart';

/// Persists the user's [ThemeMode] preference in the shared `settings` box
/// and broadcasts it to listeners. Reads on construction so the very first
/// build after splash already reflects the saved preference.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _mode = _load();
  }

  static const _key = 'themeMode';

  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get themeMode => _mode;

  /// 'dark' | 'light' | 'system' — round-tripped with the persisted value
  /// so the settings screen can show the same string the user picked.
  String get modeString => switch (_mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };

  /// Update the active theme and persist immediately.
  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    try {
      await Hive.box(HiveBoxes.settings).put(_key, modeString);
    } catch (_) {
      // Persistence is best-effort; the in-memory mode still updates.
    }
  }

  /// Convenience wrapper that accepts the legacy string-based mode.
  Future<void> setModeString(String s) async {
    await setMode(_fromString(s));
  }

  static ThemeMode _fromString(String s) => switch (s) {
        'light' => ThemeMode.light,
        'system' => ThemeMode.system,
        _ => ThemeMode.dark,
      };

  ThemeMode _load() {
    try {
      final value = Hive.box(HiveBoxes.settings).get(_key);
      if (value is String) return _fromString(value);
    } catch (_) {
      // Hive box may not be open yet during very early boot. Fall through.
    }
    return ThemeMode.dark;
  }
}
