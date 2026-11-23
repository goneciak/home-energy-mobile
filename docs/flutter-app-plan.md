# GI Home Mobile: plan implementacji aplikacji Flutter (iOS i Android) dla istniejącego, niezmiennego GI Core API

## Streszczenie

Plan opisuje nową aplikację mobilną **GI Home** (Flutter, iOS i Android). Aplikacja łączy się z lokalnym GI Core (NestJS, prefiks `/api/v1`) w sieci domowej. Podział pracy:
- **M2** (ok. 27–33 osobodni): wersja użyteczna dla właściciela, czyli połączenie, logowanie, „czy w domu wszystko OK”, bezpieczne sterowanie ogrzewaniem i przełącznikami, tryb demo. Dystrybucja wewnętrzna.
- **M4** (ok. 48–59 osobodni plus czas kalendarzowy na zamknięte testy i review sklepów): wersja 1.0 do publikacji w sklepach.

**Dwa twarde ograniczenia (mają pierwszeństwo przed ADR-ami, mapami obszarów i wcześniejszymi szkicami):**

1. **Backend nie jest modyfikowany.** W `C:\home-energy-poc` nie zmienia się nic: ani kod GI Core, endpointy, DTO czy adnotacje Swagger, ani ADR-y i dokumentacja, ani compose, infrastruktura czy `.env.example`, ani gi-cloud, gi-relay czy Supervisor. Aplikacja działa z GI Core dokładnie takim, jaki jest dziś. Każda luka backendu dostaje obejście po stronie klienta albo trafia na jawną listę ograniczeń (§21). **Ten plan nie zawiera żadnej listy zmian w backendzie.**
2. **Frontend i backend są w osobnych folderach.** Aplikacja ma własny folder i własne repozytorium git **`C:\home-energy-mobile`**, sąsiadujące z klonem backendu. Nigdy nie jest to `apps/gi-mobile`, submoduł ani symlink. Backend jest konsumowany wyłącznie przez HTTP. Lokalnie backend uruchamia się z jego własnego folderu w Dockerze. Działający Core wymaga już istniejącego, **należącego do repozytorium mobilnego** pliku `C:\home-energy-mobile\tools\backend\compose.override.yml` (§18.2). Aplikacja wskazuje backend konfigurowalnym base URL:
   - emulator Androida: `10.0.2.2`;
   - symulator iOS: `localhost`;
   - telefon fizyczny: IP komputera w LAN.

Uruchomienie backendu z jego folderu nie zmienia żadnych **śledzonych** plików. Kontener deweloperski zapisuje wyłącznie artefakty runtime ignorowane przez git: `dist/`, `src/generated/prisma`, `infrastructure/mosquitto/{data,log}`. Szczegóły w §18.

Fakty oznaczone **(zweryfikowane)** sprawdziłem w plikach lub przez GET na działającym Core. Rzeczy, których nie dało się potwierdzić, są w §24 „Pytania otwarte”.

---

## 0. Decyzje w skrócie

| Temat | Decyzja |
|---|---|
| Repozytorium | `C:\home-energy-mobile`. Folder już istnieje, ale nie jest jeszcze repozytorium git. Zawiera `tools/backend/compose.override.yml` **(zweryfikowane)**. W M0 inicjalizujemy w nim git; folderu nie tworzymy od nowa. Struktura to pub workspace (`app/` i `packages/gi_core_api/`). Katalog narzędzi nazywa się `tools/`, zgodnie z istniejącym plikiem. |
| Uruchamianie backendu lokalnie | `docker compose -f infrastructure/compose.yml -f ..\home-energy-mobile\tools\backend\compose.override.yml up -d postgres mosquitto gi-core` z `C:\home-energy-poc`. Sam bazowy compose **nie** daje działającego Core (§3.9). |
| Testy kontraktowe | **Głównym** sposobem jest należący do repo mobilnego `contract/compose.contract.yml`: własne usługi bez `container_name`, własna sieć, brak stałych portów hosta, build z Dockerfile backendu w trybie tylko do odczytu, migracje przez target `migrator`. |
| Odbiorcy v1 | OWNER i ADMIN mają pełne codzienne sterowanie w LAN. USER i SERVICE dostają uczciwą aplikację tylko do podglądu; kontrolki są **ukryte**. |
| Wiele urządzeń GI Home | v1 obsługuje dokładnie **jeden profil** (domyślna propozycja, D1). |
| Stan | `flutter_riverpod` + `riverpod_generator`. |
| Routing | `go_router` z guardami: profil → status setupu → sesja → `mustChangePassword` → zakładki filtrowane rolą. |
| HTTP | `dio` w czysto-dartowym pakiecie `gi_core_api` z **katalogiem endpointów**. |
| Modele | Ręcznie pisane `freezed` + `json_serializable`, walidowane prawdziwymi odpowiedziami. **Bez generatora OpenAPI.** |
| Refresh token | Ręczna obsługa ciasteczka: parsowanie `Set-Cookie`, wybór ciasteczka po `Path`, zapis w `flutter_secure_storage`, wysyłka `Cookie:` tylko na `POST …/auth/refresh`. Jeden właściciel, pojedynczy lot, zapis przed użyciem (write-ahead). **Nigdy odświeżania w tle.** |
| Czas rzeczywisty | Polling tylko na pierwszym planie, zależny od cyklu życia aplikacji. Bez SSE. |
| Zdalny dostęp | Poza v1 (ograniczenie L22). |
| Powiadomienia | Lista „Uwaga” w aplikacji. Push jest niemożliwy. |
| Pierwsze uruchomienie | Przekazanie do panelu web (`http://<host>/setup`) na Pi. |
| Tryb demo | **Koniec M2.** Widoczne wejście na ekranie łączenia i adapter `HttpClientAdapter` w procesie. |
| Telemetria | Brak SDK. Lokalny bufor diagnostyczny, przechwytywanie błędów Dart i raport wysyłany przez użytkownika. |
| Kompatybilność z Core | Sondowanie funkcji po zalogowaniu i best-effort `runningVersion`; nic nie jest bramkowane wersją (§16). |
| Android | `compileSdk`/`targetSdk` 36, wyrównanie 16 KB, przygotowanie pod ochronę sieci lokalnej (§9.4). |

---

## 1. Cele i zakres

### 1.1 Mierzalne cele powiązane z bramkami

| Cel | Definicja | Pomiar | Bramka |
|---|---|---|---|
| **G1 Rzut oka** | Zimny start do stanu „Kondycja domu” ≤ 5 s. Wznowienie z ostatnim snapshotem ≤ 1 s, z widocznym wiekiem danych. | p90 z 20 uruchomień: Pi w LAN, 10 urządzeń, średniej klasy Android, trace z `integration_test` (timeline). Czas zimnego startu trafia też do lokalnego licznika. | Exit M4 |
| **G2 Bezpieczne sterowanie** | OWNER/ADMIN zmieniają cel, tryb i histerezę, wstrzymują i wznawiają ogrzewanie oraz edytują harmonogramy. UI nigdy nie twierdzi, że przekaźnik fizycznie się przełączył. | Testy widgetów dla każdego stanu, test fixture dla optymistycznego zapisu GI_EDGE (§12.2), przegląd bezpieczeństwa. | Exit M2 |
| **G3 Uczciwość** | Każda wartość ma świeżość. Trzy różne komunikaty: „GI Home nieosiągalny”, „urządzenie offline” i „brak internetu w urządzeniu (pogoda/PV)”. | Testy golden dla każdego stanu. | Exit M2 (pogoda: M3) |
| **G4 Bez niespodziewanych wylogowań** | < 1% sesji kończy się wymuszonym ponownym logowaniem z winy klienta (`AUTH_REFRESH_TOKEN_REUSED`, niejednoznaczny refresh). | Liczniki kodów przyczyn w raportach diagnostycznych wysyłanych co tydzień przez beta-testerów (§8.4). | Exit M4 |
| **G5 Zero śladu w backendzie** | Aplikacja działa z każdym wdrożonym Core i przeżywa aktualizacje, które dodają pola lub wartości enumów. | Nocny test kontraktowy na przypiętym ref i na najnowszym `main`. Reguła CI blokująca `TODO(backend)`. | Każdy kamień milowy |

Dodatkowo w Exit M4: odsetek sesji bez awarii ≥ 99,5% przez ≥ 14 dni bety (Play Android vitals, App Store Connect) oraz budżet obciążenia z §11.

### 1.2 Zakres

| Poziom | Zawartość |
|---|---|
| **MVP wewnętrzne (M0–M2)** | **Łączenie:** adres, sonda, odcisk urządzenia, potwierdzenie. **Setup:** przekazanie do web, gdy urządzenie nie jest zainicjalizowane. **Konto:** logowanie, przywracanie sesji, wylogowanie, wymuszona zmiana hasła (z autofill). **Dom:** kondycja, uwagi, urządzenia wg pokoi, karta ogrzewania. **Szczegóły urządzenia.** **Przełączniki** niegrzewcze. **Ogrzewanie:** strategia efektywna i bazowa, edytor, przytrzymaj-aby-wstrzymać, wznowienie z potwierdzeniem, baner dry-run, PV-boost. **Ustawienia.** **Tryb demo.** **Przechwytywanie błędów i raport diagnostyczny.** |
| **v1.0 sklepy (M3–M4)** | **Harmonogramy** z zegarem harmonogramów. **Pogoda, słońce, PV.** **Plan grzania PV.** **Historia** z tabelą dla czytników ekranu. **Lista „Uwaga”.** **Konto i sesje:** sesje, reset i regeneracja kodu odzyskiwania (z ochroną ekranu), profil i język. **Sieć i kompatybilność:** ETag (jeśli S4 potwierdzi), snapshot offline, sondowanie funkcji. **Wydanie:** dostępność, gotowość do sklepów. |
| **v1.1+** | **Zarządzanie:** automatyzacje (lista, przełącznik, usuwanie), pokoje. **Bezpieczeństwo i łączność:** biometryczna blokada, przeszukiwanie /24, TOFU HTTPS. **Rozszerzenia:** widgety ekranu głównego, opcjonalne lokalne powiadomienia, wiele urządzeń GI Home (jeśli D1 = A). |
| **Później / eksperymentalne** | Spike zdalnego dostępu przez GI Cloud (flaga dev), natywny kreator setupu, onboarding ESPHome, edytor automatyzacji, instalacja aktualizacji urządzenia. |
| **Nigdy w mobile** | `POST /diagnostics/mqtt/publish`, inspektor MQTT, OTA, kreatory okablowania i ról encji, przełącznik dry-run, formularze energii i taryf, `/edge/*`, `POST /weather/refresh`, `/solar/events`, ręczne przełączanie przekaźników kotła i pompy w v1. |

---

## 2. Persony, role i ścieżki

Model ról z PRD (gość, instalator, zakresowe uprawnienia) **nie istnieje w Core**. Obowiązują role `OWNER | ADMIN | USER | SERVICE` (`apps/gi-core/src/common/enums/user-role.enum.ts`).

| Persona | Rola | Obietnica v1 |
|---|---|---|
| Właściciel | OWNER (dokładnie jeden) | Pełne sterowanie codzienne, sesje, kod odzyskiwania |
| Współzarządzający | ADMIN | To samo co OWNER; v1 nie ma funkcji tylko dla właściciela |
| Domownik | USER | Podgląd: Dom, Ogrzewanie (widok), Historia, Pogoda, Profil. Komunikat: „Zmiany ogrzewania może wprowadzić właściciel.” |
| Serwis | SERVICE | Nie jest celem. Widzi interfejs USER, ale katalog pozwala mu czytać `/settings/system` (§4.2). |

Ścieżki projektowe:
1. Poranny rzut oka.
2. „Zimno, podkręć”.
3. „Coś jest nie tak”.
4. Awaryjne wstrzymanie ogrzewania.
5. Korekta harmonogramu.
6. „Co działo się w nocy?”.
7. Zgubiony telefon (Sesje).
8. Zapomniane hasło.
9. Nowy telefon (`gi-home.local` → potwierdzenie → logowanie).
10. **Zmiana użytkownika na tym samym telefonie** (§7.8).

---

## 3. Fakty o backendzie, pod które piszemy (kontrakt)

Działający dev Core `http://localhost:3000` zwraca `GET /api/v1/setup/status` → `{"initialized":false,"initializedAt":null,"deviceName":null,"locale":"pl-PL","timezone":"Europe/Warsaw"}` **(zweryfikowane)**.

### 3.1 Prefiks i Swagger
- Prefiks to `/api/v1` (`apps/gi-core/src/main.ts:41`).
- `SWAGGER_ENABLED` ma domyślnie `true` (`apps/gi-core/src/config/env.validation.ts:53`, **zweryfikowane**). Profil `infrastructure/release` ustawia `false` (`infrastructure/release/gi-core.env.example:9`).
- Compose na Pi nie ustawia tej zmiennej, ale Traefik kieruje na Core tylko `PathPrefix(/api)`, a `/` idzie do gi-ui. Swagger jest więc tam nieosiągalny.
- **Kontrola dryfu specyfikacji korzysta wyłącznie z Core deweloperskiego lub kontraktowego.**

### 3.2 Walidacja
`ValidationPipe({whitelist, forbidNonWhitelisted, transform})` (`main.ts:44-57`). Każde dodatkowe pole kończy się błędem 400 `VALIDATION_FAILED` ze szczegółami w `details`, kluczowanymi ścieżką z kropkami.

### 3.3 Koperta błędu
Format: `{statusCode, code, message, path, requestId, timestamp, details?}` (`common/filters/api-exception.filter.ts`).

| Sytuacja | Kod |
|---|---|
| Brak uprawnień (RBAC) | `HTTP_403` |
| Limit żądań | `HTTP_429` |
| Nieznana trasa | `HTTP_404` (odróżniać od domenowego `RESOURCE_NOT_FOUND`) |
| Część błędów | 500 `INTERNAL_SERVER_ERROR` |

Pole `message` jest po polsku tylko dla kodów z tabeli `common/i18n/api-message.ts`.

### 3.4 Request ID
`X-Request-Id` jest przyjmowany, jeśli pasuje do `^[A-Za-z0-9][A-Za-z0-9._:-]*$` i ma ≤ 128 znaków. Wraca w nagłówku i w polu `requestId` (`common/middleware/request-id.middleware.ts:6-15`).

### 3.5 Auth
- **Access token:** JWT Bearer, domyślnie 900 s. Sesja jest sprawdzana przy każdym żądaniu.
- **Refresh token** ma postać `<uuid>.<43 znaki base64url>` i działa wyłącznie przez ciasteczko:
  - wydawany tylko w `Set-Cookie` przy logowaniu i odświeżaniu (`auth.controller.ts:79-83,131-135,226-235`);
  - czytany tylko z `request.cookies` na `POST /auth/refresh` (`:128-130`), bez body i bez limitu żądań;
  - ścieżka ciasteczka: `/${API_PREFIX}/auth/refresh` (`auth.config.ts:36`);
  - `AUTH_COOKIE_SECURE="false"` w dev (`infrastructure/compose.yml:73`, **zweryfikowane**) i na Pi (`deploy/raspberry-pi/appliance/compose.yml:257`).
- **Rotacja z wykrywaniem ponownego użycia, bez okna łaski.** Ponowne użycie starego tokenu albo przegrany wyścig unieważnia sesję (`auth.service.ts:188-220`).
- **Czas życia i limity:**
  - sesja żyje 30 dni bezwzględnie (`:228-231`);
  - limit 10 sesji z cichym usuwaniem najstarszej (`:85-108`);
  - `/auth/logout` wymaga Bearer;
  - `mustChangePassword` nie jest egzekwowane przez serwer;
  - logowanie: 5 prób na 60 s na IP; `recovery/reset`: 5 na 15 min.
- **Unieważnienie sesji działa natychmiast** (korekta M3): `AuthGuard` sprawdza wiersz sesji przy każdym żądaniu (`auth.guard.ts:46-58`), więc access token odwołanej sesji dostaje od razu 401 `AUTH_SESSION_REVOKED`, a nie dopiero po 900 s.

### 3.6 Domena urządzeń
- **`GET /devices`** (lista) zwraca dla każdego elementu (`device.dto.ts` `DeviceResponseDto` l.84-226; `device-response.mapper.ts:10-20` rozwija cały `device.toSnapshot()`):
  - `status` (UPPERCASE), `connectivityState`, `lastSeenAt`;
  - `activeFaultCount` i `currentState`, parsowane z `diagnostics` (`device.dto.ts:218,225`; `prisma-device.mapper.ts:45,80-81`);
  - `heatingRelayEntityId`, `pumpRelayEntityId`, `heatingSuspended`, `dryRun`.

  **Lista wystarcza więc do rozpoznania urządzeń grzewczych, banera wstrzymania i dry-run.** Nie zawiera encji ani strategii.
