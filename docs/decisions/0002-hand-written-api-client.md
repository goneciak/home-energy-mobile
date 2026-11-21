# 0002. Ręcznie pisany klient API z katalogiem endpointów, bez generatora OpenAPI

- **Status:** Przyjęta (M0).
- **Data:** 2026-11-19
- **Plan:** §5.2, §6.1–6.6, §17.4, §17.5, §21 (L19)

## Kontekst

Specyfikacja OpenAPI GI Core nie nadaje się do generowania kodu (§6.1): 72 ze
122 operacji bez schematu 2xx, 76 nullowalnych stringów jako `object`, puste
schematy, niezdefiniowany schemat `gi_refresh_token`, kolizja nazwy `Object`,
brak `integer`, błędnie zadeklarowana odpowiedź `control-strategy`. Spike S5
potwierdził ten ostatni punkt na żywo: Swagger deklaruje `ControlStrategyDto`,
a serwer odsyła `{controlStrategy, baseControlStrategy, configurationVersion}`
([S5](../spikes/s5-fixtures-quirks.md)). Spec ani backend nie będą poprawiane.

## Decyzja

- Czysto-dartowy pakiet `packages/gi_core_api` (bez Fluttera) z `dio`.
- **Katalog endpointów** (`lib/src/catalog/endpoints.dart`, `GiEndpoints`):
  każdy wpis ma `operationId` zgodny ze Swaggerem, metodę, ścieżkę, role,
  klasę timeoutu i politykę ponowień. Katalog steruje bramkowaniem ról,
  timeoutami, filtrem `tools/spec_diff.dart` i regułą pokrycia.
- Modele pisane ręcznie we `freezed` + `json_serializable`
  (`lib/src/models/`), z kolejnością zaufania: fixture'y nagrane z Core w
  Dockerze → kod serwisów Core → typowane schematy spec → typy GI UI.
- Tolerancyjne dekodowanie w aplikacji (`DecodeMode.tolerant`: enumy z
  `unknown`, konwertery liczb ze stringów, defensywne `diagnostics`) i tryb
  ścisły w testach kontraktowych (`DecodeMode.strict`: nieznane pole to błąd).
  Błąd kształtu to `ApiFailure.unexpectedShape`, nigdy wyjątek, który wywraca
  aplikację.
- Reguła CI (`test/catalog_coverage_test.dart`): każdy wpis katalogu ma
  fixture, test jednostkowy dekodujący fixture i test kontraktowy na żywo
  (lista `liveCoverage` w każdym `test/contract/*_contract_test.dart`).
  `tools/gen_backend_contract.dart` generuje z tego `docs/backend-contract.md`.
- Spec służy wyłącznie wykrywaniu dryfu (`tools/spec_diff.dart`,
  `contract/openapi/core-<ref>.json`).

## Konsekwencje

- Pozytywne: modele odpowiadają temu, co serwer naprawdę wysyła (np. kody 201
  tam, gdzie Swagger mówi 200, zob. S6); nowy endpoint nie wejdzie bez
  fixture'u i testu na żywo.
- Negatywne: ręczna praca przy każdym nowym endpoincie i przy dryfie Core.
  Łagodzą to nocny canary kontraktowy, `spec_diff` i licznik
  `unexpectedShape` w diagnostyce (§16).
