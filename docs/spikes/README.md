# Spike'i M0: wyniki

Spike'i ryzyka z planu (`docs/flutter-app-plan.md`, M0, tabela spike'ów).
Każdy wynik podaje komendę albo test, który go dał. Wszystkie lokalne spike'i
biegły na stosie kontraktowym (`contract/compose.contract.yml`) przeciw
niezmienionemu backendowi `8be59cd`; stosy zostały usunięte (`-Down`), a
`git -C C:\home-energy-poc status --porcelain` jest pusty.

| Spike | Wynik | Status |
|---|---|---|
| [S1 Auth przez ciasteczko](s1-auth-cookie.md) | 50 rotacji OK; podwójny refresh → `AUTH_REFRESH_TOKEN_REUSED` i unieważnienie sesji; śmierć procesu przed zapisem → jedno wymuszone logowanie; test kontraktowy refreshu zielony | Zamknięty |
| S2 Cleartext i sieć lokalna | – | **Oczekuje: wymaga fizycznych telefonów** (iPhone, Android 16 z flagą ochrony sieci lokalnej); do sprawdzenia: prośba `NEARBY_WIFI_DEVICES` i przepływ odmowy, komunikat iOS o sieci lokalnej, zachowanie po zmianie Wi-Fi |
| S3 `.local` | – | **Oczekuje: wymaga fizycznych telefonów** (iOS, Android 10/13/14/15, 2 producentów); zapasowy resolver mDNS jest zaimplementowany za flagą `mdnsFallback` (domyślnie wyłączoną), o jej włączeniu rozstrzygnie ten wynik ([ADR 0015](../decisions/0015-network-change-no-write-replay.md)) |
| [S4 Conditional GET](s4-conditional-get.md) | Słaby ETag i 304 na `/devices` i `/devices/:id`; ETag zmienia się co 30 s przez odpytanie legacy | Zamknięty: 304 tak |
| [S5 Fixture'y i osobliwości](s5-fixtures-quirks.md) | Kształt control-strategy (Swagger błędny), `initializedAt` stabilne, `configurationVersion` +2/min bez harmonogramów, `communicationMode` odróżnia GI Edge | Zamknięty; klucze `diagnostics` GI Edge tylko z kodu (sprzęt) |
| [S6 Urządzenie fake](s6-fake-device.md) | GO: provisioning bez proxy, ONLINE mimo 404 `/gi-provision`, przełącznik w obie strony | Zamknięty |
| [S7 Zegar harmonogramów](s7-schedule-clock.md) | UTC w obu stosach Docker; granica okna liczona w UTC | Zamknięty dla Docker; Pi: wniosek z konfiguracji, pomiar na sprzęcie |
| [S8 Stos kontraktowy](s8-contract-stack.md) | Zielony bring-up obok stosu dev, Swagger dostępny, port efemeryczny | Zamknięty lokalnie; runner Linux GitHub otwarty |

## Jak uruchomić stos i testy spike'ów

```powershell
cd C:\home-energy-mobile
$env:PATH = "$env:USERPROFILE\fvm\versions\3.50.0\bin;$env:PATH"   # seeder wymaga Dart 3.14
.\tools\dev-up.ps1 -Contract -RunId spikes -Seed                   # wypisuje GI_CORE_URL, FAKE_ESPHOME_URL
cd packages\gi_core_api
$env:GI_CORE_URL = 'http://127.0.0.1:<port>'; $env:FAKE_ESPHOME_URL = 'http://127.0.0.1:<port>'
dart test -t contract -r expanded test/contract/session_rotation_contract_test.dart   # S1
dart test -t contract -r expanded test/contract/core_quirks_contract_test.dart        # S4, S5
cd ..\..
python -I -X utf8 spikes/core_probe.py $env:GI_CORE_URL timeline --seconds 200        # S4/S5
python -I -X utf8 spikes/core_probe.py $env:GI_CORE_URL window                         # S7
.\tools\dev-up.ps1 -Contract -RunId spikes -Down
```

Nowe testy mają tag `contract`, więc przebieg jednostkowy
(`dart test -x contract`) ich nie uruchamia. Pliki są zarejestrowane w
regule pokrycia katalogu (`test/catalog_coverage_test.dart`).
`spikes/core_probe.py` to skrypt pomocniczy (biblioteka standardowa
Pythona) do osi czasu i jednorazowych obserwacji; komendy `schedule`,
`window` i `weather` zapisują dane, a `ratelimit` zużywa okno logowania,
więc tylko na stosie kontraktowym: każda z nich najpierw szuka urządzenia
`fake-esphome` i bez niego kończy się błędem (stos dev go nie ma).

**Uwaga:** `tools/dev-up.ps1 -Seed` woła `dart` z `PATH`. Ze starszym
globalnym SDK seeder się nie kompiluje (primary constructors, Dart 3.14);
stos wtedy działa, ale bez danych. Stąd linia z `PATH` powyżej (albo osobne
`fvm dart run tools/seed_core.dart --base-url <GI_CORE_URL> --init --yes`).

## Odpowiedzi na pytania z §24

| § 24 | Pytanie | Odpowiedź | Źródło |
|---|---|---|---|
| 2 | Czy target `production` wystawia `/docs-json` przy `SWAGGER_ENABLED=true` i czy mosquitto local-only wystarcza? | **Tak i tak.** `GET /docs-json` → 200 (112 887 bajtów, ten sam rozmiar w S5); Core startuje z `listener 1883 127.0.0.1`. MQTT GI Edge jest wyłączone bez `MQTT_CORE_PASSWORD`. | [S8](s8-contract-stack.md), [S5](s5-fixtures-quirks.md) |
| 4 | Klucze `diagnostics` dla `currentState`/`activeFaults` i `relayNCommanded` | `diagnostics.currentState` (string → `currentState` na liście), `diagnostics.activeFaults` (tablica → `activeFaultCount`), `diagnostics.relayN.commanded` → encja `diagnostics.relay{N}Commanded`. **Z kodu backendu**; na żywo tylko legacy (`diagnostics: null`, `currentState: null`, `activeFaultCount: 0`). Potwierdzenie GI Edge: lista sprzętowa. | [S5](s5-fixtures-quirks.md#klucze-diagnostics-currentstate-i-usterki-24-p-4) |
| 5 | Czy `/devices`, `/devices/:id` zwracają ETag i 304? | **Tak**: słaby ETag Expressa, 304 z pustym ciałem; ETag zmienia się co 30 s dla urządzeń legacy. | [S4](s4-conditional-get.md) |
| 6 | Czy 429 zawiera `Retry-After`? | **Tak**, w sekundach (60 przy natychmiastowym przekroczeniu, 47 w S8); odpowiedzi logowania mają też `X-RateLimit-Limit/Remaining/Reset`. Limit liczy także nieudane logowania. | [S1](s1-auth-cookie.md#limity-żądań), [S8](s8-contract-stack.md) |
| 7 | Czy `initializedAt` jest stabilne po `PATCH /settings/system`? | **Tak** (zmiana `deviceName` i `timezone`, `initializedAt` bez zmian). | [S5](s5-fixtures-quirks.md#initializedat-po-patch-settingssystem-24-p-7) |
| 8 | Strefa czasowa procesu gi-core na Pi i w dev | **UTC** w dev i w stosie kontraktowym (`docker exec … date`, brak `TZ`), okno harmonogramu przełącza się według UTC. Pi: UTC wynika z konfiguracji deploy (brak `TZ`, `node:22-alpine`), bez pomiaru. | [S7](s7-schedule-clock.md) |
| 10 | Czy pogoda i PV w Core dev działają przez `HTTP_PROXY` bez relay? | **Częściowo.** Stos kontraktowy (bez proxy): bez lokalizacji `weather/current` 503, `pv/forecast` 400; po ustawieniu lokalizacji pogoda 200 (Core łączy się bezpośrednio), PV dalej 400 bez mocy instalacji. Stos dev nie był sprawdzany (wymagałby zapisu w danych dewelopera). | [S5](s5-fixtures-quirks.md#pogoda-i-pv-bez-proxy-24-p-10) |
| 11 | Czy `status` z listy przyjmuje wartości poza ONLINE/OFFLINE (np. STALE)? | `status` to `ONLINE`/`OFFLINE`/`UNKNOWN`/`PROVISIONING`/`UPDATING`/`ERROR` (zaobserwowane `ONLINE` i `UNKNOWN`); **`STALE` jest tylko w `connectivityState`** (5 min / 15 min). | [S5](s5-fixtures-quirks.md#wartości-status-na-liście-24-p-11) |

Pozostałe punkty §24: 1 (źródło ref) rozstrzygnięty w planie, dostęp CI do
repo backendu otwarty ([S8](s8-contract-stack.md)); 3 częściowo (pole
`communicationMode`, [S5](s5-fixtures-quirks.md)), heartbeat GI Edge na
sprzęcie; 9 (`/appliance/updates/status`) i 12 (terminy Androida/Play) poza
zakresem tych spike'ów; 13 dotyczy wariantu relay (D20), nieużywanego.

## Wpływ na plan

- **L16** jest silniejsze, niż opisuje plan: `configurationVersion` rośnie
  co 30 s dla każdego urządzenia legacy ze strategią, także bez
  harmonogramów ([S5](s5-fixtures-quirks.md)). Porównywanie wartości bazowych
  (§12.5) jest jedyną poprawną drogą.
- **M3 ETag**: technicznie możliwy, mały zysk ([S4](s4-conditional-get.md)).
- **D8**: zegar harmonogramów domyślnie UTC ([S7](s7-schedule-clock.md)).
- **§7.4**: bez zmian ([S1](s1-auth-cookie.md)).