- **`GET /devices/:id`** (szczegóły) zwraca:
  - `status` (lowercase, produktowy), `entities[]`;
  - `controlStrategy`, `baseControlStrategy`, `configurationVersion`;
  - `heatingSuspended`, `dryRun`, `pvHeatingConfig`, `pvBoostActive`;
  - `diagnostics` oraz identyfikatory przekaźników.

  **Nie zawiera `currentState` ani `activeFaultCount`.** Odpowiedź jest budowana jawnie w `device-details-query.service.ts:44-89` i nie ma tych pól (**zweryfikowane** grepem).
- **`PATCH /devices/:id/control-strategy`** wymaga wszystkich trzech pól. Zwraca `{controlStrategy, baseControlStrategy, configurationVersion}` (`control-strategy.service.ts:53-59`), a nie zadeklarowany `ControlStrategyDto`.
- **`configurationVersion` rośnie samoistnie.** `@Cron('0 * * * * *')` co minutę wywołuje `reconcile()` dla każdego urządzenia z włączonym harmonogramem. Każde wywołanie zapisuje `configurationVersion: { increment: 1 }`, zarówno w gałęzi „wstrzymane”, jak i w zwykłej, bez sprawdzania, czy coś się zmieniło (`heating-schedule-reconciliation.service.ts:63,108,145`, **zweryfikowane**).
- **Przełącznik:** `PUT /devices/:id/entities/:entityId/state {state}`, tylko OWNER/ADMIN i tylko boolowski SWITCH.

  | Kod | Znaczenie |
  |---|---|
  | 404 `DEVICE_ENTITY_NOT_FOUND` | Encja nie istnieje |
  | 409 `HEATING_SUSPENDED`, 409 `ENTITY_DISABLED` | Sterowanie zablokowane |
  | 422 `ENTITY_NOT_WRITABLE` | Encja tylko do odczytu |
  | 503 `DEVICE_OFFLINE`, 503 `ESPHOME_DEVICE_UNREACHABLE` | Urządzenie nieosiągalne |
  | 502 `ESPHOME_COMMAND_REJECTED`, 502 `ESPHOME_COMMAND_UNCONFIRMED`, 504 `ESPHOME_COMMAND_TIMEOUT` | Brak potwierdzenia |

- **GI_EDGE_V1: zapis optymistyczny.** W `esphome-switch-command.service.ts` po `giEdgeCommands.enqueue(...)` (l.249) Core zapisuje na encji żądaną wartość i `lastSeenAt: requestedAt` (l.281), z wynikiem audytu `REQUESTED` (l.296), **zanim urządzenie cokolwiek zrobi** (**zweryfikowane**). Polecenia nie mają ID.

### 3.7 Progi łączności i ustawienia
- Progi łączności: STALE po 5 min, OFFLINE po 15 min (`domain/services/device-connectivity.ts`). API ich nie udostępnia.
- `GET /settings/system` jest dostępne dla `OWNER, ADMIN, SERVICE` (`settings.controller.ts:60-61`, **zweryfikowane**).

### 3.8 Topologia Pi
- Traefik kieruje `PathPrefix(/api)` na `127.0.0.1:3000`, tylko na porcie :80.
- Avahi publikuje **wyłącznie nazwę hosta** `gi-home.local`.
- Chmura jest domyślnie wyłączona.

Źródło: `deploy/raspberry-pi/appliance/compose.yml`.

### 3.9 Topologia deweloperska: jak naprawdę działa Core na localhost:3000

**Bazowy compose sam w sobie nie daje działającego Core.** Wymaga nakładki należącej do repo mobilnego, `C:\home-energy-mobile\tools\backend\compose.override.yml` (**zweryfikowane**: plik istnieje). Powody (wg nagłówka nakładki i kodu):

1. **MQTT jest zakodowany na sztywno.** Core łączy się z `mqtt://127.0.0.1:1883` (`apps/gi-core/src/main.ts:76`, **zweryfikowane**). We własnym kontenerze nic tam nie nasłuchuje i start zawiesza się przed uruchomieniem HTTP. Nakładka ustawia `network_mode: "service:mosquitto"` z `networks: !reset []` i publikuje port 3000 **na kontenerze mosquitto** (`${GI_CORE_BIND_ADDRESS:-127.0.0.1}:${GI_CORE_PORT:-3000}:3000`).
2. **Bind mount ukrywa klienta Prisma.** `../apps/gi-core:/app` przykrywa wygenerowanego klienta, więc nakładka robi `npx prisma generate` przy starcie.
3. **Bazowa komenda nie migruje.** `npm ci && npm run start:dev` (`infrastructure/compose.yml:87`) nie uruchamia migracji, więc nakładka dodaje `npx prisma migrate deploy`.

Inne istotne fakty (**zweryfikowane** w `infrastructure/compose.yml`):

| Element | Wartość | Konsekwencja |
|---|---|---|
| Stałe nazwy kontenerów | `gi-mosquitto` (l.4), `gi-postgres` (l.35), `gi-core` (l.65), `gi-ui` (l.107) | Dwa projekty compose z tego pliku nie uruchomią się równocześnie |
| Nazwa sieci | stała `gi-home-energy` (l.128-130) | Projekty współdzieliłyby sieć i aliasy |
| Stałe porty hosta | Postgres `5435:5432` (l.43); mosquitto `1883`, `9001` (l.7-8) | Kolizje portów |
| Proxy wyjściowe Core | `NODE_OPTIONS=--use-env-proxy`, `HTTP_PROXY=http://host.docker.internal:3129`, `NO_PROXY=localhost,127.0.0.1,host.docker.internal` (l.76-78) | Patrz §17.3 |
| Hasło Postgres | `POSTGRES_PASSWORD: gi_dev_password` (l.46) | `apps/gi-core/.env.example:3` ma `change_me`, więc się nie zgadza |
| GI UI | przepisuje `/api/*` na `http://gi-core:3000` (l.106,110; `apps/gi-ui/next.config.ts`) | Przy aktywnej nakładce nazwa DNS `gi-core` nie istnieje w sieci, więc przekierowanie GI UI nie działa. Kontener gi-ui nie jest obecnie uruchomiony. |

`infrastructure/lan-http-proxy.mjs` nasłuchuje wyłącznie na `server.listen(3129, '127.0.0.1', …)` (**zweryfikowane**). Ma działać na hoście (`make lan-relay-up`), nie w kontenerze.

---

## 4. Ekrany i endpointy

Ścieżki są względne do `/api/v1`. **R** oznacza wszystkie role, **W** oznacza OWNER/ADMIN (dla pozostałych kontrolki są ukryte).

### 4.1 MVP (M1–M2)

| Ekran / element | Endpoint(y) | Rola | Uwagi |
|---|---|---|---|
| Łączenie: adres, sonda, potwierdzenie | `GET /health/live`; `GET /setup/status` | publiczne | „GI Home „{deviceName ?? 'GI Home'}” · {host}”, „Czy to Twój GI Home?” **przed** wysłaniem danych logowania. Widoczne wejście „Wypróbuj wersję demonstracyjną” (§19.5). |
| Brak inicjalizacji | `GET /setup/status` | publiczne | „Dokończ konfigurację w przeglądarce” otwiera `http://<host>/setup`. **W dev** ten adres nie działa, bo GI UI nie startuje z nakładką; flavor dev pokazuje wskazówkę „zainicjalizuj przez `tools/seed_core.dart --init`”. |
| Logowanie | `POST /auth/login` + `Set-Cookie` | publiczne | 401 `AUTH_INVALID_CREDENTIALS`, 403 `USER_DISABLED` i 429 nigdy nie wywołują refreshu. `AutofillGroup` z `AutofillHints.username`/`password`; po sukcesie `TextInput.finishAutofillContext()`. |
| Przywracanie sesji | `POST /auth/refresh`, `GET /auth/me`, `GET /users/me/profile` | dowolna | §7 |
| Wymuszona zmiana hasła | `POST /users/me/change-password` | dowolna | Egzekwuje guard routera. Hasło 8–256 znaków: mała i wielka litera oraz cyfra. `AutofillHints.newPassword`, więc system proponuje wygenerowane hasło. |
| Dom | `GET /devices?limit=100` (30 s), `GET /rooms`, `GET /devices/:id` **tylko dla widocznych kart ogrzewania** | R | Urządzenie grzewcze to `heatingRelayEntityId != null` **z listy**. Baner wstrzymania i dry-run też z listy. |
| Karta ogrzewania | `GET /devices/:id` (15 s, gdy karta widoczna) | R | Szczegóły dostarczają strategię, encje i diagnostykę. |
| Szczegóły urządzenia | `GET /devices/:id` (5 s; 2 s przez 30–45 s po poleceniu) | R | `currentState` i `activeFaultCount` **pochodzą z elementu listy w cache**. Zapas: defensywne parsowanie `diagnostics.currentState`/`activeFaults` (nazwy kluczy do potwierdzenia fixturem). UI pokazuje źródło i świeżość każdej z tych wartości. |
| Przełącznik | `PUT …/entities/:entityId/state` → `{entityId,state,availability,confirmedAt}` | W | Bez optymizmu (§12.2). Przekaźniki kotła i pompy są tylko do odczytu. |
| Edytor strategii | `PATCH /devices/:id/control-strategy` | W | Odpowiedź dekodowana kształtem runtime. Konflikt wykrywany po wartościach (§12.5). |
| Wstrzymanie / wznowienie | `PATCH /devices/:id {heatingSuspended}` | W | §12.1 |
| Ustawienia | `GET /auth/me`, `POST /auth/logout` | dowolna | Język, informacje o urządzeniu, wskaźnik HTTP, wygaśnięcie sesji, „Zmień użytkownika”, „Wyślij raport diagnostyczny” |

### 4.2 Dodatki v1.0 (M3)

| Element | Endpoint(y) | Rola |
|---|---|---|
| Harmonogramy | `GET /devices/:deviceId/schedules` (model ręczny) | R |
| Zmiany harmonogramów | `POST` → **201** (brak `@HttpCode`), `PATCH` → 200, `DELETE` → 204 `/devices/:deviceId/schedules/:sid` | W |
| Pogoda i słońce | `/weather/current`, `/weather/daily`, `/weather/hourly`: 503 `HTTP_503` oznacza „brak danych”. `/solar/current` bez współrzędnych domu zwraca **400 `HTTP_400`** („Set house coordinates first.”), nie 503 (korekta M3). | R |
| Prognoza PV | `GET /pv/forecast`. Kod 400 `HTTP_400` oznacza „nie skonfigurowano” (brak współrzędnych albo PV), więc karta jest ukryta. Awaria Open-Meteo kończy się **500 `INTERNAL_SERVER_ERROR`** (błąd nieprzechwycony w Core); traktujemy to jak „brak danych”, nie jak awarię aplikacji (korekta M3). | R |
| Plan grzania PV | `GET /devices/:id/pv-heating-plan` | R |
| Historia | `GET /devices/:d/entities/:e/history?from=&to=&limit=` | R |
| Uwaga | wyliczane z `GET /devices` | R |
| Sesje | `GET /auth/sessions`, `DELETE /auth/sessions/:id` (204; odwołanie działa natychmiast), `POST /auth/logout-all` (204; unieważnia **wszystkie** sesje, także bieżącą, więc klient traktuje to jak lokalne wylogowanie) | dowolna |
| Reset hasła | `POST /auth/recovery/reset` → 204. Unieważnia wszystkie sesje użytkownika, ale **nie zużywa i nie rotuje kodu**, więc po resecie aplikacja proponuje regenerację (korekta M3). | publiczne |
| Regeneracja kodu odzyskiwania | `POST /auth/recovery/regenerate` → `{recoveryCode}` | dowolna |
| Profil | `GET`/`PATCH /users/me/profile`, `POST /users/me/change-password` → **200 `{revokedSessions}`** (nie 204; unieważnia pozostałe sesje, bieżąca zostaje; tryb demo poprawiony w M3) | dowolna |
| Strefa czasowa domu | `GET /settings/system` → `{timezone}` | OWNER/ADMIN/SERVICE (o dostępie decyduje katalog). USER dostaje strefę telefonu z etykietą. |
| Wersja Core (best effort) | `GET /appliance/updates/status` | OWNER/ADMIN (§16) |

### 4.3 v1.1+
Automatyzacje (`GET /automations`, `PATCH /automations/:id/enabled`, `DELETE`; W; nigdy nie wywoływane dla USER), pokoje (`POST`/`PATCH /rooms`, `PATCH /devices/:id {roomId}`), plakietka aktualizacji.

### 4.4 Nigdy nie wywoływane
- `/auth/refresh` z body
- SSE `/devices/:id/telemetry`
- `/edge/*`, `/diagnostics/*`
- zapisy `/settings/energy*`
- `POST /setup/initialize` (w aplikacji; dopuszczalne tylko narzędzie seed w dev i kontrakcie)
- `POST /weather/refresh`, `/solar/events`
- `/integrations/*` i `/provisioning*` (poza narzędziem seed)

---

## 5. Architektura

### 5.1 Warstwy
```
presentation   widgety, ekrany, go_router
application    Notifiery Riverpod, orkiestratory pollingu, use case'y, bramki ról can(endpoint), FeatureFlags
domain         czysty Dart: SafetyPolicy, HomeCondition, FreshnessPolicy, ScheduleClock, ConfirmationPolicy
data           repozytoria: mapowanie DTO→domena, last-good + fetchedAt, snapshot, cache ETag
gi_core_api    (osobny pakiet czysto-dartowy) dio, katalog, DTO, konwertery, ApiFailure,
               AuthSessionManager, TransportPolicy, codec Set-Cookie, CapabilityProbe
platform       secure storage (VaultResult), cykl życia, łączność, mDNS (Android), FLAG_SECURE/clipboard
```
`gi_core_api` nie zależy od Fluttera. Testy kontraktowe uruchamia się przez `dart test`.

**Decyzja (M0–M1, tylko odczyt):** modele `gi_core_api` (freezed, niemutowalne, czysty Dart, z tolerancyjnym dekodowaniem §6.4) pełnią rolę modeli domenowych. Warstwa `data` nie mapuje ich na osobne typy; dodaje `fetchedAt` (`Fetched<T>`) i last-good. Logika domenowa (`HomeCondition`, `ControllerStatus`, `FreshnessPolicy`) jest czystym Dartem nad tymi typami. Prezentacja nie interpretuje kodów serwera: teksty błędów daje `core/errors/failure_messages.dart`, a ekrany rozróżniają tylko typy `ApiFailure`, które zmieniają przepływ (np. 404 urządzenia, 429 logowania). Osobne modele domenowe i mapowanie DTO→domena wprowadzamy, gdy wymagają tego zapisy (M2+) albo gdy kształt na ekranie przestaje odpowiadać kształtowi z API.

### 5.2 Pakiety
Dokładne wersje przypinamy w M0, a Flutter stable przez FVM.

| Obszar | Pakiet | Uwagi |
|---|---|---|
| Stan i DI | `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator` | |
| Routing | `go_router` | |
| HTTP | `dio`, `synchronized` | Bez `dio_cookie_manager`/`cookie_jar` (§7.2) |
| Modele | `freezed`, `json_serializable`, `build_runner` | |
| Sekrety | `flutter_secure_storage` (przypięta wersja) | iOS: `first_unlock_this_device`. Android: **domyślny, aktualny szyfr pakietu**, bez przestarzałej flagi `encryptedSharedPreferences` (androidx security-crypto jest przestarzałe). Test migracji z wcześniejszego formatu. |
| Preferencje i pliki | `shared_preferences`, `path_provider` | Pliki w Application Support (§8.3) |
| Różne | `uuid`, `package_info_plus`, `device_info_plus`, `url_launcher`, `connectivity_plus`, `logging`, `share_plus` (raport diagnostyczny) | |
| Aktualizacje | `in_app_update` (Android) | §16 |
| i18n | `flutter_localizations`, `intl`, gen-l10n | |
| Wykresy (M3) | `fl_chart` | Z warstwą Semantics i tabelą alternatywną |
| mDNS Android | `multicast_dns` z MulticastLock | |
| Później | `local_auth`, `flutter_local_notifications`, `workmanager`, `home_widget` | |
| Dev | `very_good_analysis`, `mocktail`, `fake_async`, `http_mock_adapter`, `alchemist`, `integration_test`, `patrol`, `shelf` | |

Kanały platformowe piszemy sami i utrzymujemy je minimalne: `FLAG_SECURE`, wrażliwy schowek, `NSURLIsExcludedFromBackupKey`, MulticastLock.

---

## 6. Strategia klienta API

### 6.1 Dlaczego bez generowania kodu
Wyeksportowana specyfikacja ma poważne braki:
- 72 ze 122 operacji nie ma schematu 2xx;
- 76 nullowalnych stringów jest typowanych jako `object`;
- 11 schematów jest pustych;
- schemat bezpieczeństwa `gi_refresh_token` nie jest zdefiniowany;
- syntetyczny schemat `Object` koliduje z typem w Darcie;
- brakuje typu `integer`;
- odpowiedź `control-strategy` jest zadeklarowana błędnie.

