# Spike S5: fixture'y i osobliwości GI Core

Data: 2026-11-19. Backend: `8be59cd`. Stosy kontraktowe `s1457`, `s1v2`,
`s7w` (usunięte), zaseedowane `tools/seed_core.dart --init --yes` (konta
ADMIN/USER, dwa pokoje, trzy urządzenia ręczne, urządzenie fake z rolami
encji i strategią `MANUAL 55/4`).

**Wynik:** pytania S5 zamknięte lub opisane poniżej; jedno (klucze
`diagnostics` GI Edge) da się potwierdzić tylko na sprzęcie.

## Jak powtórzyć

```powershell
# stos jak w S1: .\tools\dev-up.ps1 -Contract -RunId s5 -Seed (SDK z FVM na PATH)
cd packages\gi_core_api
$env:GI_CORE_URL = 'http://127.0.0.1:<port>'; $env:FAKE_ESPHOME_URL = 'http://127.0.0.1:<port>'
dart test -t contract -r expanded test/contract/core_quirks_contract_test.dart -N "S5"
dart test -t contract test/contract/devices_contract_test.dart
cd ..\..
python -I -X utf8 spikes/core_probe.py $env:GI_CORE_URL statuses
python -I -X utf8 spikes/core_probe.py $env:GI_CORE_URL timeline --seconds 200
python -I -X utf8 spikes/core_probe.py $env:GI_CORE_URL schedule --seconds 150
python -I -X utf8 spikes/core_probe.py $env:GI_CORE_URL weather
curl -s $env:GI_CORE_URL/docs-json -o docs.json   # deklaracja Swaggera
```

`schedule` i `weather` zapisują dane (harmonogram, lokalizacja domu): tylko
na stosie kontraktowym.

## Kształt control-strategy

- `GET /devices/:id` zawiera `controlStrategy` (efektywna) i
  `baseControlStrategy` (ręczna), każda dokładnie z kluczami
  `targetTemperatureCelsius`, `hysteresisCelsius`, `mode`, oraz liczbowe
  `configurationVersion` (test S5 „the detail carries both strategies…”).
- `PATCH /devices/:id/control-strategy` odpowiada 200
  `{controlStrategy, baseControlStrategy, configurationVersion}` (test
  `devices_contract_test.dart` „control-strategy answers with three keys, not
  the DTO” i [S6](s6-fake-device.md)).
- Swagger (`/docs-json`, operacja `DevicesController_updateControlStrategy`)
  deklaruje odpowiedź 200 jako `ControlStrategyDto`
  (`{targetTemperatureCelsius, hysteresisCelsius, mode}`): **deklaracja jest
  błędna**, co potwierdza §6.1 i ADR [0002](../decisions/0002-hand-written-api-client.md).
- Harmonogram, którego okno trwa, podmienia w `controlStrategy` tylko
  `targetTemperatureCelsius` i `hysteresisCelsius`; `mode` zostaje z
  `baseControlStrategy` (zmierzone w [S7](s7-schedule-clock.md): `MANUAL 55/4`
  → `MANUAL 40/2` → `MANUAL 55/4`).

## `initializedAt` po `PATCH /settings/system` (§24 p. 7)

`PATCH /settings/system {deviceName: "<nazwa> S5", timezone:
"America/New_York"}` jako ADMIN → 200 `{deviceName, locale, timezone}`.
`GET /setup/status` przed i po: `initializedAt` **identyczne**
(`2026-11-19 04:41:22.501Z` w `s1457`, `05:03:35.777Z` w `s7w`), `deviceName`
i `timezone` zmienione. Test przywraca poprzednie wartości. Kod: `updateSystem`
robi `upsert` tylko z polami DTO (`settings.service.ts`), nie dotyka
`initializedAt`.

Wniosek: odcisk po `initializedAt` jest stabilny, a zmiana `deviceName` to
zmiana nazwy, nie inne urządzenie (ADR [0005](../decisions/0005-appliance-fingerprint-single-profile.md)).

## `configurationVersion` rośnie samo (L16)

Pomiar `timeline` (stos `s1457`, urządzenie fake, bez żadnych zmian):

