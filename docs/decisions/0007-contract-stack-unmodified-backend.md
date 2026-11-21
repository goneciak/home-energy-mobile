# 0007. Testy kontraktowe na własnym stosie Docker przeciw niezmienionemu backendowi

- **Status:** Przyjęta (M0), z odnotowanym odstępstwem (tag `contract`
  zamiast `live`). Potwierdzona spike'ami S6 i S8.
- **Data:** 2026-11-19
- **Plan:** §3.9, §17.3, §17.4, §18.2, §19.1, spike'i S6, S8, D15, D20

## Kontekst

Backend `C:\home-energy-poc` jest tylko do odczytu: nie zmieniamy kodu,
compose, `.env.example` ani dokumentacji. Bazowy compose backendu ma stałe
`container_name`, stałą sieć i stałe porty hosta, więc drugi projekt obok
działającego stosu dev koliduje. Stos dev ma też dane dewelopera, których
testy nie mogą zmieniać. Spec OpenAPI jest niepełny (ADR [0002](0002-hand-written-api-client.md)),
więc prawdę o kontrakcie dają tylko żądania do prawdziwego Core.

## Decyzja

- Własny `contract/compose.contract.yml` w repo mobilnym (nie dołącza
  `infrastructure/compose.yml`): `postgres` (tmpfs), `mosquitto` (local-only),
  `gi-migrate` (target `migrator`), `gi-core` (target `production`,
  `network_mode: service:mosquitto`), `fake-esphome`. Bez `container_name`,
  bez stałych portów (Core na `127.0.0.1::3000`), bez bind mountów do
  backendu; backend to wyłącznie kontekst budowania tylko do odczytu.
  Projekt `gi-mobile-contract-<runId>`, sprzątany przez `down -v`.
- Uruchamianie: `tools/dev-up.ps1 -Contract [-Seed]` / `tools/dev-up.sh
  --contract [--seed]` wypisują `GI_CORE_URL` i `FAKE_ESPHOME_URL`; `-Down`
  usuwa projekt.
- Dane wyłącznie przez publiczne API: `tools/seed_core.dart --base-url …
  --init --yes` (inicjalizacja, konta ADMIN/USER, pokoje, urządzenie fake,
  role encji, strategia), z opcjonalnym `--fixtures` zapisującym fixture'y do
  `packages/gi_core_api/test/fixtures/core/<ref>/`. Strażnik odmawia zapisu do
  zainicjalizowanego Core bez `--allow-initialized`.
- Testy na żywo w `packages/gi_core_api/test/contract/`, uruchamiane przez
  `dart test -t contract` z `GI_CORE_URL`. Tryb ścisły dekodowania. Testy
  zmieniające dane biegną tylko na Core z urządzeniem fake (czyli na stosie
  kontraktowym, D20).
- Przypięty ref backendu w `contract/backend.lock` (D15); CI
  (`.github/workflows/contract.yml`) buduje z tymczasowego checkoutu.

### Odstępstwo: tag `contract`, nie `live`

Plan (§17.1, §17.3) nazywa tag `live`. W kodzie tag nazywa się `contract`
(`packages/gi_core_api/dart_test.yaml`), bo pod tą nazwą CI wyklucza go z
przebiegu jednostkowego (`dart test -x contract`) i uruchamia w workflow
`contract.yml`. Znaczenie jest to samo.

## Konsekwencje

- Pozytywne: stos kontraktowy działa obok stosu dev bez kolizji (S8),
  urządzenie fake przechodzi pełne provisioning bez proxy (S6), a spike'i
  S1/S4/S5 dały się uruchomić jako zwykłe testy kontraktowe
  ([wyniki](../spikes/README.md)).
- Negatywne: limit logowania (5/min na IP, wspólny dla seedera i testów)
  wymusza oszczędne logowania i czasem czekanie na `Retry-After`;
  `core_quirks_contract_test.dart` czeka ~70 s na odpytywanie urządzenia
  legacy. Pierwszy build obrazu Core trwa długo; na runnerze Linux GitHub
  stos nie był jeszcze uruchamiany (otwarte w S8).
- Uwaga praktyczna (S1–S7, 2026-11-19): `tools/dev-up.ps1 -Seed` uruchamia
  `dart` z `PATH`; gdy na `PATH` jest starszy globalny SDK, seeder nie
  kompiluje się (primary constructors z Dart 3.14). Obejście: SDK z FVM
  pierwszy na `PATH` albo osobne `fvm dart run tools/seed_core.dart`.