Backendu nie poprawiamy, więc spec służy **wyłącznie** do wykrywania dryfu (§17.5).

**Kolejność zaufania przy pisaniu modeli:**
1. Fixture'y nagrane z Core w Dockerze.
2. Kod serwisów GI Core.
3. Typowane schematy specyfikacji.
4. `apps/gi-ui/src/shared/api/types.ts`, tylko jako wskazówka.

### 6.2 Katalog endpointów
```dart
const devicesDetail = Endpoint(
  id: 'DevicesController_get', method: GET, path: '/devices/{id}',
  roles: {OWNER, ADMIN, USER, SERVICE}, timeout: Timeouts.read,
  idempotent: true, autoRetry: 2, conditional: true);
const systemSettings = Endpoint(
  id: 'SettingsController_getSystem', method: GET, path: '/settings/system',
  roles: {OWNER, ADMIN, SERVICE}, timeout: Timeouts.read, idempotent: true);
```

Katalog steruje:
- bramkowaniem `can()`;
- timeoutami i polityką ponowień;
- filtrem porównywania specyfikacji (`spec_diff`);
- regułą CI „każdy wpis ma test fixture i test kontraktowy”;
- listą sond funkcji (§16).

Z katalogu generujemy plik `docs/backend-contract.md` w repo mobilnym.

### 6.3 DTO żądań
Ręcznie pisane klasy z jawnym `toJson`. Test sprawdza **dokładny zestaw kluczy**. `control-strategy` zawsze wysyła wszystkie trzy pola. Pusty `lastName: ''` oznacza null.

### 6.4 Tolerancyjne dekodowanie
- Każdy enum ma wartość `unknown`.
- Trzy słowniki statusów (`DeviceListStatus` UPPERCASE, `ProductStatus` lowercase, `ConnectivityState`) nigdy nie są łączone.
- Wartość encji to zamknięty typ `EntityValue`.
- `diagnostics` ma defensywne akcesory.
- Decimal: `@NumOrString()`. BigInt jako string.
- Czas: `UtcInstant`, `LocalTimeOfDay`, `HouseLocalDateTime`.
- Nieznane pola są ignorowane w aplikacji, ale tryb ścisły w testach kontraktowych na nich pada.

Błąd dekodowania to `ApiFailure.unexpectedShape(endpointId, requestId, fieldPath)`. Trafia do lokalnego licznika i nigdy nie wywraca aplikacji.

### 6.5 Łańcuch interceptorów
1. **TransportPolicy** (§9.4).
2. **Nagłówki:**
   - `Accept`;
   - `Accept-Language`;
   - `User-Agent: GIHome-Mobile/<ver> (iPhone; iOS 18.1)` lub `(Linux; Android 15; Pixel 8)`: jedyna etykieta urządzenia widoczna w `/auth/sessions`;
   - `X-Request-Id: m-<uuid-hex>`.
3. **Auth:** Bearer, z wyjątkiem `/auth/login`, `/auth/refresh`, `/auth/recovery/reset`, `/setup/*`, `/health/*`. Gdy token wygasa za < 60 s, interceptor czeka na `ensureFresh()`.
4. **Conditional GET**, tylko jeśli S4 potwierdzi 304.
5. **Mapowanie błędów** na `ApiFailure` (§8).
6. **Retry po 401:** jeden refresh i jedno powtórzenie żądania. Powtórzenie POST/PUT/PATCH jest bezpieczne, bo AuthGuard odrzucił żądanie przed handlerem.
7. **Logger:** redaguje `cookie`, `set-cookie` i `authorization` i zapisuje do bufora pierścieniowego.

### 6.6 Timeouty i ponowienia

| Klasa | Connect / receive | Ponowienia |
|---|---|---|
| Domyślny GET | 4 s / 10 s | do 2× z backoffem |
| Pogoda, słońce, PV | 4 s / 20 s | 1× |
| `PUT …/state` | 4 s / 20 s | **nigdy** |
| PATCH / POST / DELETE | 4 s / 15 s | **nigdy** (poza powtórzeniem po 401) |
| `/auth/refresh` | 4 s / 30 s, bez CancelToken | §7.4 |
| Sonda LAN | 1,5 s / 2 s | — |

---

## 7. Auth i sesja

### 7.1 Przechowywanie danych
v1: jeden profil urządzenia i jeden aktywny użytkownik na profil.

| Element | Gdzie | Uwagi |
|---|---|---|
| Ciasteczko refresh `{name, value, path, obtainedAt, absoluteExpiry, generation}` | `flutter_secure_storage`, klucz `p/<profileId>/rt` | iOS `first_unlock_this_device` (bez synchronizacji i kopii iCloud). Android `allowBackup="false"` i `dataExtractionRules`. |
| Access token i jego wygaśnięcie | Pamięć (monotoniczny `Stopwatch`) oraz secure storage z wygaśnięciem według zegara ściennego (D3) | Nigdy nie trafia do logów. |
| `sessionId` | Odczytany (bez weryfikacji) z claimu JWT | Oznaczenie „ten telefon” na liście sesji. |
| Profil `{profileId, label, hosts[], fingerprint, lastUserEmail, lastUserId, scheduleClock}` | `shared_preferences` | Bez sekretów. |
| Hasło | **Nigdy** nie jest zapisywane. | |
| Znacznik reinstalacji | `shared_preferences` | Gdy znacznika brak, czyścimy elementy `p/*` w Keychain. |

**Awarie magazynu.** Odczyt zwraca `VaultResult {present, absent, unavailable}`:
- `absent` → `SessionLost(noToken)`;
- `unavailable`, czyli wyjątek Keystore/Keychain (np. uszkodzenie po aktualizacji OS lub `errSecInteractionNotAllowed` przed pierwszym odblokowaniem):
  - profil zostaje;
  - komunikat „Nie można odczytać danych logowania – spróbuj ponownie”;
  - ponowna próba przy następnym wznowieniu;
  - wyczyszczenie i wymuszenie logowania dopiero po N = 3 kolejnych porażkach albo przy błędzie dekodowania.

  Te gałęzie mają testy jednostkowe w pakiecie testów awarii z M1.

### 7.2 Dlaczego ręczne ciasteczko zamiast cookie jar
- Token musi przetrwać zmianę base URL (`gi-home.local` → IP).
- `cookie_jar` odrzuca ciasteczka `Secure` przez `http`.
- Ciasteczko idzie wyłącznie na ścieżkę refresh, tak jak scope'uje je przeglądarka.
- To świadomy kompromis po stronie klienta (`docs/decisions/0001-cookie-refresh.md` w repo mobilnym), **nie** prośba o zmianę backendu.

### 7.3 Przepływy na drucie

**Logowanie**
```
POST {base}/api/v1/auth/login   {"email":"…","password":"…"}   ← dokładnie te dwa klucze
→ 200 {accessToken, expiresIn, user:{id,email,firstName,lastName,role,mustChangePassword}}
  Set-Cookie: gi_refresh_token=<uuid>.<43 b64url>; Path=/api/v1/auth/refresh; HttpOnly; SameSite=Lax; Max-Age=2592000
```
1. Parsujemy każdą wartość `set-cookie` przez `dart:io Cookie.fromSetCookieValue`.
2. Wybieramy ciasteczko, którego `path` kończy się na `/auth/refresh`. Zapasowo szukamy po nazwie `gi_refresh_token`.
3. Walidujemy wartość wyrażeniem `^[0-9a-f-]{36}\.[A-Za-z0-9_-]{43}$`.
4. Zapisujemy z `absoluteExpiry = now + Max-Age`.
5. Gdy ciasteczka brak, zwracamy klientowy kod `REFRESH_COOKIE_MISSING`.

**Odświeżenie**
```
POST {base}{cookie.path}   Cookie: <name>=<value>   (bez body)
→ 200 {accessToken, expiresIn} + rotowany Set-Cookie
```
- Pusta wartość albo `Expires` w 1970 oznacza wyczyszczenie.
- Odpowiedź 200 **bez** poprawnego rotowanego ciasteczka oznacza utratę sesji. Ponowne użycie starego tokenu dałoby REUSED.

**Wylogowanie**
1. `ensureFresh()`.
2. `POST /auth/logout` (204).
3. **Zawsze** czyścimy dane lokalnie: ciasteczko, access token, snapshot, cache ETag i dane profilu użytkownika.
4. Jeśli wywołanie serwera się nie powiodło, pokazujemy: „Wylogowano z telefonu. Sesja na urządzeniu wygaśnie w ciągu 30 dni lub możesz ją usunąć w Profil → Sesje.”

### 7.4 `AuthSessionManager`: jeden właściciel, pojedynczy lot, zapis przed użyciem
Jedyny kod, który czyta refresh token. Działa tylko na głównym izolacie i używa własnego dio bez CancelToken.

```
ensureFresh({force=false}):
  if !force && access ważny > 60 s → return access
  return _inFlight ??= _refresh().whenComplete(() => _inFlight = null)

_refresh():
  await lock(profile)
  if access odświeżył ktoś inny → return
  if !lifecycle.isResumed → await resumed
  fp ← GET /setup/status (cache ≤ 60 s); initializedAt ≠ profil → DifferentAppliance (ciasteczka NIE wysyłamy)
  R ← vault.read()
     absent      → SessionLost(noToken)
     unavailable → VaultUnavailable (bez czyszczenia; licznik porażek)
  resp ← rawDio.post(R.path, headers:{Cookie: …}, data:null, followRedirects:false, receiveTimeout:30 s)
  200:  R' ← selectRefreshCookie(resp); niepoprawne → wipe; SessionLost(protocol)
        await vault.write(R', generation+1)        // WRITE-AHEAD
        access ← resp.accessToken; zapis (D3)
  401 INVALID | REUSED | SESSION_REVOKED, 403 USER_DISABLED → wipe; SessionLost(code)
  NIE WYSŁANO (DNS, odmowa połączenia, connectTimeout) → zachowaj R; Offline
  NIEJEDNOZNACZNE (timeout receive/send, reset po wysłaniu, 502/503/504, HTML) → zachowaj R; flaga ambiguous;
        następna próba dopiero po udanym GET /health/live, R wysyłamy dokładnie raz
  TLS → ApiFailure.TlsUntrusted (bez zmiany stanu tokenu)
```

Każda ścieżka `SessionLost` zwiększa lokalny licznik przyczyn: `REUSED`, `INVALID`, `REVOKED`, `USER_DISABLED`, `ambiguous`, `noToken`, `protocol`, `vaultUnavailable`.

Obsłużone pułapki:
- równoległe 401 po wznowieniu;
- brak timerów, więc nic nie odświeża się w tle;
- śmierć procesu między rotacją a zapisem (okno zmniejszone do milisekund; skutkiem jest jedno logowanie);
- przejście w tło podczas refreshu;
- przesunięcie zegara;
- zimny start z zapisanym tokenem.

**Kod działający w tle (v1.1+) nigdy nie odświeża tokenu.** Może poprosić główny izolat o token (`IsolateNameServer`), użyć zapisanego, wciąż ważnego tokenu albo pominąć przebieg.

### 7.5 Routing kodów

| Kod | Akcja |
|---|---|
| 401 `AUTH_ACCESS_TOKEN_EXPIRED` / `_INVALID` / `AUTH_UNAUTHORIZED` | `ensureFresh(force)` i jedno powtórzenie |
| 401 `AUTH_SESSION_REVOKED`, 403 `USER_DISABLED` | Wyczyszczenie danych i ekran logowania z tekstem: „Sesja wygasła lub została zakończona na innym urządzeniu (np. limit 10 zalogowanych urządzeń)” |
| `AUTH_INVALID_CREDENTIALS` / `/auth/login` | Błąd formularza |
| 403 `HTTP_403` | PermissionState i ponowne pobranie `/auth/me` |
| 429 `HTTP_429` | Odliczanie (`Retry-After`, jeśli jest — patrz §24; w przeciwnym razie 60 s) |

### 7.6 Czas życia sesji
- Od T-3 dni Ustawienia pokazują „Za X dni trzeba będzie zalogować się ponownie”.
- Po ponownym logowaniu: `DELETE /auth/sessions/<stary sessionId>` (v1.0); kod 404 ignorujemy.
- Przy wznowieniu: `GET /auth/me` i `GET /users/me/profile`.

### 7.7 Odzyskiwanie i hasło (v1.0)

**Reset.** Normalizujemy kod (trim, wielkie litery, bez białych znaków; myślniki zostają, bo Core ich nie usuwa), wysyłamy `POST /auth/recovery/reset` (204) i logujemy użytkownika. `AUTH_RECOVERY_INVALID` mapujemy po kodzie. Reset unieważnia wszystkie sesje, ale kodu nie rotuje (korekta M3), dlatego po resecie proponujemy regenerację.

**Regeneracja** prowadzi do **kroku sejfu**. Kod pokazujemy raz; trzeba go skopiować, udostępnić do menedżera haseł albo przepisać dwie ostatnie grupy. Kod nie jest zapisywany. Nie ma pozornego pytania o hasło, bo Core go nie weryfikuje (L25). Kod daje pełne przejęcie konta, dlatego dopóki ekran sejfu jest widoczny:
- **Android:** `FLAG_SECURE` przez mały kanał platformowy (blokada zrzutów ekranu i miniatury w przełączniku aplikacji). Kopiowanie z `ClipDescription.EXTRA_IS_SENSITIVE` (Android 13+).
- **iOS:** zasłaniająca nakładka przy `AppLifecycleState.inactive`, więc migawka przełącznika nie pokazuje kodu. Kopiowanie przez `UIPasteboard` z `localOnly` i wygaśnięciem po 60 s.
- Test widgetu sprawdza, że nakładka pojawia się w stanie `inactive`.

Te same zabezpieczenia (nakładka i `FLAG_SECURE`) dotyczą formularza resetu z kodem.

### 7.8 Wielu użytkowników na jednym telefonie
Reguła v1: **jeden aktywny użytkownik na profil.**
- „Zmień użytkownika” działa jak wylogowanie: wylogowanie po stronie serwera, a lokalnie czyścimy ciasteczko, access token, snapshot, cache ETag, cache `/settings/system` i liczniki ról. Potem ekran logowania z **pustym** polem e-mail.
- Testy widgetów:
  - po przełączeniu z OWNER na USER kontrolki są przeliczane;
  - żadne dane dostępne tylko dla OWNER (np. strefa czasowa z `/settings/system`) nie przeciekają do sesji USER.

---

## 8. Błędy, offline i diagnostyka

### 8.1 `ApiFailure`
```
CoreError{statusCode, code, message, path, requestId, timestamp, details?}
  ├ ValidationFailed · Forbidden(HTTP_403) · RateLimited(HTTP_429) · RouteAbsent(HTTP_404) · Domain(code)
AuthFailure(code)
Unreachable (nie wysłano) · Timeout (niejednoznaczne) · LocalNetworkDenied · TlsUntrusted(host, reason)
UnexpectedResponse (nie-JSON, np. strona HTML proxy) · UnexpectedShape(endpointId, field)
PlainServerError(500)
```
- Tekst w UI pochodzi z `code` w plikach ARB. Kody klienckie:
  - `BACKEND_UNREACHABLE`, `REQUEST_TIMEOUT`;
  - `LOCAL_NETWORK_DENIED`, `TLS_CERT_UNTRUSTED`;
  - `UNEXPECTED_RESPONSE`, `REFRESH_COOKIE_MISSING`, `DIFFERENT_APPLIANCE`.
- `TlsUntrusted` mapujemy z `HandshakeException`/`CertificateException`. Komunikat: „Certyfikat serwera nie jest zaufany – użyj http:// w sieci domowej lub certyfikatu z publicznego CA”. **Nigdy nie przechodzimy po cichu z https na http.**
- `RouteAbsent` (`HTTP_404` na znanym endpoincie) oznacza „Funkcja niedostępna w tej wersji GI Home” i zasila sondowanie funkcji (§16).

### 8.2 Komunikaty dla przełączników i ogrzewania

| Kod | UX |
|---|---|
| 409 `HEATING_SUSPENDED` | „Ogrzewanie jest wstrzymane. Najpierw je wznów.” |
| 409 `ENTITY_DISABLED`, 422 `ENTITY_NOT_WRITABLE` | „Tego przełącznika nie można teraz użyć” |
| 503 `DEVICE_OFFLINE` | „Urządzenie jest offline. Polecenie nie zostało wysłane.” |
| 503 `ESPHOME_DEVICE_UNREACHABLE`, 502 `…_UNCONFIRMED`, 504 `…_TIMEOUT` | „Urządzenie nie potwierdziło polecenia”, a następnie odświeżenie szczegółów |
| 502 `ESPHOME_COMMAND_REJECTED` | Jak `…_UNCONFIRMED`: urządzenie ESPHome odpowiedziało statusem innym niż 2xx (`esphome-http.client.ts`). Kod nie był wcześniej w tej tabeli |
| 400 `ESPHOME_HOST_FORBIDDEN` | „Adres sterownika jest poza siecią domową” (mało prawdopodobne; host rozwiązuje się na adres publiczny) |
| 403 `HTTP_403` | „Nie masz uprawnień do tej operacji.” i jednorazowe przeładowanie `/auth/me` |
| 404 `DEVICE_ENTITY_NOT_FOUND` | „Element został usunięty lub zmieniony.” |
| 400 `VALIDATION_FAILED` | Błąd przy polu |
| 500 | Komunikat ogólny, ponowienie, `requestId` |

