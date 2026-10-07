/// 8pt spacing grid used across the app. All padding/margin values should
/// come from here so the system stays consistent in both light and dark themes.
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double display = 64;
}

/// Legacy radius tokens. Kept so existing imports of `AppRadius.card`,
/// `AppRadius.button`, `AppRadius.pill`, `AppRadius.sheet` keep working.
///
/// New code should prefer the `AppRadii` class in
/// `app_design_tokens.dart`, which exposes the full canonical scale
/// (`xs`, `sm`, `md`, `lg`, `xl`, `pill`).
class AppRadius {
  AppRadius._();

  /// Cards, dialogs, large containers.
  static const double card = 14;

  /// Buttons, inputs.
  static const double button = 10;

  /// Pills, badges, chips.
  static const double pill = 999;

  /// Bottom sheets, modals.
  static const double sheet = 20;
}