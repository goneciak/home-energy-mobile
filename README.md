# GI Home Mobile

[![CI](https://github.com/goneciak/home-energy-mobile/actions/workflows/ci.yml/badge.svg)](https://github.com/goneciak/home-energy-mobile/actions/workflows/ci.yml)

Aplikacja mobilna (Android i iOS) do zarządzania domowym systemem ogrzewania
i energii GI Home. Łączy się z lokalnym serwerem GI Core przez jego REST API
(`/api/v1`) w sieci domowej.

## Funkcje

- **Pulpit urządzeń** – stan sterowników, encji i połączenia w czasie
  zbliżonym do rzeczywistego, lista „Uwaga” z problemami wymagającymi reakcji.
- **Bezpieczne sterowanie ogrzewaniem** – przełączniki z potwierdzeniem
  przytrzymaniem, wstrzymanie i wznowienie ogrzewania, strategia sterowania.
  Stan pokazywany jest wyłącznie po potwierdzeniu przez urządzenie.
- **Harmonogramy** – tworzenie, edycja i usuwanie okien grzania.
- **Pogoda, słońce i fotowoltaika** – bieżące warunki, prognozy i plan
  grzania z nadwyżki PV.
- **Historia** – wykresy pomiarów z 1 h do 7 dni oraz widok tabelaryczny
  dla czytników ekranu.
- **Konto** – profil, język, zmiana hasła, zarządzanie sesjami, reset hasła
  kodem odzyskiwania.
- **Tryb demo** – pełna aplikacja na danych przykładowych, bez serwera.
- **Praca offline** – ostatni znany stan dostępny bez połączenia; zapisy
  nigdy nie są kolejkowane.
- Interfejs po polsku i angielsku, motyw jasny i ciemny.

## Stos technologiczny

| Obszar | Technologia |
|---|---|
| Framework | Flutter 3.50 (Dart 3.14), wersja przypięta przez FVM |
| Stan | Riverpod 3 z generatorem kodu |
| Nawigacja | go_router |
| Modele | freezed, json_serializable |
| HTTP | dio, osobny pakiet `gi_core_api` w czystym Dart |
| Wykresy | fl_chart |
| Testy | flutter_test, alchemist (golden), integration_test, testy kontraktowe na Dockerze |
| CI/CD | GitHub Actions, Codemagic, fastlane |

## Szybki start

Wymagania: [FVM](https://fvm.app), Docker z Compose v2, Android SDK lub Xcode.

```sh
fvm install
fvm flutter pub get
cd app
fvm flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=config/dev.json
```

Aplikację można uruchomić bez serwera, wybierając **Tryb demo** na ekranie
startowym. Uruchomienie lokalnego GI Core w Dockerze opisuje
[docs/development.md](docs/development.md).

## Struktura repozytorium

```
app/                    aplikacja Flutter (UI, stan, integracje platformowe)
packages/gi_core_api/   klient API GI Core: modele, sesja, obsługa błędów
tools/                  narzędzia deweloperskie: seeder, mock serwera, kontrola dryfu API
contract/               stos i snapshot specyfikacji do testów kontraktowych
docs/                   dokumentacja, decyzje architektoniczne (ADR)
```

## Testy

```sh
cd app && fvm flutter test                          # testy jednostkowe, widgetów i golden
cd packages/gi_core_api && fvm dart test -x contract
cd tools && fvm dart test
```

Testy kontraktowe na prawdziwym serwerze i testy end-to-end na emulatorze
opisuje [docs/development.md](docs/development.md).

## Dokumentacja

- [Funkcje i zasady działania](docs/features.md)
- [Środowisko deweloperskie, CI/CD](docs/development.md)
- [Przegląd bezpieczeństwa sterowania](docs/safety-review.md)
- [Audyt stanów ekranów](docs/state-audit.md)
- [Kontrakt API backendu](docs/backend-contract.md)
- [Decyzje architektoniczne](docs/decisions/)
- [Procedura wydania](docs/release-runbook.md)
- [Lista kontrolna wydania](docs/release-checklist.md)
- [Plan rozwoju](docs/flutter-app-plan.md)
- [Architektura aplikacji](app/README.md), [klient API](packages/gi_core_api/README.md)