### 8.3 Offline i miejsce przechowywania danych
- Repozytoria trzymają ostatnią dobrą wartość z `fetchedAt`.
- Od M3 jest trwały snapshot dla profilu i użytkownika. **Snapshot, cache ETag i logi** leżą w `getApplicationSupportDirectory()`:
  - iOS: z `NSURLIsExcludedFromBackupKey`; `UIFileSharingEnabled` wyłączone;
  - Android: obejmują je `allowBackup=false` i `dataExtractionRules`.
- Test jednostkowy sprawdza, że wylogowanie i zmiana użytkownika czyszczą wszystkie trzy magazyny: secure storage, prefs i pliki.
- Zimny start bez połączenia pokazuje snapshot tylko do odczytu z banerem „Brak połączenia z GI Home · dane z 07:41” i kondycją „Ograniczone dane”.
- **Zapisy nigdy nie są kolejkowane offline.**

### 8.4 Przechwytywanie błędów i raport diagnostyczny
Aplikacja jest local-first i nie zawiera żadnego SDK telemetrii. Nic nie wymaga zmian w backendzie.
1. **M1:** handlery `FlutterError.onError`, `PlatformDispatcher.instance.onError` i `runZonedGuarded` zapisują błędy do zredagowanego bufora pierścieniowego. Nieprzechwycone wyjątki Dart nie wywracają procesu, więc nie trafiłyby do natywnych raportów awarii.
2. **Lokalne liczniki:**
   - przyczyny wymuszonego wylogowania (§7.4);
   - `UnexpectedShape` per `endpointId`;
   - czas zimnego startu w ms;
   - `VaultUnavailable`, `TlsUntrusted`, `LocalNetworkDenied`.
3. **„Wyślij raport diagnostyczny”** (Ustawienia): arkusz udostępniania z plikiem JSON. Tokeny, e-maile i adresy IP hosta są zredagowane. Beta-testerzy wysyłają raport raz w tygodniu i na tej podstawie liczymy G4.
4. Natywne awarie: raporty App Store Connect i Play Android vitals.
5. Zdalne raportowanie (np. self-hosted Sentry) to osobna decyzja opt-in (D18). Wymagałoby aktualizacji etykiety prywatności i formularza Data safety.

---

## 9. Łączność LAN, tożsamość urządzenia i bezpieczeństwo transportu

### 9.1 Co istnieje
- Avahi publikuje tylko rekord A/AAAA `gi-home.local`. Drugie urządzenie dostaje nazwę `gi-home-2.local`.
- Nie ma `_gihome._tcp` ani rekordu TXT.
- Nie ma stabilnego identyfikatora urządzenia dostępnego bez uwierzytelnienia.

### 9.2 Drabina połączenia („Znajdź GI Home”)
1. Zapamiętany host profilu: `GET /api/v1/health/live` z timeoutem 1,5 s.
2. Rozwiązanie nazwy `gi-home.local`, a następnie `gi-home-2…5.local`:
   - iOS: systemowy resolver;
   - Android: najpierw systemowy resolver, potem `multicast_dns` (jeśli S3 wykaże taką potrzebę).
3. Ręczny wpis: host, port, IP lub URL. Wpis ręczny jest **zawsze widoczny**.
4. (v1.1) Przeszukanie podsieci /24.

Kandydat jest potwierdzony, gdy `health/live` zwraca 200 i `/setup/status` się parsuje. Potem użytkownik potwierdza wybór.

**Wiele kandydatów przy D1 = A (jeden profil):**
- ekran łączenia wypisuje wszystkie znalezione urządzenia;
- wybór innego niż obecny profil **zastępuje** profil dopiero po potwierdzeniu: „Spowoduje wylogowanie i usunięcie danych z GI Home „X””. Czyszczone są ciasteczko, snapshot i ETag.
- Przy D1 = B patrz §23.

### 9.3 Odcisk urządzenia
- Odcisk to `initializedAt + deviceName`. Zgodność sprawdzamy przy każdym uruchomieniu i przed każdym refreshem.
- Różne `initializedAt` oznacza inne urządzenie, więc ciasteczka nie wysyłamy.
- `initialized:false` oznacza reset urządzenia i ekran „Dokończ konfigurację”.
- Gdy zmieni się IP, ponownie wiążemy profil przez `gi-home.local`, jeśli odcisk się zgadza.
- Odcisk służy poprawności, nie bezpieczeństwu (L13).
- Test akceptacyjny: dwa Core w Dockerze z różnym `initializedAt` nigdy nie dostają nawzajem swojego ciasteczka refresh.

### 9.4 Konfiguracja platform i TransportPolicy

**iOS:**
- `NSAllowsLocalNetworking = YES`, bez `NSAllowsArbitraryLoads`.
- `NSLocalNetworkUsageDescription` po polsku i angielsku.
- Brak `NSBonjourServices`.
- Odmowa dostępu do sieci lokalnej daje `LocalNetworkDenied` i link do Ustawień.

**Android:**
- `compileSdk`/`targetSdk` **36**. Play wymaga targetSdk 36 dla nowych aplikacji i aktualizacji od 31 VIII 2026; potwierdzić w Play Console w M0. `minSdk` zgodnie z D13.
- Uprawnienia `INTERNET`, `ACCESS_NETWORK_STATE`, `CHANGE_WIFI_MULTICAST_STATE` (tylko dla zapasowego mDNS).
- `network_security_config.xml` z `base-config cleartextTrafficPermitted="true"` (konieczne dla wpisu IP).
- **Ochrona sieci lokalnej:** deklarujemy `NEARBY_WIFI_DEVICES` z `usesPermissionFlags="neverForLocation"` i budujemy żądanie runtime z mapowaniem `LocalNetworkDenied` (UX jak na iOS), gotowe na chwilę, gdy docelowe API to wymusi. W Androidzie 16 ochrona jest opcjonalna (flaga kompatybilności); termin wymuszenia jest w §24. Spike S2 obejmuje uruchomienie z włączoną flagą.
- Wyrównanie stron 16 KB dla wszystkich natywnych bibliotek wtyczek (`zipalign -c -P 16` lub APK Analyzer) jest bramką wydania w M4.
- Duże ekrany: Android 16 przy targetSdk 36 ignoruje blokady orientacji i zmiany rozmiaru na ≥ 600 dp. Akceptujemy więc poziom na tabletach i dodajemy golden 840×600. Na iOS: tylko iPhone, portret (`TARGETED_DEVICE_FAMILY=1`), zgodnie z D13.

**`dart:io HttpClient` może omijać ATS/NSC.** Konfigurujemy je mimo to; S2 sprawdza, co faktycznie działa.

**TransportPolicy** (pierwszy interceptor):
- `http://` dozwolone tylko dla RFC1918, link-local, loopback, `*.local` i `10.0.2.2` (tylko flavor dev);
- wszystko inne wymaga `https://`;
- dane logowania i ciasteczko nigdy nie trafiają do hosta, który nie spełnia polityki;
- brak cichego przejścia z https na http.

**Uczciwość co do jawnego tekstu:** jednorazowy komunikat „Połączenie w sieci domowej nie jest szyfrowane. Używaj tylko w zaufanej sieci Wi-Fi.”, wskaźnik „HTTP” w Ustawieniach i logger bez tokenów.

**HTTPS za proxy operatora:** działa z systemowym magazynem zaufania. Na Androidzie `dart:io` domyślnie nie ufa CA zainstalowanym przez użytkownika, więc prywatne CA zadziała dopiero z TOFU (v1.1), co opisujemy w README. Test jednostkowy z serwerem shelf na certyfikacie self-signed sprawdza mapowanie na `TlsUntrusted`.

### 9.5 Pierwsze uruchomienie
`POST /setup/initialize` jest publiczny i bez limitu żądań. Pierwsza osoba, która go wywoła, zostaje właścicielem. Dlatego v1 tylko przekazuje użytkownika do przeglądarki (`http://<host>/setup`; na Pi Traefik kieruje `/` do gi-ui). Natywny kreator to D7.

### 9.6 Base URL w trybie deweloperskim
Presety flavoru dev, edytowalne:

| Cel | Base URL | Warunek |
|---|---|---|
| Emulator Androida | `http://10.0.2.2:3000` | Core opublikowany na loopbacku hosta (domyślnie przez nakładkę) |
| Symulator iOS | `http://localhost:3000` | j.w. |
| Android fizyczny (USB) | `adb reverse tcp:3000 tcp:3000`, potem `http://localhost:3000` | Core zostaje na loopbacku |
| **Dowolny telefon fizyczny w LAN (preset główny)** | `http://<IP-PC-w-LAN>:3000` | Backend uruchomiony z `GI_CORE_BIND_ADDRESS=0.0.0.0` i nakładką mobilną. To zmienna środowiskowa runtime; żaden plik backendu się nie zmienia. Port publikuje mosquitto. |
| Alternatywa | `http://<IP-PC>:8080` przez `tools/dev_lan_proxy` (forwarder TCP w Dart `0.0.0.0:8080 → 127.0.0.1:3000`) | Gdy Core ma zostać na loopbacku |
| Prawdziwe Pi | `http://gi-home.local` lub `http://<ip>` | |

Trasa przez dev GI UI `:3001` **nie działa** z obecną konfiguracją: z nakładką nazwa `gi-core` nie istnieje w sieci, a gi-ui nie jest uruchomione. Wymagałaby GI UI zbudowanego z osiągalnym `GI_CORE_URL`, więc jej nie używamy.

W Windows trzeba otworzyć wybrany port w profilu „Prywatna” zapory (README).

---

## 10. Zdalny dostęp przez GI Cloud: poza v1
Wymagałby wszystkich poniższych:
- osobnego logowania do gi-cloud;
- ręcznego parowania `applianceId`;
- `remote-session` i wymiany `?rat=` na ciasteczko `gi_remote`;
- drugiego logowania do Core w tunelu.

Dodatkowe przeszkody:
- tunel buforuje odpowiedzi;
- błędy wracają jako HTML;
- chmura jest domyślnie wyłączona;
- kod przejęcia jest dostępny tylko przez SSH;
- TLS kończy się na VPS;
- istnieje ryzyko podszycia się pod konektor.

**v1 działa tylko w LAN** („Dostęp tylko w sieci domowej”). Architektura zostawia furtkę: `ApplianceProfile.transports` i ciasteczko przechowywane per profil. Opcjonalny spike R1 (flaga dev) wchodzi w grę tylko wtedy, gdy działa stos chmurowy. Ten plan nie prosi nikogo o zmiany w chmurze.

---

## 11. Czas rzeczywisty: polling na istniejących endpointach

| Dane | Endpoint | Kadencja (pierwszy plan) |
|---|---|---|
| Lista urządzeń (wspólny cache dla Domu, Urządzeń i Uwagi) | `GET /devices?limit=100` | 30 s, pull-to-refresh i przy wznowieniu |
| Karty ogrzewania na Domu | `GET /devices/:id` dla urządzeń grzewczych z ostatniej listy | max(15 s, n × 6 s), gdzie n = liczba urządzeń grzewczych na liście (nie widocznych kart); współbieżność ≤ 3; zob. [ADR 0016](decisions/0016-home-card-cadence-request-budget.md) |
| Otwarte szczegóły | `GET /devices/:id` | 5 s; 2 s przez 30–45 s po poleceniu; 15 s po 2 min bezczynności |
| Pokoje | `GET /rooms` | przy otwarciu |
| Pogoda i słońce | `/weather/*`, `/solar/current` | 15 min |
| PV | `/pv/forecast`, `/pv-heating-plan` | 30 / 15 min |
| Historia | historia encji | 60 s dla ≤ 24 h; brak odświeżania dla 7 d |
| `/auth/me`, `/users/me/profile` | | przy wznowieniu i po `HTTP_403` |

**Zasady:**
- Wszystko staje przy `paused`. Przy wznowieniu jedno pobranie z jitterem 0–300 ms.
- Tyknięcie jest pomijane, jeśli poprzednie żądanie jeszcze trwa.
- Maksymalnie 4 współbieżne żądania na urządzenie GI Home.
- Backoff 5 → 10 → 30 → 60 s.
- Banner „Dane z HH:MM”, gdy dane są starsze niż 2× interwał (dla kart: 2× ich własna kadencja).

**Budżet obciążenia (Exit M4):**
- ≤ 12 żądań/min na telefon na ekranie Dom (lista 2/min + karty łącznie ≤ 10/min: każda karta co max(15 s, n × 6 s); np. 18 s przy 3 kartach, 30 s przy 5); szczegóły w [budżecie obciążenia](load-budget.md);
- ≤ 30 żądań/min średnio na szczegółach (z krótkimi szczytami po poleceniu);
- CPU gi-core na Pi < 50% przy 3 telefonach i panelu web przez 30 min.

### 11.1 Kondycja domu (czysta funkcja, testy jednostkowe)
Liczona **z samej listy** oraz z wyniku pobrania szczegółów kart ogrzewania:
```
ActionRequired  dowolne włączone urządzenie: currentState ∈ {FAULT, SAFE_MODE}
                lub connectivityState == ERROR lub (grzewcze && activeFaultCount > 0)
NeedsAttention  inaczej: connectivityState ∈ {OFFLINE, STALE} lub activeFaultCount > 0
                lub grzewcze && heatingSuspended lub productStatus == needs_configuration
LimitedData     inaczej, gdy: urządzenie nieosiągalne / pokazany snapshot / nie powiodło się
                pobranie szczegółów karty / lista starsza niż 2 min / brak urządzeń
Good            w pozostałych przypadkach
```
„Ograniczone dane” zawsze wygrywa z fałszywym „Dobrze”. Najwyżej 3 sugestie. Kolor nigdy nie jest jedynym sygnałem.

---

## 12. UX sterowania krytycznego dla bezpieczeństwa
Reguły są w `SafetyPolicy` i `ConfirmationPolicy` (czysty Dart, 100% pokrycia gałęzi). Źródła: `docs/safety.md`, `docs/state-machine.md`, `esphome-switch-command.service.ts`, PRD §8.6/§10.4.

### 12.1 Wstrzymanie ogrzewania
- **Wstrzymanie:** przytrzymanie przez ok. 600 ms, bez dialogu (OFF to kierunek bezpieczny). Akcja dostępna też w VoiceOver i TalkBack. Wysyła `PATCH /devices/:id {"heatingSuspended": true}`, a następnie polluje do potwierdzenia.
- **Wznowienie:** zawsze arkusz konsekwencji z temperaturą zasilania i powrotu (z wiekiem danych), trybem i celem, które zaczną obowiązywać, oraz tekstem „Kocioł może się włączyć w ciągu ~30 s”.
- **Gdy ogrzewanie jest wstrzymane:** przypięty baner, ukryte akcje ON z wyjaśnieniem, a 409 dostaje ten sam komunikat.
- **Odstępstwa M2 (otwarte):** arkusz wznowienia pokazuje dziś tylko temperaturę sterującą (z wiekiem danych), bez osobnej temperatury zasilania i powrotu; przypiętego banera wstrzymania nie ma jeszcze na karcie Ustawienia. Do uzupełnienia, zanim §12.1 uznamy za spełniony.

### 12.2 Przełączniki bez optymizmu
Stany:
1. „Wysyłanie…”
2. po 2xx:
   - **LEGACY_ESPHOME** (synchronicznie): „Potwierdzone przez urządzenie”;
   - **GI_EDGE_V1**: „Zlecono · czeka na potwierdzenie”.
3. Szybki polling szczegółów.

**Potwierdzenie dla GI_EDGE_V1.** Nigdy nie używamy `entity.value` ani `entity.lastSeenAt`: Core zapisuje je optymistycznie zaraz po zakolejkowaniu polecenia (§3.6). Potwierdzenie wymaga **poziomu urządzenia** `lastSeenAt` (heartbeat lub telemetria) **ściśle późniejszego niż `confirmedAt` z odpowiedzi PUT**; to zegar serwera, więc nie ma przesunięcia zegara klienta. Źródłem jest `diagnostics.relayN.{output, commanded}` z heartbeatu. Heartbeat i dostarczenie polecenia to w Core osobne kanały, więc heartbeat liczy się jako raport dopiero, gdy `relayN.commanded` równa się żądanemu stanowi (przy wstrzymaniu: gdy żaden przekaźnik nie ma już `commanded: true`). Inaczej zostaje „Zlecono · czeka na potwierdzenie”, a po 45 s (dłużej niż interwał heartbeatu 30 s plus dwa polle; to nie TTL polecenia) pokazujemy ostatni heartbeat po `confirmedAt` taki, jaki jest, albo „Brak potwierdzenia”, gdy żadnego nie było. Stan przełącznika i wartość encji przekaźnika GI Edge bierzemy z `diagnostics.relayN.output` (w dry-run z `commanded`), nigdy z `entity.value`; bez diagnostyki przekaźnika wartość encji zapisana po ostatnim heartbeacie to „czeka na raport sterownika”.

