# Środowisko deweloperskie

# Wymagania

- **Flutter 3.50.0** (stable, Dart 3.14) przez [FVM](https://fvm.app): wersję
  przypina `.fvmrc` (śledzony przez git), a CI czyta ją z tego samego pliku.
  Jednorazowo:

  ```sh
  dart pub global activate fvm   # instaluje FVM
  fvm install                    # w katalogu głównym repo: pobiera SDK z .fvmrc
  ```

  `fvm install` tworzy też link `.fvm/flutter_sdk` (katalog `.fvm/` jest
  ignorowany przez git; gdyby linku brakowało, odtwarza go `fvm use 3.50.0`),
  na który wskazuje `.vscode/settings.json` (`dart.flutterSdkPath`). Komendy `flutter`
  i `dart` z tego dokumentu uruchamiaj jako `fvm flutter …` / `fvm dart …`;
  globalny `flutter` z `PATH` może mieć inną wersję i nie rozwiąże zależności
  (`sdk: ^3.14.0`).
- **Docker** z Compose v2 (Docker Desktop na Windows/macOS).
- Checkout backendu obok tego repo: `..\home-energy-poc` (inną ścieżkę podaje
  się w `GI_BACKEND_DIR`).
- W backendzie plik `apps/gi-core/.env` (ignorowany przez git, wymagany przez
  compose backendu). Tworzy się go z `apps/gi-core/.env.example` zgodnie z
  README backendu; `DATABASE_URL` musi używać hasła Postgresa z
  `infrastructure/compose.yml`. Skrypty z tego repo tego pliku nie tworzą.
- Android SDK i emulator lub telefon; dla iOS Xcode na macOS.

# Backend GI Core w Dockerze

Bazowy compose backendu sam w sobie nie daje działającego Core (MQTT na sztywno
pod `127.0.0.1:1883`, bind mount ukrywający klienta Prisma, brak migracji).
Nakładka [`tools/backend/compose.override.yml`](../tools/backend/compose.override.yml)
naprawia to bez zmian w backendzie: gi-core dzieli przestrzeń sieciową z
mosquitto, a port 3000 publikuje kontener mosquitto. Szczegóły są w nagłówku
nakładki i w planie (§3.9, §18.2).

## Jedną komendą

```powershell
.\tools\dev-up.ps1            # podnosi postgres, mosquitto, gi-core i czeka na /health/live
.\tools\dev-up.ps1 -Seed      # j.w. + tools/seed_core.dart --init --allow-initialized
.\tools\dev-up.ps1 -Lan       # GI_CORE_BIND_ADDRESS=0.0.0.0 (telefon fizyczny w LAN)
```

```sh
tools/dev-up.sh [--seed] [--lan] [--port 3000] [--timeout 600] [--backend-dir ../home-energy-poc]
```

Skrypty uruchamiają compose z folderu backendu, czekają na
`http://127.0.0.1:3000/api/v1/health/live` (pierwszy start robi `npm ci`, więc
może to potrwać kilka minut) i wypisują presety adresów. Ponowne uruchomienie
jest bezpieczne: `up -d` nie rusza usług o niezmienionej konfiguracji. Zmiana
`-Lan`/`--lan` albo portu na działającym stosie odtwarza kontenery.

## Ręcznie

```powershell
cd C:\home-energy-poc
docker compose -f infrastructure/compose.yml -f ..\home-energy-mobile\tools\backend\compose.override.yml up -d postgres mosquitto gi-core
# zdrowie: http://localhost:3000/api/v1/health/live, Swagger: http://localhost:3000/docs
# telefon fizyczny w LAN: $env:GI_CORE_BIND_ADDRESS='0.0.0.0' przed komendą
```

Zatrzymanie: ta sama komenda z `stop` zamiast `up -d ...` (`down -v` kasuje też
bazę dev). Uruchomiony stos zapisuje w folderze backendu tylko pliki, które
backend już ignoruje: `apps/gi-core/dist`, `apps/gi-core/src/generated/prisma`,
`infrastructure/mosquitto/{data,log}`. Nie uruchamiaj drugiego stosu z tego
samego folderu backendu (stałe nazwy kontenerów, sieci i porty).

Panel web GI UI (`:3001/setup`) **nie działa** z nakładką, dlatego Core dev
inicjalizuje się seederem.

## Stos kontraktowy (obok stosu dev)

[`contract/compose.contract.yml`](../contract/compose.contract.yml) to osobny,
jednorazowy projekt compose (plan §17.3, spike S8): GI Core zbudowany z
folderu backendu (target `migrator` i `production`, tylko do odczytu, bez bind
mountów), własny Postgres na tmpfs, mosquitto nasłuchujący tylko na
`127.0.0.1` we wspólnej przestrzeni sieciowej z gi-core oraz udawany sterownik
[`tools/fake_esphome`](../tools/fake_esphome). Nie ma stałych nazw kontenerów ani
portów hosta: Core dostaje efemeryczny port na `127.0.0.1`, więc działa
równolegle ze stosem dev (i z innymi stosami kontraktowymi). Bez reverse
proxy, Home Assistant i GI UI.

```powershell
.\tools\dev-up.ps1 -Contract -Seed            # nowy projekt gi-mobile-contract-<losowe id>
.\tools\dev-up.ps1 -Contract -RunId a -Seed   # albo z własnym id
# ... wypisuje GI_CORE_URL=http://127.0.0.1:<port> i FAKE_ESPHOME_URL=...
.\tools\dev-up.ps1 -Contract -RunId a -Down   # docker compose ... down -v
```

```sh
tools/dev-up.sh --contract [--run-id a] [--seed]
tools/dev-up.sh --contract --run-id a --down
```

Ręcznie to dokładnie:

```sh
docker compose -p gi-mobile-contract-a -f contract/compose.contract.yml up -d --build --wait
docker compose -p gi-mobile-contract-a port mosquitto 3000     # 127.0.0.1:<port>
dart run tools/seed_core.dart --base-url http://127.0.0.1:<port> --init --yes
docker compose -p gi-mobile-contract-a -f contract/compose.contract.yml down -v
```

- Folder backendu: `GI_BACKEND_DIR` (domyślnie `../home-energy-poc` obok tego
  repo); przypięty ref jest w [`contract/backend.lock`](../contract/backend.lock).
- Środowisko Core jest w [`contract/contract.env`](../contract/contract.env): same
  wartości testowe, Swagger włączony (`/docs`, `/docs-json`), bez `HTTP_PROXY`.
- `fake-esphome` jest osiągalny dla Core pod `fake-esphome:80` (DNS Dockera,
  prywatny IPv4). Wykrywanie mDNS nie jest używane; seeder idzie ścieżką
  ręcznego hosta (discover/claim/complete). Stos dev **nie** widzi tego
  urządzenia (D20), więc tam seeder pomija kroki 5-7 z ostrzeżeniem.
- Pierwszy build obrazów trwa kilka minut; kolejne starty kilkanaście sekund
  (pomiary w [`docs/spikes/s8-contract-stack.md`](spikes/s8-contract-stack.md)).

## Inicjalizacja i dane demo

```sh
dart run tools/seed_core.dart --init                 # z katalogu głównego repo; pyta y/N
dart run tools/seed_core.dart --base-url http://localhost:3000 --init --allow-initialized
dart run tools/seed_core.dart --base-url <GI_CORE_URL> --init --yes   # stos kontraktowy (CI)
dart run tools/seed_core.dart --base-url <GI_CORE_URL> --fixtures --allow-initialized
dart run tools/seed_core.dart --help
```

Kroki (plan §17.3), każdy idempotentny:

1. `POST /setup/initialize`, tylko z `--init` i tylko przy `initialized:false`.
   Pierwszy wywołujący zostaje właścicielem, więc seeder najpierw pyta y/N
   (`--yes` pomija pytanie).
2. Logowanie właściciela z `tools/backend/dev.env`.
3. `POST /users`: konta ADMIN i USER z
   [`tools/seed_accounts.example.json`](../tools/seed_accounts.example.json)
   (albo z `tools/seed_accounts.json`, gitignored, jeśli istnieje).
4. Pokoje „Salon” i „Kotłownia” oraz trzy urządzenia demo (po nazwach).
5. discover/claim/complete urządzenia `fake-esphome` (`--fake-device <host>`,
   `--fake-device none` pomija kroki 5-7), potem pierwsza synchronizacja.
6. `PATCH /devices/:id` (przekaźnik grzania, encja temperatury) i role encji
   (bez nich szczegóły urządzenia mówią `needs_configuration` zamiast `online`).
7. `PATCH /devices/:id/control-strategy`: 55 °C, histereza 4 °C, tryb `MANUAL`
   (pętla histerezy Core działa tylko w `AUTO`, więc przekaźnik rusza się tylko
   na polecenie).

- **Strażnik:** wszystko, co pisze do Core, który już jest zainicjalizowany
  (`--init`, `--fixtures`), wymaga `--allow-initialized`. Bez tej flagi seeder
  kończy się kodem 3.
- Dane logowania właściciela są w `tools/backend/dev.env` (gitignored).
  Seeder generuje je przy pierwszym uruchomieniu; kod odzyskiwania dopisuje
  tylko pierwszego Core (stos dev), stosy kontraktowe są jednorazowe.
- Konta ADMIN (`admin@gihome.test`) i USER (`user@gihome.test`) mają celowo
  udokumentowane, testowe hasła z pliku przykładowego. To nie są prawdziwe dane
  logowania; nigdy nie kieruj seedera na prawdziwe urządzenie.
- `--fixtures` dopisuje brakujące nagrania do
  `packages/gi_core_api/test/fixtures/core/<shortSha z backend.lock>/<endpointId>/<case>.json`
  (`endpointId` to id z katalogu `GiEndpoints`, czyli operationId Swaggera;
  `_unrouted` to odpowiedzi na nieistniejące trasy; nagłówki `Set-Cookie` w
  `<case>.set-cookie.txt`). Istniejących plików nie nadpisuje (testy zależą od
  ich wartości), chyba że dodasz `--overwrite-fixtures`. Refresh, zmianę hasła
  i wylogowanie nagrywa na koncie USER, nie właściciela.
- GI Core pozwala na 5 logowań na minutę z jednego IP. Seeder loguje się raz
  (z `--fixtures` do czterech razy, jeśli brakuje nagrań).

# Narzędzia kontraktu i dewelopera

Wszystkie są w pakiecie `gi_tools` (`tools/`, czysty Dart, bez Fluttera) i
uruchamia się je z katalogu głównego repo; `--help` opisuje opcje. Backend
tylko czytają.

## `tools/spec_diff.dart`: dryf specyfikacji (plan §17.5)

Pobiera `/docs-json` z Core (najlepiej kontraktowego) i porównuje go z
[`contract/openapi/core-<ref>.json`](../contract/openapi) (`<ref>` = `shortSha`
z `backend.lock`), tylko dla operacji z katalogu `GiEndpoints.all`.

```sh
dart run tools/spec_diff.dart --base-url <GI_CORE_URL> --snapshot contract/openapi/core-8be59cd.json
dart run tools/spec_diff.dart --base-url <GI_CORE_URL> --json      # raport JSON
dart run tools/spec_diff.dart --spec-file live.json                # spec z pliku
dart run tools/spec_diff.dart --base-url <GI_CORE_URL> --write-snapshot contract/openapi/core-<ref>.json
```

- **Błąd (kod 1):** brak operacji z katalogu; nowe wymagane pole żądania lub
  parametr (albo pole, które stało się wymagane); usunięte lub zmienione
  wymagane pole żądania; usunięte pole odpowiedzi, które klient dekoduje jako
  wymagane, albo zmiana typu pola, które klient czyta.
- **Ostrzeżenie (kod 0):** nowe pola opcjonalne, nowe endpointy, pola
  odpowiedzi, których klient nie potrzebuje, zmienione kody 2xx, inny
  `operationId`.
- Kod 2: nie udało się przeczytać specyfikacji lub snapshotu; 64: złe opcje.
- Które pola klient wymaga, narzędzie ustala samo: dekoduje nagrane fixture'y
  tymi samymi modelami co `GiCoreClient` i sprawdza, bez którego pola dekoder
  się wywraca (spec GI Core w większości nie ma schematów odpowiedzi, §6.1).
- Snapshot jest kanoniczny (posortowane klucze, wcięcie 2 spacje), więc diff w
  PR pokazuje tylko prawdziwe zmiany. Nowy snapshot nagrywa się
  `--write-snapshot` razem ze zmianą `backend.lock` i fixture'ów.

## `tools/gen_backend_contract.dart`: `docs/backend-contract.md` (plan §6.2)

```sh
dart run tools/gen_backend_contract.dart           # przepisuje docs/backend-contract.md
dart run tools/gen_backend_contract.dart --check   # kod 1, gdy plik jest nieaktualny
```

Tabela z katalogu: id, metoda, ścieżka, autoryzacja, kamień milowy i
funkcja (pola `milestone` i `feature` w `Endpoint`), timeout i ponowienia,
przypadki fixture'ów oraz pliki testów na żywo. Plik jest commitowany;
`tools/test/backend_contract_test.dart` generuje go w pamięci i failuje, gdy
commitowana wersja jest nieaktualna (po zmianie katalogu, fixture'ów albo list
`liveCoverage` uruchom generator).

Stan na koniec M3 (2026-11-22): katalog ma 33 endpointy, plik jest aktualny
(`--check`), a `spec_diff` żywego `/docs-json` Core `8be59cd` względem
`contract/openapi/core-8be59cd.json` nie pokazuje różnic (101 ścieżek, snapshot
identyczny), więc snapshot nie wymagał odświeżenia. Braki po stronie backendu
nie są zapisywane jako `TODO(backend)`: CI blokuje ten znacznik (plan §17,
G5), a backend pozostaje niezmienny; ograniczenia opisuje plan §21.

## Reguła pokrycia katalogu (plan §6.2, §17.2, §19.1)

[`packages/gi_core_api/test/catalog_coverage_test.dart`](../packages/gi_core_api/test/catalog_coverage_test.dart)
wymaga dla każdego wpisu `GiEndpoints.all`: co najmniej jednego pliku w
`test/fixtures/core/<ref>/<endpointId>/`, testu jednostkowego, który czyta ten
fixture (`fixtureObject('<endpointId>/...')` i pokrewne), oraz testu na żywo.
Każdy `test/contract/*_contract_test.dart` deklaruje
`const liveCoverage = <Endpoint>[...]` z wpisami, które sprawdza, i jest
zarejestrowany w teście pokrycia. Wpis bez testu na żywo wymaga pozycji z
powodem w `liveCoverageExemptions`
(`test/contract/support/live_coverage.dart`); dziś lista jest pusta.

## `tools/mock_core`: udawany GI Core z fixture'ów (tylko dev, plan §17.1)

Serwer shelf, który odpowiada na endpointy katalogu nagranymi fixture'ami
(`packages/gi_core_api/test/fixtures/core/<shortSha z backend.lock>`), z
minimalnym logowaniem w pamięci: dowolny e-mail i hasło logują jako nagrany
właściciel z tym e-mailem, ciasteczko refresh rotuje przy każdym
`/auth/refresh` (ponowne użycie starego daje `AUTH_REFRESH_TOKEN_REUSED` i
kończy sesję), działają `me`, `profile`, zmiana hasła i wylogowanie. Szczegóły
urządzenia są z nagrań po id (urządzenie z listy bez nagranych szczegółów
dostaje szczegóły zbudowane z listy), `lastSeenAt` to czas żądania. Zapisy M2
(`PUT .../state`, `PATCH /devices/{id}`, `PATCH .../control-strategy`) działają
na kopii szczegółów w pamięci z kontrolami w kolejności Core (404, 409
`HEATING_SUSPENDED`, 422, 409 `ENTITY_DISABLED`, 503 `DEVICE_OFFLINE`); GI Edge
zapisuje optymistycznie, a w dry-run zwraca stary stan; `MockCore.switchFailure`
wstrzykuje błąd ESPHOME 502/503/504 na ścieżce legacy. Inne ścieżki dają
kopertę `404 HTTP_404` jak Core. Bez limitu logowań.

```sh
dart run tools/mock_core/bin/mock_core.dart                       # http://127.0.0.1:3100
dart run tools/mock_core/bin/mock_core.dart --port 3200 --fixtures-ref 8be59cd
dart run tools/mock_core/bin/mock_core.dart --password demo --access-ttl 60   # wymuś hasło, krótki token
dart run tools/mock_core/bin/mock_core.dart --host 0.0.0.0        # telefon w LAN (otwórz port w zaporze)
```

W aplikacji (flavor dev) wpisz `10.0.2.2:3100` na emulatorze Androida,
`localhost:3100` na symulatorze iOS albo `<IP-komputera>:3100` z
`--host 0.0.0.0`. To co innego niż flaga `mockCore` flavoru dev (adapter w
procesie aplikacji, `app/lib/src/core/dev/mock_core_adapter.dart`):
`mock_core` przechodzi przez prawdziwy HTTP, drabinę połączenia i
`AuthSessionManager`. Nie służy do testów aplikacji i nigdy do wydań.

## `tools/import_web_messages.dart`: jednorazowy import słownictwa (plan §13.1)

Czyta `apps/gi-ui/src/shared/i18n/messages.ts` z folderu backendu (tylko
odczyt) i proponuje wpisy ARB. Bez `--apply` nie zmienia `app/lib/l10n`.

```sh
dart run tools/import_web_messages.dart                      # propozycja w tools/out/ (gitignored)
dart run tools/import_web_messages.dart --only auth.,nav.    # tylko klucze z tymi prefiksami
dart run tools/import_web_messages.dart --only auth. --apply # dopisuje brakujące klucze do ARB
cd app && fvm flutter gen-l10n
```

- Wynik: `tools/out/web_messages_import.json` (każdy komunikat: klucz web,
  proponowany klucz ARB, np. `dashboard.deviceDiscoveredTitle` →
  `dashboardDeviceDiscoveredTitle`, pl, en, placeholdery, status) i
  `tools/out/web_messages_import.md` (tabele do przejrzenia).
- Statusy: `missing` (nowy klucz; tylko te dodaje `--apply`), `exists` (ten
  sam klucz i tekst), `differs` (klucz jest, tekst inny: zostaje tekst
  aplikacji), `sameText` (ten sam polski tekst pod innym kluczem: użyj
  istniejącego), `incomplete` (brak pl albo en w GI UI).
- `--apply` dopisuje nowe klucze na końcu `app_pl.arb` (z `@klucz`: opis z
  kluczem web, placeholdery typu `String`) i `app_en.arb`. Istniejących kluczy
  i tłumaczeń nie zmienia, reszta pliku zostaje bajt w bajt. Słownictwo GI UI
  bywa techniczne: importuj wybiórczo (`--only`) i popraw teksty na ekrany
  codzienne (§13.1).
- Parser jest pragmatyczny: obiekt `const messages = { "<locale>": { ... } }`,
  klucze w cudzysłowach lub bez, wartości w `"..."`, `'...'` i `` `...` ``
  (bez `${}`), sklejane `+`, typowe escape'y i komentarze. Wartości, których
  nie umie policzyć (interpolacja, wywołania, spready), pomija i wypisuje w
  raporcie. Folder backendu: `--source` albo `GI_BACKEND_DIR`.

## `tools/dev_lan_proxy`

Forwarder TCP dla telefonu w LAN; opis i zapora w sekcji „Adres GI Core w
aplikacji” niżej.

# Adres GI Core w aplikacji

Ekran „Połącz z GI Home” od razu uruchamia drabinę „Znajdź GI Home” (plan
§9.2): najpierw zapamiętane adresy profilu (`hosts[]`, `/health/live` z
limitem 1,5 s), potem nazwy `gi-home.local` i `gi-home-2…5.local` przez
systemowy resolver. Każde urządzenie, które odpowie na `/health/live` i
`/setup/status`, trafia na listę; wybór prowadzi do tej samej karty
potwierdzenia co wpisany adres. Inne urządzenie niż zapisane zastępuje profil
dopiero po potwierdzeniu (wylogowanie i usunięcie danych starego). Gdy
przywracanie sesji nie dosięga zapisanego IP, aplikacja szuka tego samego
urządzenia (ten sam `initializedAt`) pod nazwą `.local` i po cichu przenosi
profil z sesją (§9.3); ekran błędu przywracania ma też „Znajdź GI Home”.
Prawdziwe rozwiązywanie `.local` na telefonach sprawdza dopiero spike S3
(fizyczne urządzenia); zapasowy `multicast_dns` podłącza się jako kolejny
`HostResolver`. We flavorze dev z flagą `mockCore` „znajduje się”
`gi-home.local`.

Android 13+ może prosić o `NEARBY_WIFI_DEVICES` (ochrona sieci lokalnej,
§9.4) przed szukaniem, ale tylko z flagą
`androidLocalNetworkPermissionRequest` (domyślnie wyłączona). Odmowa, a także
odmowa dostępu do sieci lokalnej zgłoszona przez system, pokazuje komunikat z
przyciskiem „Otwórz ustawienia” (strona aplikacji w ustawieniach systemu).
Komunikat „Połączenie w sieci domowej nie jest szyfrowane” pokazuje się raz na
profil, przy pierwszym potwierdzeniu adresu `http://`.

Uruchamianie flavorów opisuje sekcja „Flavory, konfiguracja i flagi funkcji”
poniżej. Adres można też wpisać ręcznie (pole jest zawsze widoczne): host i port, schemat
domyślnie `http://` (wklejony adres kończący się na `/api/v1` też zadziała).
We flavorze dev pod polem są presety z planu (§9.6): dotknięcie wpisuje adres
do pola, który można poprawić przed „Sprawdź” (przy presetach LAN kursor stoi
tam, gdzie trzeba wpisać IP komputera). W beta i prod presetów nie ma.

| Cel | Adres w aplikacji | Warunek |
|---|---|---|
| Emulator Androida | `10.0.2.2:3000` (preset dev) | Core na loopbacku hosta (domyślnie) |
| Symulator iOS | `localhost:3000` (preset dev) | j.w. |
| Android przez USB | `localhost:3000` (preset dev) | najpierw `adb reverse tcp:3000 tcp:3000`; Core zostaje na loopbacku |
| Telefon w Wi-Fi | `<IP-komputera-w-LAN>:3000` (preset dev) | backend z `GI_CORE_BIND_ADDRESS=0.0.0.0` (`dev-up -Lan`) i otwarta zapora |
| Telefon w Wi-Fi przez `dev_lan_proxy` | `<IP-komputera>:8080` (preset dev) | forwarder `0.0.0.0:8080 → 127.0.0.1:3000`; Core zostaje na loopbacku |
| Prawdziwe urządzenie | `gi-home.local` lub `<IP>` | |

- `http://` jest dozwolony tylko dla adresów sieci domowej (RFC 1918,
  loopback, link-local, `*.local`); każdy inny host wymaga `https://`
  (`TransportPolicy` w `gi_core_api`).
- Windows: dla telefonu w LAN otwórz port w profilu „Prywatna” zapory, np. w
  PowerShell jako administrator:
  `New-NetFirewallRule -DisplayName 'GI Core dev 3000' -Direction Inbound -Protocol TCP -LocalPort 3000 -Profile Private -Action Allow`.
- Forwarder [`tools/dev_lan_proxy`](../tools/dev_lan_proxy) (plan §9.6) pozwala
  zostawić Core na loopbacku (bez `GI_CORE_BIND_ADDRESS=0.0.0.0`): przyjmuje
  połączenia na `0.0.0.0:8080` i przekazuje je bajt w bajt do
  `127.0.0.1:3000`. Telefon wpisuje `<IP-komputera>:8080`; IP z listy, którą
  forwarder wypisuje przy starcie.

  ```powershell
  dart run tools/dev_lan_proxy/bin/dev_lan_proxy.dart                        # 0.0.0.0:8080 -> 127.0.0.1:3000
  dart run tools/dev_lan_proxy/bin/dev_lan_proxy.dart --listen 0.0.0.0:8081 --target 127.0.0.1:3100   # np. do mock_core
  # jednorazowo, PowerShell jako administrator: port 8080 tylko w profilu „Prywatna”
  New-NetFirewallRule -DisplayName 'GI dev_lan_proxy 8080' -Direction Inbound -Protocol TCP -LocalPort 8080 -Profile Private -Action Allow
  ```

  Każde połączenie to jedna linia logu przy otwarciu i jedna przy zamknięciu
  (czas, bajty w obie strony); `-q` je wyłącza. Ctrl+C zamyka nasłuch i
  otwarte połączenia. Sieć Wi-Fi komputera musi mieć w Windows profil
  „Prywatna” (Ustawienia → Sieć i Internet → właściwości sieci); w profilu
  „Publiczna” reguła nie działa i telefon dostaje timeout.
- `10.0.2.2` leży w 10.0.0.0/8, więc `TransportPolicy` dopuszcza go we
  wszystkich flavorach: domowa sieć może używać 10.0.2.x (decyzja opisana
  w `transport_policy.dart`). Tylko preset jest wyłącznie w dev.

## HTTPS za proxy operatora

`https://` (np. GI Home za reverse proxy instalatora, plan §9.4) działa z
certyfikatem, któremu ufa **systemowy magazyn zaufania** telefonu (publiczne
CA, np. Let's Encrypt). Na Androidzie `dart:io` domyślnie **nie ufa CA
zainstalowanym przez użytkownika**, więc proxy z prywatnym CA albo
certyfikatem self-signed kończy się komunikatem „Certyfikat serwera nie jest
zaufany” (`TlsUntrusted`). Taki certyfikat zadziała dopiero z przypinaniem przy
pierwszym połączeniu (TOFU), planowanym na v1.1.

# Flavory, konfiguracja i flagi funkcji

Trzy flavory (plan §19.2), każdy z własnym punktem wejścia i plikiem
konfiguracji w `app/config/` (bez sekretów). Na Androidzie mają osobne
applicationId, nazwę i ikonę, więc można je zainstalować obok siebie.

| Flavor | Punkt wejścia | Konfiguracja | applicationId (Android) | Nazwa |
|---|---|---|---|---|
| `dev` | `lib/main_dev.dart` | `config/dev.json` | `pl.gihome.gi_home.dev` | GI Home Dev |
| `beta` | `lib/main_beta.dart` | `config/beta.json` | `pl.gihome.gi_home.beta` | GI Home Beta |
| `prod` | `lib/main.dart` | `config/prod.json` | `pl.gihome.gi_home` | GI Home |

```sh
cd app
fvm flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=config/dev.json
fvm flutter run --flavor beta -t lib/main_beta.dart --dart-define-from-file=config/beta.json
fvm flutter run --flavor prod -t lib/main.dart --dart-define-from-file=config/prod.json

fvm flutter build apk --debug --flavor dev -t lib/main_dev.dart --dart-define-from-file=config/dev.json
fvm flutter build appbundle --flavor prod -t lib/main.dart --dart-define-from-file=config/prod.json
```

- Punkt wejścia musi pasować do pliku: `FLAVOR` z innego flavoru zatrzymuje
  start aplikacji (`AppConfig.fromEnvironment`). Bez pliku wszystkie flagi są
  wyłączone.
- Docelowe bundle ID wymagają decyzji właściciela (plan §23, D5); na razie to
  bazowe ID z sufiksami `.dev` i `.beta`. Release podpisuje się kluczem
  uploadu, gdy są ustawione `GI_UPLOAD_*` albo `app/android/key.properties`
  (sekcja „Podpisywanie wydań Androida”); bez nich – kluczem debug z
  ostrzeżeniem, a z `GI_REQUIRE_RELEASE_SIGNING=true` build się przerywa.
- Android: `minSdk` 26, `compileSdk` i `targetSdk` 36 (D13). iOS: tylko
  iPhone, portret, iOS 15+ (D13). **Schematy Xcode, konfiguracje buildów i
  osobne bundle ID per flavor na iOS czekają na pracę na macOS**; do tego czasu
  `--flavor` na iOS nie działa, a iOS buduje się bez flavoru
  (`flutter run -t lib/main_dev.dart --dart-define-from-file=config/dev.json`).
- Wyłączenie z kopii zapasowej (§8.3): na iOS katalog Application Support
  (diagnostyka, później snapshot i cache ETag) dostaje
  `isExcludedFromBackup` przez kanał `gi_home/backup`
  (`lib/src/core/platform/backup_exclusion.dart`, handler w
  `ios/Runner/AppDelegate.swift`). **Kod Swift jest niezweryfikowany, dopóki
  nie zostanie zbudowany na macOS**; strona Dart ma testy z atrapą kanału.
  Android nie wywołuje kanału: chronią go `allowBackup="false"` i
  `dataExtractionRules`.
- Flagi funkcji (`FeatureFlags`, §19.6) mają wartości domyślne z pliku
  konfiguracji (`FF_*`). W dev i beta można je nadpisać na ukrytym ekranie
  „Funkcje eksperymentalne”: 7 dotknięć wersji aplikacji w Ustawieniach.
  Nadpisania zostają w `shared_preferences` do „Przywróć domyślne”; prod je
  ignoruje, a gest nic nie robi.
- `STORE_URL_ANDROID` i `STORE_URL_IOS` (puste domyślnie, inaczej adres
  `https://`) to linki do sklepu w banerze „Zaktualizuj aplikację”. Baner
  pojawia się, gdy w jednej sesji aplikacji odpowiedź kluczowego endpointu
  MVP (`/auth/me`, `/devices`, `/devices/:id`, `/setup/status`) trzy razy nie
  pasuje do modelu (`UnexpectedShape`, plan §16 pkt 4); bez linku pokazuje sam
  tekst. Play In-App Updates (`in_app_update`) wymaga wpisu w Google Play i
  przyjdzie razem z nim.
- `FF_MOCK_CORE` (tylko dev) podmienia GI Core na atrapę w procesie
  (`MockCoreAdapter`): dowolny adres z sieci domowej i dowolne dane logowania
  prowadzą do przykładowego domu. Atrapa nigdy nie trafia do beta ani prod.
- `FF_MDNS_FALLBACK` (domyślnie `false` w każdym flavorze) włącza na Androidzie
  zapasowe wyszukiwanie nazw `.local` przez multicast DNS, gdy system ich nie
  rozwiązuje (`MulticastDnsHostResolver`; wymaga uprawnienia
  `CHANGE_WIFI_MULTICAST_STATE`, wpisanego w manifest). W dev i beta można ją
  przełączyć na ekranie „Funkcje eksperymentalne”. Czy ma być domyślnie
  włączona, rozstrzygnie spike S3 na fizycznych telefonach
  ([ADR 0015](decisions/0015-network-change-no-write-replay.md)).
- Ikony dev i beta mają wstążkę. Po zmianie `assets/icon/icon*.png`:
  `cd app; fvm dart run tool/make_flavor_icons.dart; fvm dart run flutter_launcher_icons`
  (pliki `flutter_launcher_icons-{dev,beta}.yaml`, zasoby w
  `android/app/src/{dev,beta}/res`; ikony prod w `src/main/res` się nie
  zmieniają).

# Generowanie kodu, analiza i testy

Najpierw, w katalogu głównym repo: `fvm flutter pub get` (rozwiązuje cały
workspace). Analizę i testy uruchamia się **w każdym członku osobno**, nie
z katalogu głównego.

```sh
# generowanie kodu (freezed, json_serializable, riverpod_generator)
cd packages/gi_core_api && fvm dart run build_runner build -d
cd app && fvm dart run build_runner build -d

# lokalizacje (po zmianie app/lib/l10n/*.arb; app_pl.arb to szablon)
cd app && fvm flutter gen-l10n

# analiza (w app/ także reguły riverpod_lint)
cd app && fvm flutter analyze
cd packages/gi_core_api && fvm dart analyze
cd tools && fvm dart analyze

# testy jednostkowe i widgetów
cd app && fvm flutter test
cd packages/gi_core_api && fvm dart test -x contract
cd tools && fvm dart test       # w tym aktualność docs/backend-contract.md
```

`riverpod_lint` działa jako plugin serwera analizy (sekcja `plugins:`
w `app/analysis_options.yaml`), więc nie ma go w `pubspec.yaml`: analizator
pobiera go sam przy pierwszej analizie. Jego wersja musi pasować do `riverpod`
z `pubspec.lock` (riverpod_lint 3.2.0 ↔ riverpod 3.5.0) — przy podbiciu
riverpoda podbij oba razem.

## Testy golden (alchemist)

Goldeny (plan §17.1, §14, §9.4) leżą w `app/test/golden/` i mają tag `golden`
(zarejestrowany w `app/dart_test.yaml`). Obejmują Dom (wszystko w porządku,
lista „Wymaga sprawdzenia”, brak urządzeń, brak połączenia z nieaktualnymi
danymi), szczegóły urządzenia (normalny, wstrzymany, dry-run, offline, stale),
logowanie (pusty formularz, błąd) i połączenie (wyszukiwanie z kandydatami,
wpisywanie adresu, karta potwierdzenia). Każdy plik PNG to jeden stan na
jednym urządzeniu (mały telefon 320×568, duży telefon 430×932, tablet Android
poziomo 840×600) z sześcioma scenariuszami: pl i en × skala tekstu 1,0 / 1,3 /
2,0. Zegar jest stały (`goldenNow`, czas lokalny), więc obrazy nie zależą od
strefy czasowej. Aplikacja ma w v1 tylko ciemny motyw (D11), więc goldeny są
w ciemnym motywie.

```sh
cd app
fvm flutter test --tags golden                   # porównanie z goldenami CI
fvm flutter test --update-goldens --tags golden  # aktualizacja po zmianie UI
```

- `goldens/ci/` (**commitowane**, renderowane na Linuxie jak w CI; poza Linuxem porównanie dopuszcza 0,3% pikseli różnicy z powodu antyaliasingu): tekst rysowany
  jako bloki, bez cieni. Porównuje je każde `flutter test`, także w CI.
- `goldens/windows|macos|linux/` (**w `.gitignore`**): podgląd z prawdziwym
  tekstem w dołączonych fontach. Powstaje tylko lokalnie przy
  `--update-goldens`; w CI (zmienna `CI`) nigdy się nie uruchamia.
- Każdy stan przed porównaniem przechodzi `meetsGuideline` (cele dotyku,
  etykiety i `textContrastGuideline`), a błąd układu (np. RenderFlex
  overflow przy skali 2,0 lub na 840×600) oblewa test. Kontrast WCAG AA par
  tokenów (`GiTokens`, `AppTheme`) liczy osobno
  `app/test/core/theme/token_contrast_test.dart` (4,5:1 dla tekstu, 3:1 dla
  dużego tekstu i ikon).
- Konfiguracja: `app/test/flutter_test_config.dart`; harness scenariuszy:
  `app/test/support/golden.dart`.

## Testy kontraktowe (na żywo, przeciw backendowi w Dockerze)

Tag nazywa się `contract` (plan mówi `live`, §17.3): pod tą nazwą wyklucza go
CI (`dart test -x contract`). Główny cel to stos kontraktowy; to warunek Exit M0
(zielony test auth na `compose.contract.yml` obok działającego stosu dev).

```powershell
.\tools\dev-up.ps1 -Contract -RunId a -Seed
cd packages\gi_core_api
$env:GI_CORE_URL='http://127.0.0.1:<port>'; $env:FAKE_ESPHOME_URL='http://127.0.0.1:<port2>'
dart test -t contract -j 1
cd ..\..; .\tools\dev-up.ps1 -Contract -RunId a -Down
```

```sh
cd packages/gi_core_api
dart test -t contract -j 1                             # stos dev, http://localhost:3000
GI_CORE_URL=http://127.0.0.1:<port> FAKE_ESPHOME_URL=http://127.0.0.1:<port2> dart test -t contract -j 1
```

- Uruchamiaj z `packages/gi_core_api`. Właściciel: `../../tools/backend/dev.env`
  (`GI_DEV_EMAIL`, `GI_DEV_PASSWORD`); ADMIN, USER i SERVICE: konta seedera.
  Hasła nigdy nie są wypisywane.
- `GI_CORE_URL` (domyślnie `http://localhost:3000`) wskazuje Core.
  `FAKE_ESPHOME_URL` deklaruje stos kontraktowy: wtedy brak urządzenia fake to
  błąd, a testy sprawdzają też fizyczny stan przekaźnika (`GET /fake/state`).
- Wszystkie testy dekodują ściśle (`DecodeMode.strict`, plan §6.4): nieznane
  pole w odpowiedzi kończy wywołanie błędem `UnexpectedShape` z
  identyfikatorem endpointu i ścieżką pola (np. `$.items[0].nowePole`).
  Aplikacja zawsze dekoduje tolerancyjnie (`DecodeMode.fromEnvironment()`
  włącza tryb ścisły zmienną `GI_CORE_STRICT_DECODING=1`).
- **Strażnik:** zestaw jest pomijany, gdy brakuje `dev.env`, Core jest
  nieosiągalny albo `initialized:false` (sam niczego nie inicjalizuje). Na Core
  `initialized:true` testy zmieniające dane (przełączanie urządzenia fake,
  zmiana hasła właściciela i powrót, strategia) działają tylko wtedy, gdy Core
  ma zaseedowane urządzenie fake, czyli jest stosem kontraktowym; na stosie dev
  są pomijane.
- Pliki: `auth_flow_contract_test.dart` (logowanie, rotacja, ponowne użycie
  ciasteczka, zmiana hasła i powrót, wylogowanie), `devices_contract_test.dart`
  (urządzenie fake ONLINE mimo 404 na `/gi-provision`, przełącznik w obie
  strony, USER dostaje `HTTP_403`, kształt odpowiedzi `control-strategy`),
  `appliance_fingerprint_contract_test.dart` (test akceptacyjny §9.3),
  `control_contract_test.dart` (ścieżki sterowania M2 na urządzeniu fake:
  `PUT .../state` w obie strony z potwierdzeniem `/fake/state` i
  `lastSeenAt == confirmedAt`, 404/400/422/409 `ENTITY_DISABLED`, wstrzymanie
  ogrzewania z 409 `HEATING_SUSPENDED` i trybem efektywnym OFF, wznowienie,
  `dryRun` ignorowany na ścieżce legacy, `control-strategy` z walidacją,
  `HTTP_403` dla USER i SERVICE; każdy test przywraca stan seedera),
  `schedules_contract_test.dart` (harmonogramy M3: CRUD 201/200/204, `PATCH {}`,
  `VALIDATION_FAILED`, `HTTP_400` dla złego UUID urządzenia,
  `DEVICE_NOT_FOUND`/`HEATING_SCHEDULE_NOT_FOUND`, `HTTP_403` dla zapisów USER,
  rekoncyliacja strategii efektywnej w zegarze UTC, ETag 304; plan PV:
  `DISABLED` bez godzin), `environment_history_contract_test.dart` (historia
  przekaźnika jako próbki `switch`, pusta historia stałej temperatury,
  `HISTORY_RANGE_INVALID`, limit 0/5001, `DEVICE_ENTITY_NOT_FOUND`; pogoda 503
  `HTTP_503`, słońce i prognoza PV 400 `HTTP_400`, bo stos nie ma lokalizacji
  domu; `/settings/system` dla ADMIN i 403 dla USER) oraz
  `account_contract_test.dart` (lista sesji z `current`, odwołanie innej,
  własnej i cudzej sesji, logout-all, nowy kod odzyskiwania, reset hasła kodem
  z powrotem do pierwotnego hasła, `PATCH /users/me/profile`).
- Reset hasła kodem odzyskiwania ma limit 5 na 15 minut z jednego IP; plik
  `account_contract_test.dart` wysyła dwa na przebieg, a po 429 pomija ten test
  zamiast failować. Trzeci przebieg w ciągu 15 minut może go więc pominąć.
- Ścieżki GI Edge (zapis optymistyczny, dry-run zwracający stary stan,
  potwierdzenie heartbeatem), `DEVICE_OFFLINE`, błędy ESPHOME 502/503/504,
  boost PV i FAULT nie są osiągalne na urządzeniu fake (tylko LEGACY_ESPHOME);
  pokrywają je fixture'y ręczne (`m2_writes_test.dart`) i `tools/mock_core`
  (`MockCore.switchFailure`).
- `-j 1`: pliki `devices_` i `control_contract_test.dart` przełączają ten sam
  przekaźnik, więc zestaw kontraktowy idzie plik po pliku.
- Logowania: kilkanaście (pliki M3 dokładają ADMIN 4, USER 9). Limit GI Core
  to 5 na minutę z jednego IP, więc logowanie ponad limit czeka raz
  `Retry-After` (do 60 s), a przebieg trwa kilka minut.

### Dwa Core: test akceptacyjny odcisku urządzenia (§9.3)

Dwa stosy kontraktowe mają różne `initializedAt`. Sesja zalogowana na A i
skierowana na adres B (ten sam sejf, odcisk A) musi zatrzymać się na
sprawdzeniu odcisku: adapter przechwytujący pokazuje, że do B nie poszło
ani ciasteczko refresh, ani token, a A po wszystkim przyjmuje nietknięte
ciasteczko (rotacja się udaje).

```powershell
.\tools\dev-up.ps1 -Contract -RunId a -Seed   # A: zapisz GI_CORE_URL i FAKE_ESPHOME_URL
.\tools\dev-up.ps1 -Contract -RunId b -Seed   # B: zapisz GI_CORE_URL jako GI_CORE_URL_B
cd packages\gi_core_api
$env:GI_CORE_URL='<A>'; $env:FAKE_ESPHOME_URL='<fake A>'; $env:GI_CORE_URL_B='<B>'
dart test -t contract -j 1
cd ..\..; .\tools\dev-up.ps1 -Contract -RunId a -Down; .\tools\dev-up.ps1 -Contract -RunId b -Down
```

Bez `GI_CORE_URL_B` ten test jest pomijany.

## Test integracyjny (end-to-end na urządzeniu)

Wymaga działającego, zainicjalizowanego Core z danymi demo (`dev-up -Seed`).
Test czyści profil urządzenia i zapisane tokeny aplikacji na urządzeniu,
przechodzi połączenie → logowanie → Dom → szczegóły urządzenia → Ustawienia →
wylogowanie i loguje się dokładnie raz.

```sh
cd app
# emulator Androida, flavor dev, tryb profile (mniejszy APK)
flutter drive --profile -d emulator-5554 --flavor dev \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_flow_test.dart \
  --dart-define-from-file=config/dev.json \
  --dart-define-from-file=../tools/backend/dev.env

# symulator iOS (debug; profile nie działa na symulatorze; bez --flavor,
# dopóki nie ma schematów Xcode)
flutter test integration_test/app_flow_test.dart -d <id-symulatora> \
  --dart-define-from-file=config/dev.json \
  --dart-define-from-file=../tools/backend/dev.env \
  --dart-define=GI_CORE_ADDRESS=localhost:3000
```

- Dane logowania trafiają do testu jako `--dart-define` (`GI_DEV_EMAIL`,
  `GI_DEV_PASSWORD`); `--dart-define-from-file` czyta je wprost z `dev.env`.
- M3 na stosie kontraktowym (tak jak `control_flow_test.dart`, z
  `--dart-define=GI_CORE_ADDRESS=10.0.2.2:<port>`):
  `schedule_flow_test.dart` (harmonogram całodobowy na każdy dzień → widoczny
  jako aktywny → edycja → usunięcie) i `account_flow_test.dart` (język
  profilu, odwołanie drugiej sesji, nowy kod odzyskiwania, zmiana hasła i reset
  kodem z ekranu logowania z powrotem do pierwotnego hasła). Nocny job
  `e2e-android` uruchamia oba po `control_flow_test.dart`.
- `GI_CORE_ADDRESS` (domyślnie `10.0.2.2:3000`) ustawia adres wpisywany na
  ekranie połączenia, np. `localhost:3000` po `adb reverse` albo IP w LAN.

# CI/CD

GitHub Actions (plan §19.1) i dystrybucja (plan §19.3, §19.4, D12). Każdy workflow
uruchamia wspólne bramki repo (`.github/actions/repo-gates`: kroki **Format** i
zakaz znacznika TODO dla backendu, plan G5) i ten sam Flutter z `.fvmrc` (`.github/actions/setup-flutter`).

| Plik | Kiedy | Co robi |
|---|---|---|
| [`ci.yml`](../.github/workflows/ci.yml) | PR, push na `main`, ręcznie, wywołanie z `build.yml` | `flutter gen-l10n`, `build_runner` w obu członkach i **kontrola aktualności wygenerowanego kodu** (`tools/ci/check-generated.sh`: `git diff --exit-code` + nieśledzone pliki; wymaga commitowania `*.g.dart`, `*.freezed.dart` i `app_localizations*.dart`), analiza każdego członka, testy (`gi_core_api` z regułą pokrycia katalogu, `tools/`, `app` bez goldenów), **bramka pokrycia**, osobny krok **goldenów** (`flutter test --tags golden`) |
| [`contract.yml`](../.github/workflows/contract.yml) | co noc, ręcznie, PR do `packages/gi_core_api/**`, `contract/**`, `tools/**` | checkout backendu na SHA z `contract/backend.lock`, `tools/dev-up.sh --contract`, seeder `--init --yes --fixtures`, `dart test -t contract -j 1`, `spec_diff` względem `contract/openapi`, artefakty (nowe fixture'y, żywy `/docs-json`, logi compose), zawsze `--down`. Nocą także kanarek na `main` backendu (nie blokuje) |
| [`e2e.yml`](../.github/workflows/e2e.yml) | PR do `app/**` (mock), co noc i ręcznie (prawdziwy Core) | emulator Androida (`reactivecircus/android-emulator-runner` v2.38.0 przypięty do SHA commita, API 34, x86_64), `integration_test/app_flow_test.dart` we flavorze dev: na PR z wbudowanym mockiem (`FF_MOCK_CORE`), nocą przeciw seedowanemu stosowi kontraktowemu przez `10.0.2.2:<port>` |
| [`build.yml`](../.github/workflows/build.yml) | PR do `app/**`/`packages/**`, push na `main`, tagi `v*`, ręcznie | AAB prod na Linuksie + kontrola wyrównania 16 KB (`tools/ci/check-16kb-alignment.sh`) + artefakt; iOS `--no-codesign` na macOS (**nie da się sprawdzić lokalnie** na Windows). Na tagach najpierw całe `ci.yml`, a AAB musi być podpisany kluczem uploadu |
| [`codemagic.yaml`](../codemagic.yaml) | tagi `v*` | `ios-testflight-internal` (TestFlight, tylko testerzy wewnętrzni) i `android-play-internal` (ścieżka internal w Play) |
| [`fastlane/`](../fastlane/Fastfile) | ręcznie (`bundle exec fastlane ios internal_ios`, `bundle exec fastlane android internal_android`) | te same przepływy poza Codemagic (Mac osoby wydającej, runner macOS) |

Procedura wydania (tagi, zapis refu backendu, phased release / staged rollout jako
wyłącznik): [`docs/release-runbook.md`](release-runbook.md).

## Obciążenie GI Core (`tools/load`)

Budżet żądań i kadencje opisuje [load-budget.md](load-budget.md). Narzędzie
`tools/load/simulate_clients.dart` odtwarza kadencje aplikacji dla N telefonów z
otwartym Home (tylko GET; jedyny inny ruch to jedno logowanie) i zapisuje
raport. Kadencje czyta z `app/lib/src/core/polling/polling_budget.dart`, więc
nie ma ich w narzędziu drugi raz.

Przeciw stosowi kontraktowemu (z `-Seed`, żeby były urządzenia):

```powershell
.\tools\dev-up.ps1 -Contract -RunId load1 -Seed
# GI_CORE_URL=http://127.0.0.1:<port>
dart run tools/load/simulate_clients.dart --base-url http://127.0.0.1:<port> `
  --run-id load1 --clients 3 --cards 3 --duration 600
.\tools\dev-up.ps1 -Contract -RunId load1 -Down
```

| Opcja | Znaczenie |
|---|---|
| `--clients` | liczba telefonów (domyślnie 3) |
| `--cards` | karty ogrzewania na Home każdego telefonu (domyślnie 2) |
| `--duration` | czas w sekundach (domyślnie 600) |
| `--base-url` | adres GI Core (albo zmienna `GI_CORE_URL`) |
| `--run-id` | RunId stosu kontraktowego; próbkuje kontener `gi-core` projektu `gi-mobile-contract-<RunId>` (`--container-filter` podaje projekt wprost) |
| `--out-dir` | katalog raportu (domyślnie `build/load-report/<znacznik czasu>`, poza gitem) |
| `--email`, `--password`, `--token` | konto do logowania (domyślnie ADMIN z `tools/seed_accounts*.json`) albo gotowy token |
| `--dry-run` | zamiast Core uruchamia atrapę w procesie i przyspiesza czas (`--time-scale`, domyślnie 30); sprawdza samo narzędzie |

Wynik to `report.json` i `report.md`: żądania na minutę na telefon (ustalone,
bez pierwszej rundy startowej), szczyt minuty, kody odpowiedzi, odsetek 304,
percentyle opóźnień p50, p90 i p99 oraz, gdy docker jest dostępny, średnie i
szczytowe CPU kontenera `gi-core` (próbka co 5 s z `docker stats`). Bez
dockera albo bez `--run-id` narzędzie ostrzega w raporcie i pomija próbkowanie.
Kod wyjścia to 0, gdy każdy telefon mieści się w 12 żądaniach na minutę, a 1,
gdy nie.

Jak czytać wynik: żądania na minutę są wiarygodne (to te same kadencje co w
aplikacji), CPU z komputera deweloperskiego mówi tylko, jak obciążenie rośnie z
liczbą telefonów, nie ile zużyje Raspberry Pi. Pomiar na Pi (trzy telefony i
panel www przez 30 minut, CPU poniżej 50%) wymaga sprzętu i jest jeszcze do
zrobienia; wynik zapisuje się według
[templates/load-test-pi-report.md](templates/load-test-pi-report.md).

Test samego narzędzia (liczenie percentyli, werdykt, przebieg na atrapie)
działa w `tools/`: `dart test test/load_simulator_test.dart`.

### Zimny start (p90 z 20 uruchomień, limit 5 s)

Szkielet pomiaru to `app/integration_test/perf/cold_start_benchmark_test.dart`:
mierzy część aplikacji (od `runGiHome` do pierwszej listy urządzeń na Home,
po jednym logowaniu) i wypisuje `COLD_START_MS=<n>` dla każdego uruchomienia.
Do czasu od ikony do Home, razem ze startem procesu, zmierz prawdziwe
uruchomienia wydaniowej wersji na telefonie w sieci Pi:
`adb shell am force-stop <pakiet>` i `adb shell am start -W <pakiet>/.MainActivity`
(pole `TotalTime`) powtórzone 20 razy. Liczby (po jednej w wierszu, albo
wiersze logu `COLD_START_MS=`) liczy:

```sh
dart run tools/load/cold_start_p90.dart runs.txt
```

Wynik (min, mediana, średnia, p90, maks. i werdykt) wklejasz do
[templates/cold-start-p90.md](templates/cold-start-p90.md). Pomiar wymaga
telefonu i prawdziwego Pi; bez tego zostaje szkielet.

## Kontrola wyrównania 16 KB (`tools/ci/check-16kb-alignment.sh`)

Play wymaga od aplikacji kierowanych na Androida 15 i nowszy bibliotek
natywnych wyrównanych do 16 KB. Skrypt sprawdza segmenty LOAD bibliotek
`arm64-v8a` i `x86_64` w AAB albo APK. CI uruchamia go na AAB w
`.github/workflows/build.yml`. Lokalnie, w Git Bash na Windows:

```bash
cd app
flutter build apk --release --flavor prod -t lib/main.dart --dart-define-from-file=config/prod.json
cd ..
bash tools/ci/check-16kb-alignment.sh app/build/app/outputs/flutter-apk/app-prod-release.apk
```

Potrzebne są `unzip` (jest w Git Bash) i `readelf` albo `llvm-readelf`. Git
Bash nie ma `readelf`; wystarczy ten z binutils (na przykład z pakietu WinLibs
`mingw64/bin`) albo `llvm-readelf` z NDK, dodany do `PATH`. Wynik zerowy
oznacza, że wszystkie biblioteki mają wyrównanie co najmniej 16384; kod 1 to
biblioteka niewyrównana, kod 2 to brak narzędzi albo pliku. Wynik z 2026-11-22
na APK prod (Windows): osiem bibliotek, najmniejsze wyrównanie 16384
(`libdartjni.so`, `libdatastore_shared_counter.so`), pozostałe 65536.

## Bramka pokrycia (plan §17.2)

```sh
(cd packages/gi_core_api && dart test -x contract --coverage-path=coverage/lcov.info --branch-coverage)
(cd app && flutter test -x golden --branch-coverage)
dart run tools/check_coverage.dart          # -v: wszystkie pliki
```

Progi: ≥ 90% linii w `packages/gi_core_api/lib` i w `app/lib/**/domain/**`, 100% linii i
gałęzi w `transport_policy.dart` (oraz w `SafetyPolicy`/`ConfirmationPolicy`, gdy
powstaną). `*.g.dart` i `*.freezed.dart` są pominięte. Gałęzie liczą się tam, gdzie lcov
ma dane `BRDA` (`--branch-coverage`); bez nich zostaje próg linii. Pliki, których nie ma
w raporcie (żaden test ich nie ładuje albo nie mają wykonywalnych linii), są wypisywane
jako ostrzeżenia. Wynik trafia też do podsumowania joba.

## Sekrety i zmienne

Żadna wartość nie jest w repo. GitHub Actions (Settings → Secrets and variables → Actions):

| Nazwa | Rodzaj | Gdzie | Po co |
|---|---|---|---|
| `GI_BACKEND_REPO` | zmienna | `contract.yml`, `e2e.yml` | `owner/name` repo backendu; domyślnie z `repository=` w `contract/backend.lock` |
| `GI_BACKEND_TOKEN` | sekret | `contract.yml`, `e2e.yml` | token tylko do odczytu (Contents: read) do repo backendu, jeśli jest prywatne (plan §24.1, wciąż otwarte); bez niego `GITHUB_TOKEN` czyta tylko repo publiczne |
| `GI_UPLOAD_KEYSTORE_BASE64` | sekret | `build.yml` (tagi) | keystore uploadu Play (`.jks`) w base64 |
| `GI_UPLOAD_KEYSTORE_PASSWORD` | sekret | `build.yml` (tagi) | hasło keystore |
| `GI_UPLOAD_KEY_ALIAS` | sekret | `build.yml` (tagi) | alias klucza |
| `GI_UPLOAD_KEY_PASSWORD` | sekret | `build.yml` (tagi) | hasło klucza |

Codemagic: grupy zmiennych `app_store_connect` (`APP_STORE_CONNECT_ISSUER_ID`,
`APP_STORE_CONNECT_KEY_IDENTIFIER`, `APP_STORE_CONNECT_PRIVATE_KEY`,
`CERTIFICATE_PRIVATE_KEY`), `gi_home_ios` (`GI_IOS_BUNDLE_ID`), `google_play`
(`GCLOUD_SERVICE_ACCOUNT_CREDENTIALS`) i `gi_home_android_signing` (te same `GI_UPLOAD_*`).
fastlane: zmienne opisane na górze [`fastlane/Fastfile`](../fastlane/Fastfile)
(`APP_STORE_CONNECT_API_KEY_*`, `MATCH_GIT_URL`, `MATCH_PASSWORD`,
`GI_PLAY_SERVICE_ACCOUNT_JSON`, `GI_ANDROID_PACKAGE_NAME`, `GI_IOS_BUNDLE_ID`). Bundle ID
to placeholdery do decyzji D5.

## Podpisywanie wydań Androida (plan §19.4)

`app/android/app/build.gradle.kts` bierze klucz uploadu ze zmiennych
`GI_UPLOAD_KEYSTORE_PATH`, `GI_UPLOAD_KEYSTORE_PASSWORD`, `GI_UPLOAD_KEY_ALIAS`,
`GI_UPLOAD_KEY_PASSWORD` albo, lokalnie, z `app/android/key.properties` (`storeFile`,
`storePassword`, `keyAlias`, `keyPassword`; gitignored, jak `*.jks`). Bez kompletu build
release podpisuje się kluczem debug i wypisuje `WARNING: release build signed with the
DEBUG key`; takiego AAB Play nie przyjmie. Z `GI_REQUIRE_RELEASE_SIGNING=true` (ustawiają
je `build.yml` na tagach, Codemagic i fastlane) brak którejkolwiek wartości przerywa build
z listą brakujących zmiennych.

## Lokalne odtworzenie kroków CI

```sh
bash tools/ci/check-generated.sh       # po gen-l10n i build_runner; wymaga commitów
bash tools/dev-up.sh --contract --run-id local --seed   # jak contract.yml
bash tools/ci/check-16kb-alignment.sh app/build/app/outputs/bundle/prodRelease/app-prod-release.aab
```

E2E z mockiem (jak `e2e.yml` na PR), na emulatorze:

```sh
cd app
echo '{"FF_MOCK_CORE": true, "GI_DEV_EMAIL": "owner@gihome.test", "GI_DEV_PASSWORD": "mock"}' > ../build/e2e-mock.json
flutter drive --profile -d emulator-5554 --flavor dev   --driver=test_driver/integration_test.dart --target=integration_test/app_flow_test.dart   --dart-define-from-file=config/dev.json --dart-define-from-file=../build/e2e-mock.json
```

Poprawność plików CI (parsowanie YAML, bramki w każdym workflow, akcje zewnętrzne
przypięte do SHA commita z komentarzem wersji, `--down` w `always()`, udokumentowane
sekrety, brak wpisanych danych uwierzytelniających) sprawdza
`tools/test/ci_config_test.dart`.
