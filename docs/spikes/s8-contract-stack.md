# Spike S8: stos kontraktowy obok stosu dev

Data: 2026-11-19. Backend: `8be59cd` (`contract/backend.lock`). Lokalnie:
Windows 11, Docker Desktop, Docker Compose v5.7.0. Runner Linux GitHub: **nie
sprawdzany** (patrz „Otwarte”).

**Wynik lokalnie: zielony bring-up równolegle ze stosem dev**, zielony test
kontraktowy auth (tryb ścisły) na `compose.contract.yml` przy działającym stosie
dev (warunek Exit M0).

## Definicja

`contract/compose.contract.yml`, projekt `gi-mobile-contract-<runId>`:
`postgres` (`timescale/timescaledb:latest-pg17` przypięty digestem, dane na
tmpfs), `mosquitto` (`eclipse-mosquitto:2` przypięty digestem, `listener 1883
127.0.0.1` z inline `configs`), `gi-migrate` (target `migrator`), `gi-core`
(target `production`, `network_mode: service:mosquitto`), `fake-esphome`. Bez
`container_name`, bez stałych portów, bez bind mountów do backendu. Core:
`127.0.0.1::3000` na mosquitto, fake: `127.0.0.1::80`. Środowisko:
`contract/contract.env` (wartości testowe).

## Pomiary

| Co | Wynik |
|---|---|
| Pierwszy `up -d --build --wait` | **91 s** (rc 0). Uwaga: warstwa `npm ci` etapu `dependencies` była już w cache BuildKit z buildu obrazu dev (ten sam Dockerfile i `package*.json`). Budowane od zera: `npm ci --omit=dev` (`production-dependencies`) 34,9 s, `nest build` 26,4 s. Czas w pełni zimnego buildu nieznany. |
| Kolejny `up -d --build --wait` (cache) | **16 s** |
| `tools/dev-up.ps1 -Contract -RunId ps1 -Seed` (up + port + health + seed) | **15,4 s** |
| `tools/dev-up.sh --contract --run-id sh1 --seed` (Git Bash) | **23 s** |
| Pełny `dart test -t contract` (A + B, 20 testów) | ~66 s, w tym ~60 s czekania na limit logowania (`Retry-After`) |

- `--wait` działa z jednorazowym `gi-migrate` (kończy się kodem 0 i nie psuje
  czekania).
- Healthchecki: `start_interval: 1s` w okresie startu, potem co 10 s.

## Obok stosu dev

- Przez cały spike stos dev (`gi-core`, `gi-mosquitto`, `gi-postgres`, port
  3000) działał bez restartu („Up 29 hours”), `/api/v1/health/live` → 200.
- Jednocześnie działały trzy Core: dev `:3000`, `gi-mobile-contract-ps1`
  `:63712` i `gi-mobile-contract-sh1` `:57426`. Brak kolizji nazw, sieci i portów.
- Zestaw kontraktowy uruchomiony na stosie dev (`GI_CORE_URL=http://localhost:3000`)
  przeszedł w trybie ścisłym; testy zmieniające dane były pominięte (brak
  urządzenia fake).

## Port efemeryczny

`docker compose -p <projekt> port mosquitto 3000` zwraca `127.0.0.1:<port>`
(zaobserwowane m.in. 54050, 53999, 60907, 63712, 57426). Skrypty `dev-up`
odczytują go i wypisują `GI_CORE_URL`, `FAKE_ESPHOME_URL`.

## Mosquitto local-only i Swagger (§24 p. 2)

- Mosquitto z `listener 1883 127.0.0.1` wystarcza: log gi-core „Nest
  microservice successfully started”, potem „GI Core listening on 0.0.0.0:3000”.
- Ostrzeżenia `MQTT_CORE_PASSWORD is not set`: subskrybent i publikacja MQTT GI
  Edge są wyłączone. Nie dotyczy urządzenia fake (`LEGACY_ESPHOME`, HTTP).
- Target `production` z `NODE_ENV=production` i `SWAGGER_ENABLED=true`:
  `GET /docs-json` → **200**, 112 887 bajtów. operationId zgadzają się z id
  katalogu (`AuthController_login`, `DevicesController_get`, …).

## Inne fakty zebrane przy okazji

- 429 z logowania ma nagłówek `Retry-After` w sekundach (zaobserwowane `47`)
  (§24 p. 6).
- `docker exec <gi-core> date` → `UTC` (S7, tylko stos kontraktowy).
- `down -v` usuwa kontenery, sieć i anonimowe wolumeny mosquitto
  (`/mosquitto/data`, `/mosquitto/log`; sprawdzone `docker volume ls`). Postgres
  na tmpfs nie tworzy wolumenu.
- Świeży Core: `setup/status` → `initialized:false`; seeder inicjalizuje go
  z `--init --yes`.

## Otwarte (runner Linux GitHub)

- Nie uruchamiano na runnerze. Do sprawdzenia: czas zimnego buildu (pełne
  `npm ci` dwa razy plus pobranie obrazu timescale ~2,3 GB), cache warstw
  między jobami.
- Dostęp CI do repo backendu przy przypiętym SHA (publiczne czy token, §24 p. 1);
  checkout do `$RUNNER_TEMP/backend` i `GI_BACKEND_DIR`.
- Wymagania wersji: `healthcheck.start_interval` (Docker Engine ≥ 25) i
  `configs.content` (Compose ≥ 2.23.1); wersji na `ubuntu-latest` nie
  sprawdzano.
- Lokalnie kontekst buildu zawiera ignorowany przez git
  `apps/gi-core/src/generated/prisma` napisany przez stos dev (`.dockerignore`
  backendu go nie wyklucza, więc `COPY . .` w etapie `build` go kopiuje). Na
  czystym checkoutcie w CI tego katalogu nie będzie; obraz lokalny i z CI mogą
  się w tym różnić. Build lokalny przeszedł.
- Limit logowania (5/min na IP) jest wspólny dla seedera i testów; w CI zestaw
  będzie trwał ~1 min dłużej z powodu jednego czekania na `Retry-After`.