Kwestie z §24, zamknięte w M2 (odczyt kodu backendu, ADR [0009](decisions/0009-switch-confirmation-semantics.md)):
- **`communicationMode` jest w `GET /devices/:id`** (`device-details-query.service.ts:54`), więc GI_EDGE_V1 rozpoznajemy wprost; ostrej reguły nie stosujemy do LEGACY_ESPHOME. Odpowiedź PUT nie mówi ani o trybie, ani o wyniku.
- **Heartbeat aktualizuje `Device.lastSeenAt`** zegarem serwera (`gi-edge-heartbeat.service.ts`, HTTP i MQTT) i nadpisuje encje przekaźników z `diagnostics.relayN.{output, commanded}`.
- **GI_EDGE i `dryRun`: PUT zwraca STARY stan** encji (encja nie jest zapisywana, audyt `REQUESTED_DRY_RUN`, `confirmedAt` = czas żądania). `response.state` nigdy nie jest traktowane jako nowy stan, na żadnej ścieżce.
- **409 `HEATING_SUSPENDED` dotyczy wszystkich przełączników urządzenia, tylko żądań ON.** OFF jest zawsze dozwolone przy wstrzymaniu (`esphome-switch-command.service.ts:87-99`).

Test fixture odtwarza zapis optymistyczny: w pierwszym pollu wartość encji się zgadza, a UI **nie** pokazuje „Potwierdzone”.

Komunikat **nigdy** nie twierdzi, że przekaźnik fizycznie się przełączył. Kontrolkę renderujemy tylko przy `domain=='switch' && writable && enabled && availability && urządzenie ONLINE`.

### 12.3 Dry-run
- Bursztynowy baner „Tryb testowy: przekaźniki nie przełączają się fizycznie”.
- Podpowiedź „Sterownik chciałby: WŁ” na podstawie `diagnostics.relayN.commanded`.
- Przełącznik dry-run zostaje w panelu web.

### 12.4 Przekaźniki kotła i pompy
Nigdy nie są ręcznymi przełącznikami w v1. Wyświetlamy je tylko do odczytu („Kocioł: grzeje (polecenie sterownika)”). Ewentualna zmiana to D9.

### 12.5 Edytor strategii
- **Wartość efektywna a bazowa:**
  - **M2:** gdy wartość efektywna różni się od bazowej (inny cel lub histereza), pokazujemy „Harmonogram aktywny” obok „Ustawienie domyślne: 20 °C, histereza 0,5 °C”. API nie mówi, który harmonogram obowiązuje. **Porównujemy wyłącznie cel i histerezę, nigdy `mode`:** przy wstrzymaniu rekoncyliacja zapisuje efektywne `mode: 'OFF'` przy niezmienionej bazie (`heating-schedule-reconciliation.service.ts:52-61`). Przy `heatingSuspended` podpowiedzi „Harmonogram aktywny” nie pokazujemy wcale, tylko wstrzymanie.
  - **M3:** nazwa harmonogramu i godzina końca („„Rano” 21 °C do 08:00”), **wyliczone** przez klientowy `ScheduleClock`. To replika `windowMatches` z Core: pierwszy pasujący według `createdAt asc`, `mode` zawsze z bazy, zegar procesu gi-core (`heating-schedule-reconciliation.service.ts:164-169`). Etykieta „wywnioskowane”.
- **Wykrywanie konfliktu.** Przy otwarciu arkusza zapamiętujemy `baseControlStrategy {targetTemperatureCelsius, hysteresisCelsius, mode}` i `heatingSuspended`. Przed PATCH pobieramy świeże `GET /devices/:id` i **porównujemy te wartości**. Jeśli się różnią, pokazujemy „Ktoś zmienił ustawienia w międzyczasie”, przeładowujemy i pytamy ponownie. `configurationVersion` jest tylko informacyjne, bo cron zwiększa je co minutę (§3.6). Last-write-wins jest ograniczony, nie wyeliminowany (L16).
- **Zakresy:** cel w krokach 0,5 °C, UI ogranicza do 5–80 °C (serwer przyjmuje 0–100). Ostrzeżenie powyżej `pvHeatingConfig.safeMaxTemperatureCelsius`. Podniesienie o ponad 10 °C wymaga potwierdzenia. Histereza 1–20. Zawsze wysyłamy trzy pola.
- **Tryby:** AUTO „GI Home steruje kotłem”; OFF „Sterowanie wyłączone – GI Home nie będzie włączać kotła”; MANUAL „GI Home nie steruje automatycznie”. Wejście w OFF bez potwierdzenia, wyjście z OFF z potwierdzeniem.

### 12.6 Blokada przy nieaktualnych danych
Przy OFFLINE, STALE lub snapshocie kontrolki przełączników i strategii są wyłączone. **Wstrzymanie zostaje dostępne.**

Blokada klienta jest **świadomie ostrzejsza niż serwer**: `validateEntity` w Core sprawdza zapisany `status == ONLINE`, nie `connectivityState`, więc urządzenie STALE (5–15 min bez heartbeatu) nadal przyjęłoby polecenie. Aplikacja go nie wyśle (`LockReason.staleData`).

### 12.7 Usterki
- Gdy `currentState ∈ {FAULT, SAFE_MODE}` lub `activeFaultCount > 0`, pokazujemy „Wymaga uwagi”. Oba pola pochodzą z listy (§4.1), ze źródłem i świeżością.
- Brak przycisku resetu, bo nie ma takiego API.
- Utrata łączności to „Brak łączności – lokalne sterowanie działa nadal”, a nie usterka.

### 12.8 Bramkowanie ról
`canControl = catalog.can(setSwitchState)`. Kod 403 nadal jest obsługiwany.

### 12.9 Dostępność
- Etykiety Semantics i ogłaszanie zmian stanu.
- Cele dotyku ≥ 48 dp, ograniczony ruch, kolor nigdy nie jest jedynym nośnikiem stanu.
- **Wykresy** mają podsumowanie Semantics (np. „Temperatura zasilania 24 h: min 38,2, max 61,0, teraz 54,3 °C”) i przełącznik „Pokaż jako tabelę” z alternatywną listą.
- Testy `meetsGuideline(androidTapTargetGuideline | iOSTapTargetGuideline | textContrastGuideline | labeledTapTargetGuideline)` na wszystkich głównych ekranach.

---

## 13. i18n, formatowanie i czas

### 13.1 Języki
- `app_pl.arb` jest szablonem, `app_en.arb` jest kompletny przy wydaniu.
- Liczby mnogie w ICU.
- Słownictwo importuje jednorazowo `tools/import_web_messages.dart` z `apps/gi-ui/src/shared/i18n/messages.ts` (tylko odczyt).
- Rzeczowniki techniczne są zabronione na ekranach codziennych.
- CI sprawdza kompletność pl/en.

### 13.2 Źródło języka
- Kolejność, od najważniejszego:
  1. Preferencja telefonu (`app_language.v1`): Ustawienia → „Język” oraz przycisk „Język” na ekranach połączenia i logowania (Automatycznie / Polski / English). Wygrywa ze wszystkim, przeżywa wylogowanie, a GI Core o niej nie wie.
  2. Zalogowany: `GET /users/me/profile`.locale, bo `AuthUserDto` nie ma pola locale. Do czasu odpowiedzi profilu obowiązuje język ostatnio zastosowany dla tego użytkownika na tym urządzeniu (`SessionLocaleStore`, klucz `session_locale.v1`).
  3. Wylogowany, ale urządzenie pamięta ostatniego użytkownika (`lastUserId`): jego zapamiętany język, żeby ekran logowania po pierwszym logowaniu mówił językiem użytkownika. Wylogowanie go zachowuje; „Zmień użytkownika” i usunięcie urządzenia wymazują razem z użytkownikiem.
  4. Przed pierwszym logowaniem na urządzeniu (pierwsze połączenie, po „Zmień użytkownika”): język telefonu, a gdy aplikacja go nie wspiera, polski.
- `Accept-Language` zawsze niesie język, który aplikacja faktycznie pokazuje.
- Teksty, które powstają po `await` albo przy zmianie ekranu (komunikaty snackbar, okna dialogowe), są układane w chwili pokazania, w bieżącym języku: dialogi czytają `context.l10n` w builderze, snackbary używają `localizedSnackBar`. Oferta przeglądu sesji po logowaniu czeka (do 5 s) na profil, żeby nie pojawiła się najpierw w języku telefonu.
- Zmiana na serwerze: `PATCH /users/me/profile {locale}` (Konto → Język).

### 13.3 Formatowanie
- `intl` z językiem aplikacji. Stopnie Celsjusza z 1 miejscem po przecinku. „—” z etykietą „Brak danych”.
- Godziny pogody w UTC, dni pogody jako doby UTC. Czas PV to czas lokalny domu, z etykietą „czas domu”.
- Dni harmonogramu: API ma `0=niedziela`, UI zaczyna tydzień od poniedziałku (`ApiWeekday`: `coreDay = dartWeekday % 7`).

### 13.4 Zegar harmonogramów
- Core porównuje godziny przez `now.getHours()`/`getDay()` na zegarze procesu gi-core (`heating-schedule-reconciliation.service.ts:164-169`, **zweryfikowane**), a nie w strefie z ustawień.
- Żaden plik compose nie ustawia `TZ` dla gi-core (`TZ: Europe/Warsaw` ma tylko homeassistant, `infrastructure/compose.yml:23`). Prawdopodobnie jest to UTC; potwierdza S7.
- Ustawienie per profil „Zegar harmonogramów” ma wartości `UTC` lub `Czas domu`.
- Domyślnie tylko etykieta i podwójny czas: „06:00 UTC = 07:00 czasu polskiego dziś (zimą) / 08:00 latem”.
- Opcjonalnie „Edytuj w czasie domu” (D8): konwersja z dzisiejszym offsetem i baner zmiany czasu dla OWNER/ADMIN. Nigdy nie przepisujemy harmonogramów po cichu.
- **Strefa domu:** `/settings/system` czytają OWNER, ADMIN i SERVICE (decyduje katalog). USER widzi etykietę zegara i strefę telefonu.

---

## 14. Wygląd („Ember Control Room”)
- **Tylko ciemny motyw w v1** (D11), przeniesiony z `apps/gi-ui/src/app/globals.css`. Tokeny w `ThemeExtension<GiTokens>`:
  - tło `#0a0908`;
  - powierzchnie `#171310`/`#1e1815`;
  - tekst `#f5efe7`, wyciszony `#a89a8a`;
  - ember `#ff8a3d`, `#ffb457`, `#c85a1e`;
  - teal `#4fd1ae`, danger `#ff6b6b`, warning `#ffb457`.

  `warning` ma ten sam kolor co `emberHot`, więc chipy ostrzeżeń zawsze dostają ikonę i obrys.
- **Fonty dołączone do aplikacji** (Fraunces, Manrope, JetBrains Mono), bez pobierania w runtime.
- **Ikona:** płomień z `apps/gi-ui/src/app/icon.svg`, **skopiowany** do `app/assets/`. Wstążka na flavorach dev i beta.
- **Komponenty współdzielone:** Badge, Card, Skeleton, ConfirmSheet, HoldToConfirmButton, EmptyState, ErrorState, PermissionState, FreshnessLabel, StatusChip, DemoBanner.
- **Dostępność kolorów:** kontrast WCAG AA sprawdzany w goldenach.

---

## 15. Powiadomienia

**v1.0: lista „Uwaga” w aplikacji i plakietka na zakładce, wyliczane z `GET /devices`.**
- Reguła mobilna: `connectivityState ≠ ONLINE` **lub** `activeFaultCount > 0` **lub** `currentState ∈ {FAULT, SAFE_MODE}`.
- **Celowo różni się od panelu web**, który filtruje po `device.status.toLowerCase() !== "online"` (`apps/gi-ui/src/app/(shell)/notifications/page.tsx:28-34`, **zweryfikowane**). `connectivityState` łapie też STALE.
- Waga zdarzeń jest wyliczana po stronie klienta: krytyczne, ważne, uwaga, rozwiązane (24 h lokalnie).
- Nie ma potwierdzania ani drzemki.

**v1.1+ (opcjonalne „Sprawdzaj w tle”, D10):**
- WorkManager lub `BGAppRefreshTask`, tylko w LAN.
- **Nigdy nie odświeża tokenów.** Komunikat: „Powiadomienia z opóźnieniem, tylko w sieci domowej, krótko po użyciu aplikacji.”

**Push jest niemożliwy.** Core nie ma rejestracji tokenów urządzeń, modelu alertów ani strumienia zdarzeń.

---

## 16. Kompatybilność z wersjami Core (bez zmian w backendzie)

1. **Wersja na zasadzie best effort.** Dla OWNER/ADMIN przy wznowieniu czytamy `GET /appliance/updates/status` (OWNER/ADMIN). Na skonfigurowanym Pi `lastCheck.services[]` zawiera `runningVersion` (`supervisor-update-client.port.ts:6`, **zweryfikowane** pole). W dev prawdopodobnie `configured:false`, więc wartość jest null (§24).
   - Wersję zapisujemy w diagnostyce i pokazujemy na ekranie „Informacje o urządzeniu”.
   - **Nic nie jest od niej bramkowane.**
2. **Sondowanie funkcji po zalogowaniu.** Dla każdej opcjonalnej funkcji wykonujemy tani, uwierzytelniony GET.
   - `HTTP_404` oznacza brak trasy, w odróżnieniu od `RESOURCE_NOT_FOUND`.
   - Wynik jest cache'owany per profil, a ekrany są bramkowane tym wynikiem i `FeatureFlags` (§19.6).
   - Sondy wolno wykonywać tylko z rolą dozwoloną przez katalog, żeby nie generować 403.
3. **Deklaracja kompatybilności.** Minimalny wspierany Core to ref z `contract/backend.lock` danego wydania. Testy nocne biegną na przypiętym ref i na najnowszym `main`. Deklarację publikujemy w notach wydania.
4. **Nieaktualna aplikacja.** Jeśli `UnexpectedShape` powtórzy się ≥ 3 razy w sesji na kluczowym endpoincie MVP, pokazujemy „Zaktualizuj aplikację” z linkiem do sklepu. Na Androidzie używamy Play In-App Updates (`in_app_update`, tryb natychmiastowy), gdy sklep zgłasza aktualizację.

---

## 17. Testy

### 17.1 Warstwy

| Warstwa | Zakres | Narzędzia |
|---|---|---|
| Jednostkowe: kontrakt | Każde DTO dekoduje **prawdziwy fixture**. Nieznane enumy. Dokładne klucze `toJson`. Wybór ciasteczka z `Set-Cookie`. | `dart test` |
| Jednostkowe: auth | 10 równoległych 401 daje 1 refresh. Zapis przed udostępnieniem tokenu. 200 bez ciasteczka. Niewysłane vs niejednoznaczne. REUSED/INVALID/REVOKED/USER_DISABLED. Niezgodny odcisk. Stan paused. Gałęzie `VaultResult`. Brak CancelToken. | `fake_async`, `mocktail` |
| Jednostkowe: polityki | `SafetyPolicy`, `ConfirmationPolicy` (w tym fixture optymistycznego zapisu GI_EDGE), `HomeCondition`, `FreshnessPolicy`, `TransportPolicy`, `ApiWeekday`, `ScheduleClock` (zmiana czasu w marcu i październiku, północ), wykrywanie konfliktu strategii po wartościach, mapowanie `TlsUntrusted` (serwer shelf z certyfikatem self-signed) | 100% gałęzi dla Safety i Transport |
| Widgety | Macierz ról. Przełącznik zlecony → potwierdzony / niepotwierdzony. Wstrzymanie i wznowienie. Blokada przy nieaktualnych danych. **Konflikt strategii po wartościach bazowych** (a nie po `configurationVersion`; test sprawdza, że sam wzrost wersji nie daje konfliktu). Dry-run. `VALIDATION_FAILED`. Wskazówki autofill. Nakładka sejfu przy `inactive`. Zmiana użytkownika OWNER → USER. Wytyczne a11y. | `flutter_test` |
| Golden | Dom; Szczegóły (normalny, wstrzymany, dry-run, offline, stale); Logowanie; Strategia; Historia z tabelą; Demo. pl i en, skale tekstu 1,0 / 1,3 / 2,0, telefon mały i duży, tablet Android 840×600. | `alchemist` |
| Mock Core / demo | Adapter `HttpClientAdapter` w procesie odtwarza fixture'y ze scenariuszami (zgubiona odpowiedź refresh, REUSED, 429, 503, FAULT, strona HTML, wolne odpowiedzi). Ten sam adapter obsługuje tryb demo. Osobny `tools/mock_core` (shelf) tylko do pracy deweloperskiej. | |
| Kontrakt na żywo | §17.3 | `dart test -t live` |
| E2E | Emulator Androida: połączenie, logowanie, przełącznik, wstrzymanie, wznowienie, wylogowanie. Mock na PR, prawdziwy Core co noc. Patrol obsługuje dialog Local Network w iOS. | `integration_test`, `patrol` |
| Ręczna lista sprzętowa | Pi: `.local` na iOS i 2 producentach Androida, ATS z IP, odmowa sieci lokalnej, Android 16 z flagą ochrony sieci lokalnej, Wi-Fi ↔ komórka, **potwierdzanie GI_EDGE na prawdziwym sterowniku**, dry-run, zegar harmonogramów, VoiceOver i TalkBack (pl) | Przed każdym wydaniem |