| UTC | `configurationVersion` | `lastSeenAt` |
|---|---|---|
| 04:41:50 | 3 | 04:41:31 |
| 04:42:10 | 4 | 04:42:01 |
| 04:42:40 | 5 | 04:42:31 |
| 04:43:10 | 6 | 04:43:01 |
| 04:43:41 | 7 | 04:43:31 |
| 04:44:11 | 8 | 04:44:01 |
| 04:44:41 | 9 | 04:44:31 |

**+1 co 30 s, czyli +2 na minutę, bez harmonogramów.** Test S5 widzi to w
każdym przebiegu (np. `10 → 13` w 70 s). Z włączonym harmonogramem, którego
okno dziś nie wypada (`schedule`, stos `s1v2`): utworzenie harmonogramu +1,
potem dodatkowo +1 o pełnej minucie (04:59:00 i 05:00:00), razem **+3 na
minutę**; `controlStrategy` bez zmian.

Przyczyna (kod backendu): odpytanie urządzenia legacy co 30 s kończy się
`DeviceApplicationService.update` ze `status: ONLINE`
(`esphome-integration.service.ts:302`), które emituje `DEVICE_UPDATED`
(`device-application.service.ts:83`); `HeatingScheduleReconciliationService.onDeviceUpdated` woła
`reconcile`, a ten przy ustawionej `baseControlStrategy` zawsze zapisuje
strategię z `configurationVersion: { increment: 1 }`
(`heating-schedule-reconciliation.service.ts:51-62, 108, 145`). Cron
`0 * * * * *` dokłada to samo dla urządzeń z włączonym harmonogramem.

Wniosek: L16 jest silniejsze, niż mówi plan („co minutę przez cron”).
Wersja rośnie co 30 s dla każdego urządzenia legacy ze strategią, więc
wykrywanie konfliktu **musi** porównywać wartości bazowe, nigdy wersję (§12.5
już tak mówi). Dla GI Edge nie mierzono: heartbeat zapisuje urządzenie
bezpośrednio przez Prisma (`gi-edge-heartbeat.service.ts:57-70`), więc może
nie emitować `DEVICE_UPDATED`.

## Klucze `diagnostics`, `currentState` i usterki (§24 p. 4)

Zmierzone (urządzenie legacy): `GET /devices/:id` → `diagnostics: null`;
lista → `currentState: null`, `activeFaultCount: 0` (test S5
„communicationMode tells GI Edge from legacy ESPHome”, `statuses`).

Dla GI Edge tylko z kodu (nie da się wytworzyć na stosie kontraktowym:
heartbeat wymaga podpisu HMAC urządzenia albo MQTT z hasłem, a MQTT jest tam
wyłączony, zob. [S8](s8-contract-stack.md)):

- `diagnostics` to surowy JSON ostatniego heartbeatu; opis pola w
  `device.dto.ts:472` wymienia `currentState`, `activeFaults`,
  `latchedFaults`, `safetyInterlockActive`, `wifi` (rssi, ip), `bootCount`,
  `resetReason`, `rebootLoopDetected` i odczyty przekaźników i czujników;
- lista: `currentState` = `diagnostics.currentState`, gdy jest stringiem;
  `activeFaultCount` = długość tablicy `diagnostics.activeFaults`, inaczej 0
  (`prisma-device.mapper.ts:20-46`);
- `relayNCommanded`: heartbeat z `diagnostics.relayN.commanded` (boolean)
  tworzy encję o `externalEntityId` `diagnostics.relay{N}Commanded`
  (`gi-edge-heartbeat.service.ts:415-431`).

Modele klienta już to odzwierciedlają (`DeviceDiagnostics.currentState` i
`DeviceDiagnostics.activeFaultCount` w `device_detail.dart`;
`DeviceListItem.currentState` i `activeFaultCount`). Potwierdzenie na prawdziwym sterowniku zostaje na
liście sprzętowej (§17.1); do tego czasu fixture GI Edge jest syntetyczny
(`MockCoreAdapter`, `communicationMode: GI_EDGE_V1`).

## Pole odróżniające GI_EDGE od LEGACY (§24 p. 3, część)

