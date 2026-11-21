# 0006. Sekrety w lokalnym secure storage; access token zapisywany (D3)

- **Status:** Przyjęta (M0). D3 = „Tak” jest wartością proponowaną planu,
  zaimplementowaną; czeka na potwierdzenie właściciela
  ([decyzje](store-and-product-decisions.md)).
- **Data:** 2026-11-19
- **Plan:** §7.1, §7.4, §8.3, §19.7 (prywatność), D3

## Kontekst

Ciasteczko refresh daje 30-dniową sesję, a access token 15 minut dostępu.
Oba muszą przetrwać restart aplikacji, nie mogą trafić do kopii zapasowych
ani na inne urządzenie i nie mogą wyciec do logów. Zimny start w ciągu 15
minut od ostatniego użycia nie powinien zużywać rotacji refresh (każda
rotacja to okno ryzyka REUSED, ADR [0001](0001-cookie-refresh.md)).

## Decyzja

- `SecureTokenVault` (`app/lib/src/features/auth/data/secure_token_vault.dart`)
  na `flutter_secure_storage`, klucze per profil: `p/<profileId>/rt`
  (ciasteczko z `generation` i `absoluteExpiry`) i `p/<profileId>/at`
  (access token z wygaśnięciem według zegara ściennego, D3).
- iOS: `KeychainAccessibility.first_unlock_this_device` (bez synchronizacji z
  iCloud i bez przywracania na innym urządzeniu,
  `core/platform/platform_providers.dart`). Android: `allowBackup="false"`
  i `dataExtractionRules`.
- `TokenVault.read` nigdy nie rzuca: `VaultPresent` / `VaultAbsent(wiped)` /
  `VaultUnavailable`. Pojedyncza awaria Keystore/Keychain nie kasuje sesji;
  dopiero kolejne porażki albo nieczytelny wpis (`vault_read_failures.dart`).
- Zapisany access token jest używany przy zimnym starcie, gdy zostało mu
  ponad 30 s (`AuthSessionManager.persistedTokenMargin`), i dopiero po
  sprawdzeniu odcisku urządzenia (ADR [0005](0005-appliance-fingerprint-single-profile.md)).
  W trakcie działania liczy się krótszy z czasów: monotoniczny i ścienny.
  Token jest usuwany przy wylogowaniu, utracie sesji, innym lub
  zresetowanym urządzeniu; `toString` go nie drukuje.
- Hasło nigdy nie jest zapisywane. Znacznik reinstalacji
  (`reinstall_marker.dart`) czyści pozostałości `p/*` z Keychain po
  reinstalacji na iOS.
- Profil, e-mail ostatniego użytkownika (do podpowiedzi logowania) i flagi
  trzymamy w `shared_preferences` (`SharedPreferencesWithCache` z allow-listą
  `appPreferenceKeys` w `app/lib/src/app/preference_keys.dart`, używaną przez
  `app/lib/src/app/bootstrap.dart`; nowy klucz trzeba tam dopisać); żadnych
  sekretów.

## Konsekwencje

- Pozytywne: zimny start w ciągu 15 minut nie wykonuje refreshu; sekrety
  zostają na urządzeniu; wszystkie gałęzie `VaultResult` i D3 mają testy
  jednostkowe (`auth_session_manager_test.dart`, grupa „persisted access token
  (D3)”, oraz testy `SecureTokenVault` w aplikacji).
- Negatywne: zapisany access token to drugi sekret w Keychain/Keystore (jest
  ważny maksymalnie 15 minut). Jeśli właściciel odrzuci D3, wystarczy nie
  zapisywać tokenu: `TokenVault.writeAccessToken`/`readAccessToken` mają
  jednego użytkownika.
