# `site/`: szkic strony statycznej (polityka prywatności, wsparcie, pomoc)

> **SZKIC (DRAFT). Nie publikować.** Treść nie została zatwierdzona przez
> operatora ani sprawdzona prawnie. Hosting (GitHub Pages, D19) nie jest
> skonfigurowany i w tym pakiecie pracy nie jest włączany.

Plan: M0 pkt 7, §19.7 (Prywatność, Konta użytkowników), D19.

| Plik | Strona |
|---|---|
| [index.md](index.md) | Strona startowa z linkami |
| [privacy.md](privacy.md) | Polityka prywatności aplikacji GI Home |
| [support.md](support.md) | Wsparcie i raport diagnostyczny |
| [account-help.md](account-help.md) | Pomoc dotycząca kont (usuwanie członka, reset hasła, reset fabryczny) |

Strony są w Markdownie, który GitHub Pages (Jekyll) renderuje bez
konfiguracji. Wersja angielska powstanie po zatwierdzeniu polskiej (sklepy
wymagają adresu polityki dla każdego języka opisu albo jednej wersji
dwujęzycznej; do decyzji przy D5).

## Zastępniki do uzupełnienia przed publikacją

| Zastępnik | Znaczenie |
|---|---|
| `[[NAZWA_OPERATORA]]` | Pełna nazwa podmiotu publikującego aplikację (administrator danych w rozumieniu RODO, jeśli dotyczy) |
| `[[ADRES_OPERATORA]]` | Adres siedziby |
| `[[EMAIL_KONTAKTOWY]]` | Adres e-mail wsparcia i spraw prywatności |
| `[[DATA_WEJSCIA_W_ZYCIE]]` | Data obowiązywania polityki |
| `[[OKRES_PRZECHOWYWANIA_RAPORTOW]]` | Jak długo operator przechowuje raporty diagnostyczne otrzymane od użytkowników |

## Skąd pochodzą fakty

Każde stwierdzenie o działaniu aplikacji w `privacy.md` wynika z kodu
(stan z 2026-11-19); przy zmianie kodu trzeba zaktualizować stronę:

| Fakt | Kod |
|---|---|
| Połączenie tylko z urządzeniem GI Home w sieci lokalnej, bez chmury | `packages/gi_core_api/lib/src/http/transport_policy.dart`, `app/lib/src/features/appliance/application/connection_ladder.dart`, ADR [0004](../docs/decisions/0004-lan-transport-policy.md) |
| Brak analityki, reklam, zdalnego raportowania awarii | zależności w `app/pubspec.yaml` (brak SDK analityki i crash reportingu), plan D18 |
| Tokeny w bezpiecznym magazynie systemu, bez kopii zapasowych; hasło nie jest zapisywane | `app/lib/src/features/auth/data/secure_token_vault.dart`, `app/lib/src/core/platform/platform_providers.dart`, `android:allowBackup="false"`, ADR [0006](../docs/decisions/0006-secure-storage-access-token.md) |
| E-mail ostatniego użytkownika i adres urządzenia w ustawieniach aplikacji | `app/lib/src/features/appliance/domain/appliance_profile.dart` |
| Diagnostyka lokalna, zredagowana, wysyłana tylko przez użytkownika | `app/lib/src/features/diagnostics/` (`redaction.dart`, `diagnostic_report.dart`, `diagnostic_report_sharer.dart`) |
| Etykieta telefonu w `User-Agent` | `packages/gi_core_api/lib/src/http/client_info.dart`, `app/lib/src/core/platform/device_identity.dart` |
| Uprawnienia | `app/android/app/src/main/AndroidManifest.xml`, `app/ios/Runner/Info.plist` |
