# Spike S6: urządzenie fake w stosie kontraktowym

Data: 2026-11-19. Backend: `8be59cd` (`contract/backend.lock`), Docker Desktop
na Windows 11, Compose v5.7.0. Stos: `contract/compose.contract.yml`, urządzenie:
`tools/fake_esphome` (serwer `dart:io`, obraz `scratch` + runtime Dart, 16,6 MB).

**Wynik: GO.** Testy z urządzeniem fake biegną w stosie kontraktowym; fallback
na same fixture'y i listę sprzętową nie jest potrzebny.

## Co emuluje fake

Endpointy, które GI Core faktycznie wywołuje
(`esphome-http.client.ts`, `gi-edge-auto-activation.service.ts`). To API
firmware GI (`/api/v1/...`), a nie klasyczny `web_server` ESPHome:

| Żądanie Core | Odpowiedź fake |
|---|---|
| `GET /api/v1/device` | manifest `schemaVersion "1.0"`: 1 przekaźnik (`heating_relay`, switch, zapisywalny), 1 czujnik (`supply_temperature`, `deviceClass: temperature`, 45,5 °C) |
| `GET /api/v1/status` | `{status:{availability:"online"}, diagnostics:{uptimeSeconds}}` |
| `GET /api/v1/events?fromId=&limit=` | pusta strona dziennika |
| `POST /api/v1/entities/heating_relay/state?state=on\|off` | `{entity:{key, state, available:true}}`, stan zapamiętany |
| `POST /gi-provision` | **404** |

Dodatkowo klasyczne trasy ESPHome (`/switch/heating_relay[/turn_on|turn_off|toggle]`,
`/sensor/supply_temperature`) na tym samym stanie oraz `GET /fake/state`
(fizyczny stan przekaźnika, log poleceń, liczba prób `/gi-provision`) dla testów.

## Adresowanie

- Core akceptuje tylko port 80 i adresy rozwiązujące się wyłącznie do
  prywatnego IPv4 (`parseEndpoint`, `assertAllowedAddress`). Host
  `fake-esphome` rozwiązuje się przez DNS Dockera do adresu z sieci projektu
  (zmierzone: `172.20.0.2`), więc przechodzi.
- Bez proxy: w `contract.env` nie ma `HTTP_PROXY`/`NODE_OPTIONS`, Core łączy się
  bezpośrednio. Relay (`lan-http-proxy.mjs`) nie jest potrzebny.
- **mDNS nie jest używane.** Fake nie ogłasza `_esphomelib._tcp`;
  `GET /integrations/esphome/discovered` zwrócił `[]`. Seeder idzie ścieżką
  ręcznego hosta (`POST /integrations/esphome/discover {host: "fake-esphome"}`),
  tą samą, na którą backend sam spada w Dockerze
  (`esphome-mdns-discovery.service.ts`).

## Zmierzony przebieg (seeder, kroki 5-7)

1. `POST /integrations/esphome/discover {host:"fake-esphome"}` → **201**, sesja
   `DISCOVERED` (identity: `externalId gi-fake-esphome-01`, `ip "fake-esphome"`).
2. `POST /provisioning/:id/claim` → **201** (Swagger deklaruje 200).
3. `POST /provisioning/:id/complete {name, type: ESP32, roomId}` → **201**
   (Swagger: 200), urządzenie utworzone, `communicationMode LEGACY_ESPHOME`.
4. `POST /devices/:id/synchronize` → **201**: 2 encje, status `ONLINE`.
5. `PATCH /devices/:id {heatingRelayEntityId, controlTemperatureEntityId}` → 200.
6. `PUT /devices/:id/entities/:entityId/role {roleId}` (`role-boiler`,
   `role-co-supply`) → 200.
7. `PATCH /devices/:id/control-strategy {55, 4, MANUAL}` → 200
   `{controlStrategy, baseControlStrategy, configurationVersion: 2}`.

## ONLINE mimo 404 na `/gi-provision`

- Po `DEVICE_CREATED` Core wysłał `POST http://fake-esphome/gi-provision`,
  dostał 404 i zalogował `rejected auto-activation POST (HTTP 404) -- likely no
  gi_provisioning component compiled in`. `GET /fake/state` →
  `provisioningAttempts: 1`.
- Urządzenie zostaje `LEGACY_ESPHOME`; lista: `status ONLINE`,
  `connectivityState ONLINE`. Odpytywanie legacy (co 30 s) odświeża `lastSeenAt`:
  po ~4 min działania stosu był o 3 s starszy od zegara w chwili odczytu.
- **Szczegóły (`GET /devices/:id`) mówią `needs_configuration`, dopóki któraś
  włączona encja nie ma roli ani funkcji** (`productStatus` w
  `device-details-query.service.ts`). Po przypisaniu ról: `online`. Dlatego
  seeder przypisuje role w kroku 6.

## Przełącznik w obie strony

`PUT /devices/:id/entities/:relayId/state` jako ADMIN (test
`devices_contract_test.dart`):

- `{state:true}` → 200 `{entityId, state:true, availability, confirmedAt}`,
  fake: `relayOn: true`, polecenie `via: gi-api`;
- `{state:false}` → 200, fake: `relayOn: false`;
- encja w szczegółach odzwierciedla stan po każdym kroku (ścieżka legacy w kodzie czeka
  na odpowiedź urządzenia przed zapisem; audytu nie odczytywano);
- USER → 403 `HTTP_403`, przekaźnik się nie ruszył.

Tryb `MANUAL` jest celowy: pętla histerezy Core (`gi-edge-live-heating-control`)
działa tylko w `AUTO` i przy 45,5 °C < 53 °C sama włączyłaby przekaźnik.

## Zachowania backendu zauważone po drodze (bez zmian w backendzie)

- Drugi `discover` tej samej tożsamości przy otwartej sesji kończy się **500
  `INTERNAL_SERVER_ERROR`** (w logu: niezmapowany
  `ProvisioningDomainError PROVISIONING_SESSION_ALREADY_ACTIVE`). Seeder najpierw
  szuka otwartej sesji w `GET /provisioning` i dopiero wtedy wywołuje discover.
- `claim`, `complete` i `synchronize` zwracają 201, a Swagger deklaruje 200.
- Odpowiedź `discover` zagnieżdża domenowy obiekt sesji, nie
  `ProvisioningSessionResponseDto`; seeder odczytuje sesję z listy.
- Każda synchronizacja nadpisuje nazwę urządzenia nazwą z manifestu
  („Fake kotłownia”), więc nazwa podana w `complete` nie zostaje.

## Stos dev (D20)

Nie sprawdzano wariantów (b)/(c) relay dla stosu dev. Na stosie dev seeder
dostaje błąd discover i pomija kroki 5-7 z ostrzeżeniem; testy urządzenia są tam
pomijane.
