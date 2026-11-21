# GI Home (Flutter app)

Mobile app for a local GI Core appliance. HTTP, session and models live in
`../packages/gi_core_api`; this package is UI, state and platform glue.

## Run

Setup, backend start-up, seeding, base URL presets, codegen, analyze and all
test commands (unit, golden, contract, integration) are in the
[root README](../README.md). This file only describes the app's structure.

## Layout

```
lib/
  main.dart                 prod entrypoint; main_dev.dart, main_beta.dart
  src/app/bootstrap.dart    shared start-up: AppConfig of the flavor, error
                            zone, ProviderScope (config, prefs, app info), no
                            retries
  l10n/                     ARB + generated AppLocalizations
  src/app/                  GiHomeApp (MaterialApp.router), router/ (guard, shell)
  src/core/                 platform providers, theme tokens, lifecycle, polling,
                            failure → message mapping, shared widgets
  src/core/config/          AppFlavor, AppConfig (dart-defines), FeatureFlags
                            and their phone overrides (dev, beta)
  src/core/dev/             MockCoreAdapter: in-process GI Core (dev mock
                            flag, widget tests)
  src/features/appliance/   profile (domain/data), GI Core client, connect + setup
  src/features/auth/        token vault, session notifier, login, change password
  src/features/devices/     device/room repositories (last good value +
                            fetchedAt), polled notifiers, read-only details
  src/features/home/        "Dom" tab: HomeCondition, attention list, devices
                            grouped by room
  src/features/settings/    "Ustawienia" tab
  src/features/experimental/ hidden "Funkcje eksperymentalne" (dev, beta):
                            7 taps on the app version, /settings/experimental
test/
  flutter_test_config.dart  alchemist config (CI and platform goldens)
  golden/                   golden tests (tag `golden`) and goldens/ci/*.png
  support/                  test app, fakes, fixtures, golden harness, WCAG
```

## Routing

Guards (`resolveRedirect`, pure and unit-tested) run in order: no profile →
`/connect`; appliance not set up → `/setup-required`; session restoring or
restore failed → `/restore`; signed out → `/login`; `mustChangePassword` →
`/change-password`; otherwise the shell (`/home`, `/settings`). Device details
live under the Home branch at `/home/devices/:id`. The router is built once and
re-evaluated through `refreshListenable`.

## Polling

`ref.pollWhileWatched` (core/polling) runs a `ForegroundPoller` only while the
app is in the foreground and the provider has an active (not paused)
listener: `GET /devices` every 30 s while Home or details are visible,
`GET /devices/:id` every 5 s on details, `GET /rooms` when a screen opens.
Failures keep the last good data (`PolledData`) and show a banner with its
time; outdated data (older than 2× the interval) is announced as well.

## Platform notes

- Android allows cleartext in `network_security_config.xml` (`base-config`),
  because Android cannot scope it to private IP ranges; the Dart
  `TransportPolicy` refuses `http://` outside the home network. Backups and
  device transfer are disabled.
- iOS uses `NSAllowsLocalNetworking` (no arbitrary loads) and a Polish
  `NSLocalNetworkUsageDescription`.
- Android: minSdk 26, compileSdk and targetSdk 36; flavors dev, beta, prod
  with application ID suffixes `.dev`/`.beta` and their own label and icon.
  iOS: iPhone only, portrait, iOS 15+ (D13); per-flavor schemes need macOS.
