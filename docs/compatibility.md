# Deklaracja kompatybilności z GI Core

Aplikacja mobilna mówi do urządzenia GI Home (backend GI Core) przez REST.
Ten dokument mówi, z którą wersją backendu została sprawdzona, co aplikacja
robi, gdy backend jest inny, i jak zmienić przypięcie.

## Wersja objęta testami

Plik [`contract/backend.lock`](../contract/backend.lock) jest jedynym źródłem
prawdy. Stan na dzień tego dokumentu:

| Pole | Wartość |
|---|---|
| Repozytorium | `home-energy-poc` (zob. `repository=` w pliku) |
| Gałąź | `main` |
| `sha` | `8be59cd907df1af964a817331edbcf8e1597d3e2` |
| `shortSha` | `8be59cd` |
| `pinnedAt` | `2026-11-19` |

Test `app/test/tooling/store_docs_test.dart` sprawdza, że ten dokument zawiera
`sha`, `shortSha` i `pinnedAt` z pliku. Zmiana przypięcia bez zmiany tego
dokumentu zatrzymuje testy.

**Deklarowany zakres:** wersja 1.0 aplikacji jest sprawdzona z GI Core na
commicie z tabeli (testy kontraktowe na żywo, nagrane fixture'y w
`packages/gi_core_api/test/fixtures/core/8be59cd/`, snapshot specyfikacji
`contract/openapi/core-8be59cd.json`). Zakresu „od–do” nie deklarujemy:
wspieramy ten commit i nowsze wydania, dopóki nocny test kontraktowy na `main`
backendu (kanarek, nie blokuje) i `tools/spec_diff.dart` nie zgłaszają dryfu.
Starsze wersje backendu nie były sprawdzane.

Pełna lista endpointów, których używa aplikacja, z fixture'ami i testami na
żywo: [backend-contract.md](backend-contract.md) (generowany).

## Jak aplikacja reaguje na inny backend

Stan faktyczny w kodzie, bez obietnic:

- **Brak bramki wersji.** Aplikacja nie porównuje wersji GI Core z żadnym
  zakresem i nie pokazuje komunikatu „zaktualizuj urządzenie” ani „zaktualizuj
  aplikację”. To znana luka, nie zachowanie do obiecania w sklepie.
- **Wykrywanie funkcji (feature probing).** Dla opcjonalnych funkcji
  (harmonogramy, plan PV, historia, lista sesji) aplikacja raz na połączenie i
  zalogowanego użytkownika sprawdza tanim GET-em, czy trasa istnieje.
  Tylko potwierdzone `HTTP 404` ukrywa funkcję; brak rozstrzygnięcia zostawia ją
  widoczną. Kod: `packages/gi_core_api/lib/src/probe/capability_probe.dart`,
  `app/lib/src/features/appliance/application/core_capabilities.dart`,
  ADR [0013](decisions/0013-feature-probing.md).
- **Zmiana wersji w trakcie sesji.** Zmiana wersji w
  `GET /appliance/updates/status` powtarza sondy funkcji.
- **Brak trasy przy łączeniu.** Odpowiedź, która nie wygląda jak GI Core
  (`RouteAbsent`, `404`, nieoczekiwana odpowiedź lub kształt), daje na ekranie
  łączenia komunikat „to nie wygląda na urządzenie GI Home”
  (`connect_screen.dart`), a nie crash.
- **Zmieniony kształt odpowiedzi.** W aplikacji dekodowanie jest tolerancyjne
  (`DecodeMode.tolerant`: nieznane wartości wyliczeń mają wariant `unknown`,
  liczby jako tekst są akceptowane); niezgodny kształt to
  `ApiFailure.unexpectedShape` pokazany jako błąd, nigdy wyjątek, który
  wywraca aplikację. Tryb ścisły (nieznane pole to błąd) działa tylko w testach
  kontraktowych, żeby dryf było widać przed wydaniem. Zob. ADR
  [0002](decisions/0002-hand-written-api-client.md).
- **Wykrywanie dryfu przed wydaniem.** `tools/spec_diff.dart` porównuje
  żywą specyfikację ze snapshotem w `contract/openapi/`; `contract.yml`
  uruchamia go co noc. Backend nigdy nie jest tu modyfikowany.

## Co zapisujemy przy wydaniu

Pipeline wydania kopiuje `contract/backend.lock` do artefaktów wydania. Stan
faktyczny (sprawdzony 2026-11-22):

| Pipeline | Kopiuje | Gdzie |
|---|---|---|
| `.github/workflows/build.yml` | tak | `app/build/app/outputs/bundle/prodRelease/backend.lock`, obok AAB, w artefakcie `app-prod-release-aab` |
| `codemagic.yaml` | tak | `release-info/` |
| fastlane | tak | `build/release-info/` |

Ten sam SHA wpisuje się w tabelę wydań w
[release-runbooku](release-runbook.md#2-tag-v-i-zapis-refu-backendu) i w
notatki wydania. Jeśli któryś z pipeline'ów przestanie kopiować plik, to
jest błąd wydania.

## Jak zmienić przypięcie

1. Wybierz nowy commit backendu (kanarek na `main` pokazuje, czy się
   zgadza). Backend jest tylko do odczytu.
2. Zmień `sha`, `shortSha` i `pinnedAt` w `contract/backend.lock`.
3. Podnieś stack kontraktowy (`tools/dev-up.ps1 -Contract -RunId <id> -Seed`),
   nagraj fixture'y (`tools/seed_core.dart --fixtures`, opis w
   [development.md](development.md)) do katalogu nowego `shortSha`, zrób
   snapshot specyfikacji (`tools/spec_diff.dart --write-snapshot`).
4. Uruchom testy kontraktowe (`dart test -t contract -j 1`) i `spec_diff`;
   rozbieżności rozstrzygnij w katalogu endpointów
   (`packages/gi_core_api/lib/src/catalog/`), potem wygeneruj
   [backend-contract.md](backend-contract.md).
5. Zaktualizuj ten dokument (tabela wyżej). Test dryfu to wymusza.
6. Wpis do tabeli wydań przy najbliższym tagu.

Zmianę przypięcia robi się w osobnym PR razem z nagranymi fixture'ami.
