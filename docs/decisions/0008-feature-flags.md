# 0008. Typowane flagi funkcji z domyślnymi wartościami per flavor, bez zdalnej konfiguracji

- **Status:** Przyjęta (M0). Scalanie z wynikami sond funkcji (§16) dojdzie w M3.
- **Data:** 2026-11-19
- **Plan:** §13.4, §16, §19.2, §19.6, D8

## Kontekst

Część funkcji jest niepewna albo zależy od decyzji właściciela: konwersja
czasu harmonogramów na czas domu (§13.4, D8: „Edytuj w czasie domu”, strefa
z `/settings/system`, nie strefa telefonu), sterowanie przełącznikami per
typ integracji (§19.6), runtime'owe żądanie uprawnienia sieci lokalnej na Androidzie (§9.4),
mock Core do pracy bez backendu. Aplikacja działa wyłącznie w LAN i nie ma
backendu „od nas”, więc zdalna konfiguracja (Firebase Remote Config itp.)
nie wchodzi w grę: byłaby jedyną usługą chmurową i łamałaby politykę
prywatności (brak SDK zewnętrznych).

## Decyzja

- Enum `FeatureFlag` i niezmienny obiekt `FeatureFlags`
  (`app/lib/src/core/config/feature_flags.dart`). Obecne flagi: `mockCore`
  (tylko dev), `scheduleClockConversion` (D8),
  `switchControlByIntegration` (§19.6), `androidLocalNetworkPermissionRequest`,
  `conditionalGet` oraz `mdnsFallback` ([ADR 0015](0015-network-change-no-write-replay.md)).
  D10 (lokalne powiadomienia w tle, v1.1) dostanie własną flagę, gdy
  powstanie.
- Wartości domyślne z `config/<flavor>.json` przez `--dart-define-from-file`
  (klucze `FF_*`); bez define flaga jest wyłączona. We wszystkich trzech
  plikach wszystkie flagi są dziś `false`.
- W dev i beta flagi nadpisuje ukryty ekran „Funkcje eksperymentalne”
  (`features/experimental/presentation/experimental_features_screen.dart`);
  nadpisania w `shared_preferences` (`FeatureFlagOverridesStore`, klucz
  `feature_flag_overrides.v1`). W prod liczą się tylko wartości domyślne
  (`AppFlavor.allowsFlagOverrides`). Flaga niedostępna we flavorze
  (`devOnly`) jest zawsze wyłączona (`FeatureFlags.restrictTo`).
- `FeatureFlagsNotifier` (`core/config/config_providers.dart`) wystawia
  wynik jako provider Riverpod (ADR [0003](0003-riverpod-state-management.md)).

## Konsekwencje

- Pozytywne: brak usługi zdalnej i brak sieci poza LAN; flagi są typowane i
  testowane; wydanie prod nie ma ukrytych przełączników (zgodnie z
  Guideline 2.3.1).
- Negatywne: zmiana wartości w prod wymaga nowego wydania (wyłącznikiem
  awaryjnym jest staged rollout, `docs/release-runbook.md`). Scalenie z
  sondami funkcji (§16) jeszcze nie istnieje; do M3 decydują same flagi.
