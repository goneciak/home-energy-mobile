# Funkcje i zasady działania

# Funkcje M2: sterowanie ogrzewaniem

Sterowanie jest krytyczne dla bezpieczeństwa (plan §12). Zasady: żadnego
optymistycznego UI dla stanu przełącznika, żadnego kolejkowania zapisów
offline, żadnych ponowień zapisów, żaden tekst nie twierdzi, że przekaźnik
fizycznie się przełączył. Mapa reguł → kod → testy:
[`docs/safety-review.md`](safety-review.md); semantyka potwierdzeń:
ADR [0009](decisions/0009-switch-confirmation-semantics.md).

- **Przełączniki** (`PUT /devices/:id/entities/:entityId/state`): ON z
  arkuszem konsekwencji, OFF bez potwierdzenia. LEGACY_ESPHOME: „Urządzenie
  potwierdziło polecenie”; GI_EDGE_V1: „Zlecono · czeka na potwierdzenie”
  do heartbeatu po `confirmedAt` (30 s). Przekaźniki kotła i pompy są tylko
  do odczytu.
- **Wstrzymanie i wznowienie ogrzewania** (`PATCH /devices/:id
  {heatingSuspended}`): wstrzymanie przytrzymaniem (~600 ms, także akcja
  czytnika ekranu), dostępne nawet na nieaktualnych danych; wznowienie z
  arkuszem konsekwencji („Kocioł może się włączyć w ciągu ~30 s”).
- **Nastawa** (`PATCH /devices/:id/control-strategy`): cel 5–80 °C co
  0,5 °C, histereza 1–20, tryb AUTO/OFF/MANUAL; ponowny odczyt i wykrywanie
  konfliktu po wartościach tuż przed zapisem.
- **Blokady** (`SafetyPolicy`): rola, nieaktualne dane (ostrzej niż Core),
  wstrzymanie (tylko ON), zatrzaśnięta usterka FAULT/SAFE_MODE (tylko ON),
  encja wyłączona, niedostępna lub niezapisywalna. Każda blokada ma tekst z
  powodem.
- **Ustawienia:** język aplikacji, informacje o sesji i urządzeniu,
  wylogowanie.

## Role

| Rola | Podgląd | Przełączniki, wstrzymanie, nastawa |
|---|---|---|
| OWNER, ADMIN | tak | tak |
| USER, SERVICE | tak | nie: kontrolki ukryte, podpowiedź „Zmiany ogrzewania może wprowadzić właściciel.”; serwer i tak zwraca `HTTP_403` |

Uprawnienia wynikają z katalogu endpointów (`Endpoint.roles`), nie z kodu UI
(`HeatingPermission.of`). Konta testowe ADMIN, USER i SERVICE zakłada
seeder (`tools/seed_accounts.example.json`).

## Testy kontraktowe sterowania

```powershell
$env:PATH = "$env:USERPROFILE\fvm\versions\3.50.0\bin;$env:PATH"
.\tools\dev-up.ps1 -Contract -RunId m2 -Seed     # wypisze GI_CORE_URL i FAKE_ESPHOME_URL
cd packages\gi_core_api
$env:GI_CORE_URL='<z dev-up>'; $env:FAKE_ESPHOME_URL='<z dev-up>'
dart test -t contract -j 1 test/contract/control_contract_test.dart
cd ..\..; .\tools\dev-up.ps1 -Contract -RunId m2 -Down
```

Zakres `control_contract_test.dart` i ścieżki nieosiągalne na urządzeniu
fake opisuje sekcja „Testy kontraktowe” niżej. Limit logowania Core to 5 na
minutę.

## Tryb demo

Na ekranie łączenia przycisk „Wypróbuj wersję demonstracyjną” otwiera
przykładowy dom zalogowany jako właściciel, bez sieci i bez Pi (dane z
`app/assets/demo_fixtures/demo_core.json`, w pamięci). Baner „DEMO” jest na
każdym ekranie; „Zakończ demo” czyści dane. Notatka dla recenzentów sklepów:
[`docs/release-runbook.md`](release-runbook.md) §3.1.

