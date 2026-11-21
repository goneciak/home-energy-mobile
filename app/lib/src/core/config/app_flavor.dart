/// Build flavor of the app (plan §19.2). Each one has its own Android
/// application ID suffix, launcher label and icon, entrypoint
/// (`lib/main_dev.dart`, `lib/main_beta.dart`, `lib/main.dart`) and config
/// file (`config/<flavor>.json`, passed with `--dart-define-from-file`).
enum AppFlavor {
  /// Developers: dev address presets, the mock Core and every
  /// experimental feature.
  dev,

  /// TestFlight and Play closed testing: experimental features can be
  /// switched on from the hidden screen.
  beta,

  /// The store build: config defaults only, nothing hidden to switch on.
  prod;

  /// The flavor named [value] (`dev`, `beta`, `prod`), or `null`.
  static AppFlavor? tryParse(String value) => values.asNameMap()[value];

  /// Whether feature flags may be overridden on the phone, from the hidden
  /// "Funkcje eksperymentalne" screen (plan §19.6).
  bool get allowsFlagOverrides => this != prod;
}