### 17.2 Wspólna definicja ukończenia (DoD) każdego kamienia milowego
- `flutter analyze` czysty, kod sformatowany, `build_runner` aktualny.
- Pokrycie testami jednostkowymi `domain/` i `gi_core_api` ≥ 90%; `SafetyPolicy`, `ConfirmationPolicy` i `TransportPolicy` mają 100% gałęzi.
- Każdy nowy wpis katalogu ma test fixture i test kontraktowy na żywo.
- ARB pl i en kompletne, goldeny zaktualizowane.
- Lista kontrolna a11y dla nowych ekranów przechodzi.
- Brak otwartych błędów P0/P1.
- Brak `TODO(backend)` w repo.

### 17.3 Testy kontraktowe na żywo przeciw prawdziwemu backendowi w Dockerze

**Główny mechanizm: `contract/compose.contract.yml` (w repo mobilnym, NIE dołącza `infrastructure/compose.yml`).**

Dlaczego nie nakładka na bazowy compose: stałe `container_name`, stała sieć `gi-home-energy` i stałe porty hosta (§3.9) uniemożliwiają drugi projekt obok stosu dev. Zmiana `GI_CORE_PORT`/`GI_UI_PORT` **nie** usuwa tych kolizji.

Usługi (bez `container_name`, domyślna sieć projektu, bez stałych portów hosta):

| Usługa | Definicja |
|---|---|
| `postgres` | `timescale/timescaledb:latest-pg17` z `shared_preload_libraries=timescaledb`, własne hasło, wolumen tymczasowy |
| `mosquitto` | `eclipse-mosquitto:2`. Bez konfiguracji działa w trybie local-only; gi-core współdzieli jego przestrzeń sieciową, więc `127.0.0.1:1883` działa (do potwierdzenia w S8). Publikuje Core jako `127.0.0.1::3000` (port efemeryczny, odczyt przez `docker compose port`). |
| `gi-migrate` | build `${GI_BACKEND_DIR}/apps/gi-core`, `target: migrator` (Dockerfile ma ten target, **zweryfikowane**), `DATABASE_URL` ustawione w `environment:` |
| `gi-core` | build `target: production` (bez bind mountu, czyli bez zapisów do folderu backendu), `network_mode: "service:mosquitto"`, `depends_on: gi-migrate (service_completed_successfully)`, `environment:` |
| `fake-esphome` | `tools/fake_esphome` (Dockerfile w repo mobilnym) |

Środowisko `gi-core`:
- `DATABASE_URL` z poprawnym hasłem;
- `JWT_ACCESS_SECRET` (losowy, ≥ 32 znaki). `env.validation.ts` wymaga (`.required()`) tylko `DATABASE_URL` (l.19) i `JWT_ACCESS_SECRET` (l.55), **zweryfikowane**;
- `AUTH_COOKIE_SECURE=false`, `AUTH_COOKIE_SAME_SITE=lax`, `HOST=0.0.0.0`, `SWAGGER_ENABLED=true` (jawnie);
- **bez** `HTTP_PROXY`/`NODE_OPTIONS=--use-env-proxy`.

Uruchomienie: `docker compose -p gi-mobile-contract-<runId> -f contract/compose.contract.yml up -d --build --wait`, a po zakończeniu `down -v`.

Właściwości:
- **Brak przekaźnika.** Bez proxy Core łączy się z `fake-esphome` bezpośrednio przez sieć projektu (adres prywatny IPv4, port 80). `lan-relay` jest zbędny; potwierdza S6.
- **Źródło backendu.** W CI tymczasowy checkout przypiętego ref (`$RUNNER_TEMP/backend`). Lokalnie build czyta `C:\home-energy-poc` tylko do odczytu jako kontekst budowania. Bez bind mountów nic nie jest tam zapisywane. Jeśli pliki robocze dewelopera mają się nie mieszać z przypiętym ref, używamy osobnej kopii w katalogu tymczasowym (§24: źródło ref).
- **Alternatywa awaryjna:** zatrzymać stos dev i uruchomić nakładkę mobilną na bazowym compose ze świeżym wolumenem. Ten wariant kasuje dane dev, więc wymaga jawnej flagi.

**Fake device w stosie deweloperskim** (opcjonalnie, nie w CI). Core dev ma `HTTP_PROXY=http://host.docker.internal:3129`. Kontener z backendowym `lan-http-proxy.mjs` **nie zadziała**, bo skrypt nasłuchuje tylko na `127.0.0.1` wewnątrz kontenera (**zweryfikowane**). Opcje:
- (a) uruchomić skrypt backendu bez zmian **na hoście** (`node C:\home-energy-poc\infrastructure\lan-http-proxy.mjs`, jak robi `make lan-relay-up`). Działa dla prawdziwych urządzeń w LAN, ale nie dla `fake-esphome`, bo host Windows nie routuje do IP mostka Dockera;
- (b) mały relay należący do repo mobilnego, z tymi samymi regułami (tylko prywatne IPv4, tylko port 80), nasłuchujący na `0.0.0.0`, podłączony do `gi-home-energy` i publikujący `127.0.0.1:3129`;
- (c) sidecar socat we wspólnej przestrzeni sieciowej.

**Wszystkie opcje są niezweryfikowane do czasu spike'u S6.** Domyślnie testy z fake device biegną w stosie kontraktowym.

**`tools/seed_core.dart`** (tylko publiczne API, tylko na tymczasowej bazie):
1. `POST /setup/initialize` (tylko przy `initialized:false`)
2. login
3. `POST /users` (ADMIN, USER)
4. `POST /rooms`
5. discover/claim/complete `fake-esphome`
6. `PATCH /devices/:id` (przekaźnik grzewczy, encja temperatury)
7. `PATCH …/control-strategy`

S6 weryfikuje, że urządzenie osiąga ONLINE mimo 404 na `/gi-provision`.

**Strażnik:** zestaw odmawia działania na `initialized:true` bez `--allow-initialized`. Uruchomienie lokalne wymaga jawnego `--tags live`.

**Asercje:**
- `Set-Cookie` i Path. Rotacja z ręcznym `Cookie`. Ponowne użycie starego ciasteczka daje `AUTH_REFRESH_TOKEN_REUSED`.
- Koperta błędu i echo `x-request-id`. 400 przy dodatkowym polu.
- USER dostaje `HTTP_403` na `PUT …/state`.
- Kształt odpowiedzi `control-strategy`. 409 `HEATING_SUSPENDED`.
- **`configurationVersion` rośnie bez zmian użytkownika** (dokumentuje L16).
- Przełącznik fake ON/OFF. CRUD harmonogramów z semantyką dni tygodnia i granicą okna.
- 304 albo jego brak.
- Ścisłe dekodowanie każdego wpisu katalogu.
- Kody statusu z runtime (np. 201/202 tam, gdzie spec mówi 200).
- Sondy funkcji (`HTTP_404` vs `RESOURCE_NOT_FOUND`).

**Ostateczny plan awaryjny:** nagrane fixture'y i ręczna lista sprzętowa.

### 17.4 Fixture'y
Ścieżka: `packages/gi_core_api/test/fixtures/core/<backendRef>/<endpoint>/<case>.json`. Fixture'y GI Edge pochodzą z odczytów GET na Pi (zanonimizowane). Jeśli to niemożliwe, są pisane ręcznie z `gi-edge-heartbeat.service.ts` i oznaczane „synthetic”.

### 17.5 Kontrola dryfu specyfikacji
- `tools/spec_diff.dart` pobiera `/docs-json` z Core **kontraktowego** (lub dev) i porównuje z `contract/openapi/core-<ref>.json`, filtrując do wpisów katalogu.
- Usunięcie elementu lub nowe pole wymagane: błąd. Pozostałe zmiany: ostrzeżenie.
- Nocny canary na najnowszym `main`.

---

## 18. Struktura folderów

### 18.1 Układ repozytorium mobilnego `C:\home-energy-mobile` (osobne repo git)
```
C:\
├─ home-energy-poc\          ← backend: NIE modyfikowany; tylko odczyt i uruchamianie z jego folderu
└─ home-energy-mobile\       ← to repo (git init w istniejącym folderze w M0)
   ├─ README.md              uruchamianie backendu, base URL, zapora, polityka prywatności
   ├─ .fvmrc  pubspec.yaml (pub workspace)  analysis_options.yaml
   ├─ docs/
   │  ├─ decisions/          0001-cookie-refresh … 0009-switch-confirmation-semantics
   │  ├─ backend-contract.md generowany z katalogu
   │  ├─ release-runbook.md  phased release / staged rollout / halt
   │  └─ spikes/             wyniki S1–S8
   ├─ site/                  statyczna strona (GitHub Pages): polityka prywatności, wsparcie, pomoc dot. kont
   ├─ contract/
   │  ├─ backend.lock        przypięty ref backendu (lub hash zawartości, §24)
   │  ├─ openapi/core-<ref>.json
   │  └─ compose.contract.yml   GŁÓWNY runner testów kontraktowych
   ├─ packages/gi_core_api/  czysty Dart: lib/src/{catalog,http,auth,transport,dto,converters,failures,probe}/
   ├─ app/
   │  ├─ lib/{bootstrap,platform,domain,features/*,ui,l10n}/
   │  ├─ assets/{fonts,icons,demo_fixtures}/
   │  ├─ android/ ios/  test/ integration_test/  config/{dev,beta,prod}.json
   ├─ tools/
   │  ├─ backend/compose.override.yml    JUŻ ISTNIEJE: nakładka uruchamiająca niezmieniony Core
   │  ├─ backend/dev-relay/              (opcjonalnie, wariant b z §17.3)
   │  ├─ mock_core/  fake_esphome/ (Dockerfile)  dev_lan_proxy/
   │  ├─ seed_core.dart  spec_diff.dart  import_web_messages.dart
   │  └─ dev-up.ps1 / dev-up.sh          uruchamia backend Z JEGO folderu z nakładką mobilną
   ├─ spikes/
   ├─ fastlane/ (lub codemagic.yaml)
   └─ .github/workflows/{pr,contract,e2e,release}.yml
```
Ścieżka do backendu jest parametrem (`GI_BACKEND_DIR`, domyślnie `..\home-energy-poc`). Nic nie jest kopiowane do backendu.

### 18.2 Jak aplikacja rozmawia z backendem w Dockerze
- **Jedyny kanał to HTTP:** `http://<host>:3000/api/v1/...` w dev i `http://gi-home.local/api/...` na Pi.
- Repo mobilne korzysta z backendu tylko w trzech formach:
  - (1) zmienne środowiskowe runtime, które compose już czyta (`GI_CORE_BIND_ADDRESS`, `GI_CORE_PORT`);
  - (2) nakładka compose w **repo mobilnym**;
  - (3) odczyt plików backendu (kontekst budowania, referencje).
- **Nie zmieniają się żadne śledzone pliki backendu.** Uruchomienie stosu dev z `C:\home-energy-poc` zapisuje wyłącznie artefakty ignorowane przez git:
  - `apps/gi-core/dist`;
  - `apps/gi-core/src/generated/prisma` (z `npx prisma generate` w nakładce);
  - `infrastructure/mosquitto/{data,log}`.

  Bind mount to `../apps/gi-core:/app` (`compose.yml:84-86`). Dlatego nie uruchamiamy drugiego stosu z tego samego folderu jednocześnie, a stos kontraktowy buduje się bez bind mountu.

**Lokalny przebieg pracy:**
1. Backend (z jego folderu, bez zmian w nim):
   ```powershell
   cd C:\home-energy-poc
   docker compose -f infrastructure/compose.yml -f ..\home-energy-mobile\tools\backend\compose.override.yml up -d postgres mosquitto gi-core
   # zdrowie: http://localhost:3000/api/v1/health/live
   # telefon fizyczny w LAN: $env:GI_CORE_BIND_ADDRESS='0.0.0.0' przed komendą
   ```
2. Aplikacja: `cd C:\home-energy-mobile\app; fvm flutter run --flavor dev -t lib/main_dev.dart`. Wybierz preset z §9.6.
3. **Inicjalizacja Core dev** (obecnie `initialized:false`) to decyzja dewelopera: `dart run tools/seed_core.dart --init --base http://localhost:3000`. Narzędzie pyta o potwierdzenie. GI UI `:3001/setup` nie działa z nakładką.
4. Testy kontraktowe: `tools/dev-up.ps1 -Contract` uruchamia `contract/compose.contract.yml` jako osobny projekt i nie dotyka bazy dev.

---

## 19. CI/CD, wydania i sklepy

### 19.1 GitHub Actions w repo mobilnym
1. **PR:** format, analyze, `build_runner`, testy unit/widget/golden, l10n, reguła pokrycia katalogu, zakaz `TODO(backend)`.
2. **contract** (nocny, na żądanie, PR do `packages/gi_core_api/**`): `compose.contract.yml` z tymczasowym checkoutem backendu, różnice specyfikacji, artefakty fixture'ów.
3. **e2e-android** (nocny).
4. **build:** AAB na Linuksie, iOS na macOS (bez podpisu na PR). Kontrola wyrównania 16 KB na buildzie release.

### 19.2 Flavory
| Flavor | Base URL | Przeznaczenie |
|---|---|---|
| `dev` | dowolny, presety z §9.6 | `10.0.2.2` dozwolone, przełącznik mocka, ekran „Funkcje eksperymentalne” |
| `beta` | z ekranu łączenia | TestFlight i Play closed testing |
| `prod` | z ekranu łączenia | sklepy |

Osobne bundle ID. Konfiguracja przez `--dart-define-from-file=config/<flavor>.json`. Brak sekretów w aplikacji.

### 19.3 iOS
Wymaga macOS: Codemagic lub macOS runner (D12). Ścieżkę TestFlight konfigurujemy w M1.

### 19.4 Podpisywanie i wydania
- Fastlane: `match` lub klucz App Store Connect API; upload keystore i Play App Signing.
- Tagi `v*`.
- Każde wydanie zapisuje ref backendu.
- **Wdrażanie stopniowe jako wyłącznik awaryjny:** App Store phased release (7 dni) i Play staged rollout 10% → 50% → 100% z możliwością zatrzymania. Opisane w `docs/release-runbook.md`.

### 19.5 Tryb demo (koniec M2)
- **Po co:** zewnętrzni testerzy TestFlight wymagają Beta App Review, a recenzenci nie dosięgną urządzenia w LAN. Play closed testing ma to samo ograniczenie, a testerzy bez Pi (§19.7) też go potrzebują.
- **Wejście:** widoczny, opisany przycisk „Wypróbuj wersję demonstracyjną” na ekranie łączenia i stały baner „DEMO”. Żadnych ukrytych gestów, które mogłyby naruszyć Guideline 2.3.1.
- **Implementacja:** adapter `HttpClientAdapter` w procesie odtwarza dołączone fixture'y, bez gniazda localhost. Zapisy trafiają do stanu w pamięci.
- Tryb jest opisany w notatkach do review obu sklepów.

### 19.6 Flagi funkcji
Typowany obiekt `FeatureFlags`:
- domyślne wartości per flavor z `--dart-define-from-file`;
- w dev i beta nadpisywane z ukrytego ekranu „Funkcje eksperymentalne”;
- łączone z wynikami sondowania funkcji (§16).

Obejmuje m.in. konwersję czasu harmonogramów (D8), sterowanie przełącznikami per typ integracji i tło (D10). Nie potrzeba usługi zdalnej konfiguracji.

### 19.7 Gotowość do sklepów
- **Konto Google Play (D4, decyzja w M0):**
  - konto organizacji wymaga numeru D-U-N-S, ale nie ma reguły 14 dni;
  - **konto osobiste** wymaga zamkniętego testu z **≥ 12 testerami przez 14 kolejnych dni** przed wnioskiem o dostęp produkcyjny. Wtedy ścieżkę closed testing otwieramy pod koniec M2; testerzy bez Pi używają trybu demo. 14 dni mija w trakcie M3.