`communicationMode` jest na liście i w szczegółach (`LEGACY_ESPHOME`,
`GI_EDGE_V1`, `SIMULATION`, `REPLAY`). Zmierzone: wszystkie 4 urządzenia
stosu kontraktowego mają `LEGACY_ESPHOME`; urządzenie fake zostaje legacy
mimo `POST /gi-provision` (S6). Klient: enum `CommunicationMode` z `unknown`.
Czy heartbeat GI Edge aktualizuje `lastSeenAt`: w kodzie tak
(`gi-edge-heartbeat.service.ts:57-60`), na sprzęcie niesprawdzone.

## Wartości `status` na liście (§24 p. 11)

Zmierzone (`statuses`): urządzenie fake `status: ONLINE`,
`connectivityState: ONLINE`; trzy urządzenia utworzone ręcznie, bez kontaktu:
`status: UNKNOWN`, `connectivityState: UNKNOWN`, `lastSeenAt: null`. Kod:
`status` to `DeviceStatus` (`ONLINE`, `OFFLINE`, `UNKNOWN`, `PROVISIONING`,
`UPDATING`, `ERROR`); **`STALE` występuje tylko w `connectivityState`**
(po 5 min bez kontaktu, `OFFLINE` po 15 min; `device-connectivity.ts`).
`STALE` nie był obserwowany na żywo.

## Pogoda i PV bez proxy (§24 p. 10)

Stos kontraktowy (bez `HTTP_PROXY`), `weather`, dwa razy (`s1457`, `s1v2`):

| Żądanie | Przed ustawieniem lokalizacji | Po `PATCH /settings/energy/location` (OWNER) |
|---|---|---|
| `GET /weather/current` | 503 `HTTP_503` „Weather data is not available yet.” | **200** w 0,3–0,4 s (Core łączy się bezpośrednio z dostawcą przez HTTPS) |
| `GET /pv/forecast` | 400 `HTTP_400` „Set house coordinates first.” | 400 „Configure the installed PV peak power first.” |
| `GET /solar/current` | nie sprawdzano | 200 |

Stos dev (`HTTP_PROXY=http://host.docker.internal:3129`,
`NODE_OPTIONS=--use-env-proxy`) **nie był sprawdzany**: wymagałby zapisu
lokalizacji w danych dewelopera. Adresy dostawców są `https://`
(`WEATHER_BASE_URL`, `OPEN_METEO_BASE_URL`), a compose ustawia tylko
`HTTP_PROXY`; czy Node kieruje wtedy HTTPS przez ten proxy, trzeba zmierzyć.
Dla testów pogody (M3) wniosek jest taki, że świeży Core bez lokalizacji
zawsze odpowiada 503 lub 400, niezależnie od sieci, więc testy muszą to
tolerować albo najpierw ustawić lokalizację.

## Fixture'y

Nagrane wcześniej przez `tools/seed_core.dart --fixtures` i używane w testach
jednostkowych: `packages/gi_core_api/test/fixtures/core/8be59cd/`, m.in.

- `DevicesController_get/fake_esphome.json` (urządzenie fake, legacy, z
  rolami i strategią, `diagnostics: null`) i `no_room_no_entities.json`;
- `DevicesController_list/seeded.json` (uwaga: nagrany bez urządzenia fake,
  trzy urządzenia `UNKNOWN`);
- `SettingsController_getSystem/ok.json`, `SetupController_getStatus/{initialized,uninitialized}.json`;
- `AuthController_{login,refresh,getMe,listSessions,logout}/…`,
  `UsersController_{getProfile,changePassword}/…`, `_unrouted/error_route_not_found.json`.

W tym spike'u **nie nagrywano nowych plików** (zestaw MVP jest kompletny,
reguła pokrycia katalogu przechodzi). Odpowiedzi 304, `PATCH
/settings/system` i `PATCH …/control-strategy` są sprawdzane testami na żywo,
bez fixture'ów, bo nie ma ich w katalogu MVP. Ponowne nagranie:
`fvm dart run tools/seed_core.dart --base-url <GI_CORE_URL> --allow-initialized --fixtures [--overwrite-fixtures]`.