# Funkcje M3: codzienny komfort i konto

Stan, zablokowane punkty i korekty kontraktu: plan §20 „Status M3” i §4.2.
Decyzje: ADR [0010](decisions/0010-schedule-clock-utc.md)–[0014](decisions/0014-recovery-code-secure-display.md).

- **Harmonogramy** (`/devices/:id/schedules`; zapis OWNER/ADMIN): lista,
  włączanie, tworzenie (201), edycja, usuwanie (204). Czasy w UTC, bo tak
  liczy Core, z drugim czasem domu; dni przez `ApiWeekday`; aktywny
  harmonogram wyliczany przez `ScheduleClock` z etykietą „wywnioskowane”;
  ostrzeżenie o nakładaniu się okien tylko po stronie klienta. Edycja w czasie
  domu za flagą `scheduleClockConversion`.
- **Pogoda, słońce, PV, plan grzania PV:** 503 pogody i 400 słońca lub
  prognozy PV to „brak danych / nie skonfigurowano”; 500 prognozy PV
  (awaria Open-Meteo) też. Ikony met.no jak w GI UI.
- **Historia encji:** 1 h, 6 h, 24 h, 7 d; wykres schodkowy z LTTB w
  izolacie; „Pokaż jako tabelę” dla czytników ekranu.
- **Uwaga** (wyliczana z `GET /devices`), snapshot offline, ETag za flagą
  `conditionalGet` (domyślnie wyłączony).
- **Konto:** profil i język zapisywany na serwerze (`PATCH /users/me/profile`),
  zmiana hasła, sesje z oznaczeniem „ten telefon”, odwołanie sesji,
  wylogowanie wszędzie (także tu), reset hasła kodem odzyskiwania z ekranu
  logowania, regeneracja kodu z ochroną ekranu i schowka. Po zalogowaniu
  aplikacja proponuje przegląd innych sesji, po resecie nowy kod.
- **Sondowanie funkcji** (§16): funkcja znika tylko po `HTTP_404` trasy.

Tryb demo obsługuje wszystkie ekrany M3: harmonogramy są stanowe (CRUD z
rekoncyliacją `controlStrategy`), historia ma syntetyczny dziennik zmian z 7
dni, a pogoda, słońce, PV, sesje, regeneracja, reset i profil mają dane w
`app/assets/demo_fixtures/demo_core.json`. Zmiana hasła w demo zwraca 200
`{revokedSessions}` jak Core.

## Testy kontraktowe M3

```powershell
$env:PATH = "$env:USERPROFILE\fvm\versions\3.50.0\bin;$env:PATH"
.\tools\dev-up.ps1 -Contract -RunId m3 -Seed
cd packages\gi_core_api
$env:GI_CORE_URL='<z dev-up>'; $env:FAKE_ESPHOME_URL='<z dev-up>'
dart test -t contract -j 1 test/contract/schedules_contract_test.dart test/contract/environment_history_contract_test.dart test/contract/account_contract_test.dart test/contract/capability_probe_contract_test.dart
cd ..\..; .\tools\dev-up.ps1 -Contract -RunId m3 -Down
```

Stos kontraktowy nie ma lokalizacji domu ani PV, więc pogoda (503), słońce i
prognoza PV (400) są testowane tylko ścieżką błędu; kształty 200 pochodzą z
fixture'ów `*_handwritten`. Reset hasła ma limit 5 na 15 minut.

## Benchmark historii 7 d

```powershell
cd app
flutter test test/features/history/lttb_benchmark_test.dart      # host, w CI
# fizyczny Android, build profile (budżet ≤ 3 s, plan §20 Exit M3):
flutter drive --profile --flavor dev --dart-define-from-file=config/dev.json `
  --driver=test_driver/integration_test.dart `
  --target=integration_test/perf/history_7d_benchmark_test.dart -d <id>
```

Wynik z fizycznego telefonu średniej klasy nie jest jeszcze zebrany.