- **Kalendarz M4, osobne pozycje:**
  - wniosek o dostęp produkcyjny w Play;
  - Beta App Review;
  - App Review: 1–3 dni plus ewentualna pętla odrzucenia.
- **Prywatność:**
  1. Polityka prywatności i strona wsparcia na statycznej stronie repo mobilnego (`site/`, GitHub Pages), nie na urządzeniu. Polityka mówi, że dane trafiają wyłącznie do własnego urządzenia GI Home użytkownika i w LAN nie są szyfrowane.
  2. Formularz Data safety: brak udostępniania danych; dane logowania trafiają tylko do własnego urządzenia; „encrypted in transit: **No**” (uczciwie).
  3. `Info.plist` `ITSAppUsesNonExemptEncryption=NO`, po potwierdzeniu, że używamy wyłącznie standardowego TLS systemu.
  4. Aplikacyjny `PrivacyInfo.xcprivacy` z UserDefaults (CA92.1) dla `shared_preferences` oraz ewentualnymi powodami file-timestamp i boot-time. Bramka wydania: Xcode „Generate Privacy Report” na archiwum; każda wtyczka ma własny manifest.
  5. Etykieta App Store: brak śledzenia.
- **Konta użytkowników (Apple 5.1.1(v), polityka Google dot. usuwania konta):** w notatkach review i deklaracji Play: „Aplikacja nie tworzy kont; konta istnieją tylko na urządzeniu użytkownika i zarządza nimi właściciel w panelu web urządzenia (Użytkownicy).” Core ma `POST /users` i `DELETE /users/:userId` dla OWNER/ADMIN, ale nie ma samodzielnego usuwania (`users.controller.ts:92,142`, **zweryfikowane**). Strona pomocy w `site/` wyjaśnia usuwanie członka i reset fabryczny.
- **Pozostałe notatki review:** `NSAllowsLocalNetworking`, lokalny cleartext, tryb demo.
- **Minimalne wersje i orientacja:** D13.

---

## 20. Kamienie milowe
Zakładany zespół: 1 senior Flutter, od M2 dodatkowo 0,5 FTE design/QA. Wartości w osobodniach. Każdy kamień milowy kończy się spełnieniem DoD z §17.2 **i** swojej linii Exit.

### M0: Fundamenty i spike'i ryzyka (7–9 d)

| # | Zadanie | Rozmiar |
|---|---|---|
| 1 | **`git init` w istniejącym `C:\home-energy-mobile`** (zachować `tools/backend/compose.override.yml`): FVM, pub workspace, flavory, lint, szkielet CI PR. `compileSdk`/`targetSdk` 36. | 1 d |
| 2 | README i `tools/dev-up.ps1`/`.sh` z komendą nakładki (§18.2); presety base URL (`adb reverse`, `GI_CORE_BIND_ADDRESS=0.0.0.0`, `dev_lan_proxy`) | 0,5 d |
| 3 | Fabryka dio, interceptory nagłówków, `ApiFailure` (w tym `TlsUntrusted`, `RouteAbsent`), TransportPolicy z testami | 1 d |
| 4 | Tokeny motywu, fonty, ikona, pusta powłoka routera | 0,5 d |
| 5 | Spike'i S1–S8 | 3–4 d |
| 6 | ADR-y mobilne 0001–0008 | 0,5 d |
| 7 | Decyzje sklepowe: typ konta Play (D4), konta Apple, bundle ID, nazwa; szkic `site/` | 0,5 d |

| Spike | Procedura | Kryterium wyjścia |
|---|---|---|
| **S1 Auth przez ciasteczko** | Core w Dockerze: login → 50 refreshy → podwójny refresh (oczekiwane REUSED) → zabicie procesu między odpowiedzią a zapisem | §7.4 potwierdzony, test kontraktowy refreshu zielony |
| **S2 Cleartext i sieć lokalna** | iPhone i Android fizyczne: `http://<IP-PC>:3000/api/v1/health/live` (`GI_CORE_BIND_ADDRESS=0.0.0.0`) i `http://gi-home.local/...`. Odmowa na iOS. Android 16 z flagą kompatybilności ochrony sieci lokalnej. Czy ATS/NSC działają z `dart:io`. | Znane sygnatury `LocalNetworkDenied` dla obu platform; wybrany adapter HTTP |
| **S3 `.local`** | `InternetAddress.lookup` na iOS i Android 10/13/14/15, 2 producentów | Macierz; decyzja o fallbacku mDNS |
| **S4 Conditional GET** | `If-None-Match` na `/devices` i `/devices/:id` | 304 tak/nie |
| **S5 Fixture'y i osobliwości** | Seed stosu kontraktowego. Fixture'y MVP. Kształt control-strategy. Stabilność `initializedAt` po `PATCH /settings/system`. Wzrost `configurationVersion` co minutę. Klucze `diagnostics.currentState`/`activeFaults`. Pole odróżniające GI_EDGE od LEGACY. | Fixture'y w repo, pytania z §24 zamknięte lub opisane |
| **S6 Fake device** | `fake_esphome` w `compose.contract.yml` **bez proxy**. Discover/claim/complete, ONLINE mimo 404 `/gi-provision`, przełącznik w obie strony. Opcjonalnie wariant (b) lub (c) dla stosu dev. | Go albo fallback na fixture'y i listę sprzętową |
| **S7 Zegar harmonogramów** | `docker exec <gi-core> date`; na Pi `date` w kontenerze; obserwacja granicy okna | Domyślny zegar (oczekiwane UTC) |
| **S8 Stos kontraktowy w CI** | `compose.contract.yml` na runnerze Linux GitHub: build `migrator`/`production`, mosquitto local-only z gi-core we wspólnej przestrzeni sieciowej, Swagger dostępny, port efemeryczny. Lokalnie obok działającego stosu dev, bez kolizji. | Zielony bring-up równolegle ze stosem dev |

**Exit M0:**
- zielony test kontraktowy auth na `compose.contract.yml` obok działającego stosu dev;
- spisane wyniki spike'ów;
- odpowiedzi na D1–D8 i D4.

### M1: „Łączę się, loguję i widzę, czy w domu wszystko OK” (9–11 d)

| # | Zadanie | Rozmiar |
|---|---|---|
| 1 | `gi_core_api`: katalog MVP, DTO z fixture'ów, testy kluczy, konwertery | 2 d |
| 2 | `AuthSessionManager`, codec ciasteczek, `VaultResult` (wipe po reinstalacji, wyłączenie z kopii), pełny pakiet testów awarii | 2,5 d |
| 3 | Łączenie: normalizator, drabina, karta potwierdzenia, odcisk, profil (zastąpienie po potwierdzeniu przy D1 = A), przekazanie do web | 1,5 d |
| 4 | Guardy routera; logowanie i zmiana hasła z autofill; wylogowanie; „Zmień użytkownika”; bootstrap języka | 1,25 d |
| 5 | Poller zależny od cyklu życia; Dom (kondycja z listy, uwagi, urządzenia wg pokoi, karta ogrzewania tylko dla widocznych); Szczegóły tylko do odczytu, ze scaleniem `currentState`/`activeFaultCount` z listy | 2 d |
| 6 | Handlery błędów Dart, bufor pierścieniowy, liczniki, „Wyślij raport diagnostyczny”; snapshot/logi w Application Support | 0,5 d |
| 7 | ARB pl/en, goldeny; pipeline'y Codemagic/TestFlight internal i Play internal | 1 d |

**Exit M1:**
- build wewnętrzny na telefonie właściciela pokazuje prawdziwe dane z Pi lub ze stosu dev;
- konto USER widzi kompletną aplikację tylko do odczytu;
- testy awarii auth i `VaultResult` zielone;
- Dom bez żądań szczegółów dla urządzeń niegrzewczych (test liczby żądań).

### M2: „Bezpiecznie steruję ogrzewaniem”, MVP wewnętrzne (10–12 d)

| # | Zadanie | Rozmiar |
|---|---|---|
| 1 | `SafetyPolicy` i `ConfirmationPolicy` z testami; bramkowanie `can()`, PermissionState | 1 d |
| 2 | Maszyna stanów przełącznika; potwierdzenie GI_EDGE tylko przez `lastSeenAt` urządzenia > `confirmedAt` (fixture optymistycznego zapisu); kody błędów; dry-run; przekaźniki kotła i pompy tylko do odczytu; blokada przy nieaktualnych danych | 2 d |
| 3 | Karta ogrzewania: wartość efektywna vs bazowa, PV-boost, wskazówka „Harmonogram aktywny” (bez nazwy) | 0,75 d |
| 4 | Edytor strategii z konfliktem wykrywanym po wartościach bazowych i `heatingSuspended`; model odpowiedzi runtime | 1,5 d |
| 5 | Przytrzymaj-aby-wstrzymać, arkusz wznowienia, baner, ukryte akcje ON | 1 d |
| 6 | Ustawienia: język, informacje o urządzeniu, HTTP, wygaśnięcie sesji, wylogowanie | 0,5 d |
| 7 | **Tryb demo** (adapter w procesie, widoczne wejście, baner) | 1,5 d |
| 8 | Testy kontraktowe ścieżek sterowania; E2E na emulatorze | 1,5 d |
| 9 | Dystrybucja wewnętrzna; przegląd bezpieczeństwa (`docs/safety.md`, PRD §8.6/§10.4); przy koncie osobistym Play otwarcie closed testing z ≥ 12 testerami | 0,75 d |

**Exit M2 (MVP w ręku właściciela, ok. 27–33 osobodni):**
- G2 i G3 spełnione testami;
- przegląd bezpieczeństwa zaliczony;
- tryb demo przechodzi E2E;
- build beta zaakceptowany w TestFlight (internal) i Play (internal lub closed).

### M3: Codzienny komfort i kompletność konta (12–15 d)

| # | Zadanie | Rozmiar |
|---|---|---|
| 1 | Harmonogramy: lista, przełącznik, CRUD; `ApiWeekday`; `ScheduleClock` (replika `windowMatches`, nazwa i koniec aktywnego harmonogramu z etykietą „wywnioskowane”); podwójny czas; opcjonalna edycja w czasie domu z banerem zmiany czasu; ostrzeżenie o nakładaniu się okien | 3,5 d |
| 2 | Pogoda, słońce, PV (ikony met.no z `weather-icons.ts`), stany stale/503; plan PV | 2 d |
| 3 | Historia: `fl_chart`, 1 h/6 h/24 h, 7 d stronicowane, LTTB w izolacie, wykres schodkowy; **Semantics i „Pokaż jako tabelę”** | 3 d |
| 4 | Uwaga i plakietka; ETag (jeśli S4); trwały snapshot | 1 d |
| 5 | Profil, język z serwera, zmiana hasła; sesje (oznaczenie „ten telefon”, unieważnianie, logout-all, usunięcie starej sesji po logowaniu); reset kodem; regeneracja z sejfem i ochroną ekranu i schowka | 2,5 d |
| 6 | Sondowanie funkcji (§16); best-effort `runningVersion` | 0,5 d |
| 7 | (tylko przy D1 = B) lista profili: dodaj, zmień nazwę, przełącz, usuń z czyszczeniem; polling, snapshot i Uwaga tylko dla aktywnego profilu; nazwa profilu w pasku aplikacji | 1 d |
| 8 | Fixture'y, testy kontraktowe, goldeny | 0,5–1 d |

**Status M3 (2026-11-22, gałąź `feat/m3`):**

| # | Status |
|---|---|
| 1 | Zrobione: `ApiWeekday`, `ScheduleClock`, CRUD, ostrzeżenie o nakładaniu, podwójny czas; konwersja na czas domu za flagą `scheduleClockConversion` (ADR [0010](decisions/0010-schedule-clock-utc.md)) |
| 2 | Zrobione: pogoda, słońce, PV, plan PV; kształty 200 tylko z fixture'ów `_handwritten` (stos kontraktowy nie ma lokalizacji) |
| 3 | Zrobione: LTTB w izolacie, wykres schodkowy, tabela, 7 d w plastrach dobowych (ADR [0011](decisions/0011-history-lttb-step-chart.md)) |
| 4 | Zrobione: Uwaga, ETag za flagą `conditionalGet` (ADR [0012](decisions/0012-etag-non-authoritative-cache.md)), snapshot |
| 5 | Zrobione: sesje, logout-all, reset, regeneracja z ochroną ekranu (ADR [0014](decisions/0014-recovery-code-secure-display.md)), profil i język |
| 6 | Zrobione: sondowanie funkcji (ADR [0013](decisions/0013-feature-probing.md)), `runningVersion` |
| 7 | Poza zakresem: D1 = A (jeden profil) |
| 8 | Zrobione: fixture'y, testy kontraktowe, goldeny |

Zablokowane poza repozytorium: **pomiar historii 7 d na fizycznym Androidzie** (benchmark `app/integration_test/perf/history_7d_benchmark_test.dart` jest gotowy, wynik z urządzenia czeka na telefon; benchmark hosta `lttb_benchmark_test.dart` przechodzi) oraz **zamknięty test Play** (≥ 12 testerów przez 14 dni wymaga konta Play i testerów; decyzja właściciela, nie kod).

**Exit M3:**
- CRUD harmonogramów przechodzi pełny cykl na Core w Dockerze;
- `ApiWeekday` i `ScheduleClock` zweryfikowane na granicy okna;
- historia 7 d renderuje się w ≤ 3 s na średniej klasy Androidzie;
- przy koncie osobistym Play trwa 14-dniowy zamknięty test z ≥ 12 testerami.

### M4: Utwardzenie i gotowość do sklepów, v1.0 (8–10 d plus czas oczekiwania w sklepach)

| # | Zadanie | Rozmiar |
|---|---|---|
| 1 | Dostępność: Semantics, skala tekstu do 200% na wszystkich głównych ekranach, kontrast, 48 dp, `meetsGuideline`; audyt stanów PRD §6.4 | 1,5 d |
| 2 | Zmiany sieci, backoff, ponowne wiązanie IP, fallback mDNS (jeśli S3); żądanie `NEARBY_WIFI_DEVICES` | 1 d |
| 3 | Test obciążenia: 3 telefony + web przez 30 min na Pi; budżet z §11 | 0,5 d |
| 4 | Gotowość sklepowa: `site/` (prywatność, wsparcie, konta), Data safety, `ITSAppUsesNonExemptEncryption`, `PrivacyInfo.xcprivacy` z raportem prywatności, wyrównanie 16 KB, golden tabletowy, notatki review (demo, konta, cleartext), przypięcie ref backendu, deklaracja kompatybilności | 2 d |
| 5 | Beta z 3–5 gospodarstwami na prawdziwych Pi; cotygodniowe raporty diagnostyczne | 2–3 d |
| 6 | Kalendarz: wniosek o dostęp produkcyjny w Play, Beta App Review, App Review (1–3 d plus ewentualna pętla odrzucenia); `docs/release-runbook.md` (phased/staged, halt) | 1 d pracy + czas oczekiwania |

**Exit M4 (v1.0):**
- zimny start do kondycji domu ≤ 5 s (p90 z 20 uruchomień: Pi w LAN, 10 urządzeń, trace z `integration_test`);
- sesje bez awarii ≥ 99,5% przez ≥ 14 dni bety;
- wymuszone ponowne logowanie < 1% sesji (raporty diagnostyczne);
- budżet obciążenia spełniony (≤ 12 żądań/min na Domu, ≤ 30 na szczegółach, CPU gi-core < 50%);
- ścieżki „logowanie”, „wstrzymanie ogrzewania”, „zmiana celu” i „odczyt historii” wykonane przez testera z VoiceOver (pl) i TalkBack (pl), zapisane w liście kontrolnej wydania;
- oba zgłoszenia do sklepów zaakceptowane.

**Status realizacji M4 (2026-11-22):** nic poniżej nie jest oznaczone jako zmierzone, jeśli nie zostało zmierzone. Szczegóły i dowody: [lista wyjścia M4](templates/m4-exit-checklist.md). Przekazanie: [m4-handoff.md](m4-handoff.md).

| Kryterium Exit M4 | Status | Artefakty |
|---|---|---|
| budżet żądań na Domu i szczegółach | zrobione (automatycznie, test budżetu) | [load-budget.md](load-budget.md), [ADR 0016](decisions/0016-home-card-cadence-request-budget.md) |
| skala tekstu 200%, 48 dp, kontrast, audyt stanów | zrobione (automatycznie); zrzuty Linux do ponownego nagrania z CI | [state-audit.md](state-audit.md), [ADR 0017](decisions/0017-accessibility-verification-strategy.md) |
| zmiany sieci bez ponawiania zapisów | zrobione (automatycznie); mDNS za flagą do wyniku S3 | [ADR 0015](decisions/0015-network-change-no-write-replay.md) |
| artefakty sklepowe i prywatności | przygotowane; raport prywatności Xcode, dane operatora i konsole sklepów czekają | [docs/store](store/review-notes.md), [compatibility.md](compatibility.md) |
| zimny start p90 ≤ 5 s, CPU gi-core < 50% | przygotowane, zablokowane (Pi i telefon) | [cold-start-p90](templates/cold-start-p90.md), [raport obciążenia](templates/load-test-pi-report.md) |
| VoiceOver i TalkBack (pl) | przygotowane, zablokowane (urządzenia i tester) | [lista wydania](release-checklist.md) |
| sesje bez awarii, wymuszone logowanie | przygotowane, zablokowane (beta 14 dni) | [runbook, sekcja 8](release-runbook.md), [ADR 0018](decisions/0018-beta-programme-and-metrics.md) |
| oba zgłoszenia zaakceptowane | przygotowane, zablokowane (sklepy) | [runbook, sekcja 7](release-runbook.md) |

**Sumy:**
- MVP: ok. 27–33 osobodni (koniec M2);
- v1.0: ok. 48–59 osobodni, czyli ok. 10–13 tygodni kalendarzowych dla jednej osoby, plus czas oczekiwania na review. Przy koncie osobistym Play 14-dniowy test musi się zakończyć przed wnioskiem o produkcję, więc zaczynamy go w M2.

### Backlog v1.1+ (w kolejności)
1. Automatyzacje
2. Pokoje
3. Plakietka aktualizacji
4. Biometria
5. Widgety (bez sterowania; D14)
6. Tło i lokalne powiadomienia (D10)
7. Przeszukiwanie /24
8. TOFU HTTPS
9. Wiele urządzeń GI Home (jeśli D1 = A)
10. Spike R1
11. Natywny kreator
12. Onboarding ESPHome

---

## 21. Ograniczenia wynikające z niezmiennego backendu

> Backend GI Core zostaje dokładnie taki, jaki jest. Poniższe ograniczenia są świadomie zaakceptowane. Każde ma obejście po stronie aplikacji albo jest jawnie wyłączone z zakresu. **Żadne nie jest planowane jako praca w backendzie.**

| # | Ograniczenie | Źródło | Obejście po stronie klienta / skutek widoczny dla użytkownika |
|---|---|---|---|
| L1 | Refresh token tylko jako ciasteczko HttpOnly; brak natywnego przepływu (wbrew intencji ADR 006) | `auth.controller.ts:79-83,128-135` | Ręczne parsowanie `Set-Cookie`, wybór po Path, secure storage; `REFRESH_COOKIE_MISSING` |
| L2 | Rotacja bez okna łaski; ponowne użycie unieważnia sesję | `auth.service.ts:188-220` | Jeden właściciel, pojedynczy lot, write-ahead, brak refreshu w tle. **Sporadyczne wymuszone logowanie przy niestabilnym Wi-Fi pozostaje możliwe.** |
| L3 | Sesja 30 dni bezwzględnie | `:228-231` | Baner od T-3 dni, szybkie ponowne logowanie |
| L4 | Limit 10 sesji wspólny z web, ciche usuwanie najstarszej | `:85-108` | Wyjaśniający komunikat, ekran Sesje |
| L5 | `/auth/logout` wymaga Bearer | `auth.controller.ts:139-152` | Refresh, potem logout; zawsze lokalne czyszczenie |
| L6 | Sesje bez metadanych urządzenia | `prisma/schema.prisma` | Opisowy User-Agent, `sessionId` z JWT |
| L7 | `mustChangePassword` nieegzekwowane przez serwer | — | Guard routera |
| L8 | Setup publiczny, bez limitu żądań, kto pierwszy ten właściciel, cleartext | `setup.controller.ts` | Przekazanie do web |
| L9 | Brak push, alertów i strumienia zdarzeń | — | Lista Uwaga; opcjonalne lokalne sprawdzanie |
| L10 | Brak wartości w czasie rzeczywistym; SSE tylko ze statusem i tylko dla O/A | `esphome-telemetry-stream.service.ts` | Polling 2–30 s |
| L11 | Lista nie zawiera encji ani strategii | `device-response.mapper.ts:10-20` | Typ urządzenia, wstrzymanie, dry-run, `currentState` i usterki z listy; szczegóły tylko dla widocznych kart ogrzewania |
| L12 | USER tylko do odczytu; brak zakresowych uprawnień | `@Roles` | „Tylko podgląd”; właściciel może nadać ADMIN |
| L13 | Brak stabilnego ID; `gi-home.local` nieunikalne; brak DNS-SD | `mdns-responder/entrypoint.sh` | Warstwowe wykrywanie, wpis ręczny, odcisk (poprawność, nie bezpieczeństwo) |
| L14 | LAN tylko po HTTP; urządzenia nie da się uwierzytelnić | Pi :80 | TransportPolicy, potwierdzenie, odcisk, komunikat. **Dane logowania mogą zostać podsłuchane we wrogiej sieci.** Deklarujemy to w Data safety. |
| L15 | Zapisywalne tylko boolowskie przełączniki; GI_EDGE bez ID polecenia i z optymistycznym zapisem encji; brak potwierdzenia fizycznego i resetu usterek | `esphome-switch-command.service.ts:249-296` | Potwierdzenie tylko przez `lastSeenAt` urządzenia > `confirmedAt` lub dane z firmware; inaczej „czeka na potwierdzenie”; brak przycisku reset |
| L16 | Brak If-Match; `configurationVersion` rośnie co minutę przez cron | `heating-schedule-reconciliation.service.ts:63,108,145` | Konflikt wykrywany po wartościach bazowych i `heatingSuspended`; pozostałe PATCH-e działają na zasadzie last-write-wins |
| L17 | Harmonogramy na zegarze procesu gi-core (prawdopodobnie UTC); API nie mówi, który harmonogram jest aktywny | `:164-169` | Zegar harmonogramów, podwójne etykiety, wnioskowanie po stronie klienta („wywnioskowane”). **Skonwertowane harmonogramy przesuwają się przy zmianie czasu.** |
| L18 | Historia bez agregacji, ucina **najnowsze** próbki | `history.service.ts:110-121` | Okna, LTTB, komunikat o ucięciu |
| L19 | OpenAPI niepełne lub błędne; Swagger wyłączony w profilu `infrastructure/release` i nieroutowany na Pi; brak endpointu wersji dla wszystkich ról | `main.ts`, `env.validation.ts:53` | Ręczne modele, fixture'y, testy kontraktowe na Core dev/kontraktowym; best-effort `runningVersion` (OWNER/ADMIN, bez bramkowania); sondowanie funkcji przez `HTTP_404` |
| L20 | Decimal i BigInt jako stringi; część walidacji kończy się 500 | `settings.service.ts` | Tolerancyjne konwertery, walidacja po stronie klienta |
| L21 | Brak przepływu energii na żywo i klimatu pokoi | `docs/ui-api-coverage.md` | Tylko prognoza i plan PV |
| L22 | Zdalny dostęp: wyłączony domyślnie, dwa logowania, buforowany tunel, błędy HTML, ryzyko podszycia | gi-cloud/gi-relay | **Brak zdalnego dostępu w v1** |
| L23 | `message` ogólny; RBAC i limit żądań jako `HTTP_403`/`HTTP_429` | `api-message.ts` | Własna tabela kod → pl/en |
| L24 | Limit logowania w pamięci, per IP | `auth.module.ts:13` | Odliczanie; telefony za NAT mogą się nawzajem blokować |
| L25 | `recovery/regenerate` bez ponownego podania hasła | `auth.controller.ts:87` | Potwierdzenie lokalne, sejf z ochroną ekranu (UX, nie zabezpieczenie) |
| L26 | Brak zaproszeń i samodzielnego usuwania konta | `users.controller.ts:92-145` | Zmiana hasła przy pierwszym logowaniu; zarządzanie kontami w panelu web; deklaracje sklepowe |
| L27 | Szczegóły urządzenia bez `currentState`/`activeFaultCount` | `device-details-query.service.ts:44-89` | Scalanie z listy, pokazane źródło i świeżość |
| L28 | Lokalne uruchomienie Core wymaga nakładki (MQTT na 127.0.0.1, Prisma, migracje); dev GI UI nie działa z nakładką | `main.ts:76`, `compose.yml:87` | Nakładka w repo mobilnym; setup w dev przez `seed_core --init` |

---

## 22. Ryzyka

| Ryzyko | P / wpływ | Mitygacja |
|---|---|---|
| Przypadkowe wylogowania (L2) | Średnie / Wysoki | §7.4, S1, testy awarii, liczniki przyczyn w raportach diagnostycznych |
| Fałszywe „Potwierdzone” dla GI_EDGE | Średnie / Krytyczny | Reguła z §12.2, test fixture, lista sprzętowa |
| Pomylenie stanu zleconego z fizycznym | Średnie / Krytyczny | Komunikaty, goldeny, przegląd bezpieczeństwa w M2 |
| Fałszywe konflikty strategii | Wysokie (gdyby porównywać wersję) / Średni | Porównanie wartości (§12.5) |
| Przesunięcie zegara harmonogramów (L17) | Wysokie, jeśli UTC / Średni | S7, etykiety, opcjonalna konwersja |
| Odmowa sieci lokalnej na iOS/Androidzie 16+ albo awaria `.local` | Wysokie / Średni | Wpis ręczny zawsze widoczny, S2, S3, przygotowane `NEARBY_WIFI_DEVICES` |
| Stos kontraktowy nie wstaje (targety Dockerfile, mosquitto local-only) | Średnie / Średni | S8; awaryjnie zatrzymany stos dev i nakładka |
| Fake device nie działa | Średnie / Niski | S6; fixture'y i lista sprzętowa |
| Dryf kontraktu po aktualizacji Core | Średnie / Średni | Tolerancyjne dekodowanie, nocny canary, sondy funkcji, „Zaktualizuj aplikację” |
| Obciążenie Pi | Niskie–średnie / Średni | Budżet z §11, pomiar w M4 |
| Brama 12 testerów / 14 dni w Play | Wysokie przy koncie osobistym / Wysoki | D4 w M0, closed testing od końca M2 |
| Odrzucenie w review (LAN, cleartext, ukryte funkcje, konta, prywatność) | Średnie / Średni | Widoczny tryb demo, notatki, `site/`, Data safety, manifest prywatności |
| Brak danych o jakości bety | Średnie / Średni | §8.4, raporty co tydzień |
| Awaria Keystore/Keychain | Niskie / Średni | `VaultResult` |
| Wyciek kodu odzyskiwania przez zrzut ekranu lub schowek | Niskie / Wysoki | §7.7 |
| Brak macOS | Pewne / Średni | Codemagic od M1 |
| Testy kontraktowe zmieniają backend dewelopera | Niskie / Niski | Osobny projekt bez bind mountu, strażnik `initialized` |
| Rozczarowanie roli USER | Wysokie / Średni | Komunikaty |

---

## 23. Decyzje do podjęcia
Każda ma proponowaną wartość domyślną, żeby nie blokować startu. **Żadna nie wymaga zmian w backendzie.**

| ID | Pytanie | Propozycja domyślna |
|---|---|---|
| D1 | Wiele urządzeń GI Home w v1? | **A:** dokładnie jeden profil; wybór innego zastępuje profil po potwierdzeniu i czyści dane. **B (alternatywa):** lista profili w M3 (+1 d), polling i Uwaga tylko dla aktywnego. |
| D2 | Odbiorcy v1 | OWNER/ADMIN sterują; USER i SERVICE tylko podgląd (SERVICE czyta strefę z `/settings/system`) |
| D3 | Zapisywać 15-minutowy access token? | Tak |
| D4 | Typ konta Google Play | Do decyzji w M0. Organizacja (D-U-N-S, bez reguły 14 dni) albo osobiste (closed test ≥ 12 testerów × 14 dni od końca M2). |
| D5 | Dystrybucja, konta Apple, bundle ID, nazwa „GI Home” | Wewnętrznie w M2, w sklepach w v1.0 |
| D6 | Zdalny dostęp w 1.x? | Nie |
| D7 | Natywny kreator setupu | Nie; przekazanie do web |
| D8 | Domyślny zegar harmonogramów i konwersja | Z S7 (oczekiwane UTC); tylko etykieta; konwersja opt-in |
| D9 | Ręczne przełączanie przekaźników kotła i pompy | Nigdy w v1 |
| D10 | Lokalne powiadomienia w tle | v1.1 opt-in, najpierw Android |
| D11 | Motyw | Tylko ciemny |
| D12 | CI dla iOS | Codemagic |
| D13 | Minimalne OS, target i orientacja | iOS 15+, tylko iPhone, portret; Android API 26+, targetSdk 36, poziom na ≥ 600 dp |
| D14 | Awaryjne wstrzymanie z widgetu | Nie; tylko deep link |
| D15 | Przypięty ref backendu do testów kontraktowych | Ref wdrożony na Pi; zmiana przez PR |
| D16 | Ograniczenia UI | Cel 5–80 °C; potwierdzenie przy +10 °C |
| D17 | Wpis IP na Androidzie (permisywny `base-config`) | Tak, z TransportPolicy |
| D18 | Zdalne raportowanie awarii (np. self-hosted Sentry) | Nie; tylko raport wysyłany przez użytkownika |
| D19 | Hosting polityki prywatności i wsparcia | GitHub Pages repo mobilnego (`site/`) |
| D20 | Fake device w stosie dev (relay b/c) czy tylko w kontraktowym | Tylko w kontraktowym; wariant (b) jako opcja |

---

## 24. Pytania otwarte (niezweryfikowane; do zamknięcia w spike'ach lub przed startem)

> Odpowiedzi ze spike'ów M0 (pkt 2, 4–8, 10, 11): [docs/spikes/README.md](spikes/README.md#odpowiedzi-na-pytania-z-24).

1. **Źródło przypiętego ref backendu.** *(Rozstrzygnięte.)* `C:\home-energy-poc` to klon `https://github.com/biQte/home-energy-poc.git`, gałąź `main`. Plan był pisany pod commit `8be59cd907df1af964a817331edbcf8e1597d3e2`; ten SHA trafia do `backend.lock`. Do rozstrzygnięcia zostaje tylko, czy CI repo mobilnego ma dostęp do tego repozytorium (publiczne czy wymaga tokenu).
2. Czy target `production` z `NODE_ENV=production` wystawia `/docs-json` przy `SWAGGER_ENABLED=true` i czy mosquitto bez konfiguracji (local-only) wystarcza dla gi-core we wspólnej przestrzeni sieciowej? (S8)
3. ~~Czy z odpowiedzi szczegółów da się odróżnić GI_EDGE_V1 od LEGACY_ESPHOME i czy heartbeat GI Edge aktualizuje `Device.lastSeenAt`?~~ *(Rozstrzygnięte w M2, odczyt kodu.)* Tak i tak: `communicationMode` jest w szczegółach (`device-details-query.service.ts:54`), a każdy heartbeat (HTTP i MQTT) zapisuje `Device.lastSeenAt` zegarem serwera (`gi-edge-heartbeat.service.ts`). Klucze przekaźników: `diagnostics.relayN.{output, commanded}`. Zostaje potwierdzenie na prawdziwym sterowniku (lista sprzętowa §17.1). Zob. §12.2 i ADR [0009](decisions/0009-switch-confirmation-semantics.md).
4. Nazwy kluczy w `diagnostics` dla `currentState`/`activeFaults`. (S5) Część o przekaźnikach *(rozstrzygnięta w M2)*: `diagnostics.relayN.{output, commanded}`, zob. pkt 3.
5. Czy `GET /devices`, `/devices/:id` zwracają ETag i 304? (S4)
6. Czy odpowiedź 429 zawiera `Retry-After`?
7. Czy `initializedAt` jest stabilne po `PATCH /settings/system`? (S5)
8. Strefa czasowa procesu gi-core na Pi i w dev. (S7)
9. Kształt `GET /appliance/updates/status` na Pi (`lastCheck.services[].runningVersion`) i w dev (`configured:false`), wg odczytu `appliance-update.service.ts:51-63`. Do potwierdzenia fixturem.
10. Czy pogoda i PV w Core dev działają przez `HTTP_PROXY` na `host.docker.internal:3129` bez działającego relay? W stosie kontraktowym nie ma proxy. Testy pogody tolerują 503.
11. Czy `status` z listy przyjmuje wartości poza ONLINE/OFFLINE (np. STALE)? Wpływa na porównanie z regułą web.
12. Dokładny termin wymuszenia ochrony sieci lokalnej w Androidzie i aktualny wymagany targetSdk w Play (potwierdzić w M0).
13. Czy wariant (b) relay dla stosu dev przechodzi przez `host.docker.internal` przy Core we wspólnej przestrzeni sieciowej z mosquitto? (S6, tylko jeśli D20 tego wymaga)
