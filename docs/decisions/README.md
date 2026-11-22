# Decyzje architektoniczne aplikacji mobilnej (ADR)

Krótkie zapisy decyzji w formacie MADR-lite: kontekst, decyzja,
konsekwencje, status i odniesienia do planu (`docs/flutter-app-plan.md`).
Dotyczą wyłącznie repozytorium mobilnego; backend `C:\home-energy-poc` nie
jest zmieniany (ADR-y backendu, np. „ADR 006”, to osobna numeracja).

| Nr | Decyzja | Status | Plan |
|---|---|---|---|
| [0001](0001-cookie-refresh.md) | Refresh token jako ręcznie obsługiwane ciasteczko, bez cookie jar | Przyjęta, potwierdzona S1 | §7.2–7.4, L1, L2 |
| [0002](0002-hand-written-api-client.md) | Ręcznie pisany klient API z katalogiem endpointów, bez generatora OpenAPI | Przyjęta | §6, §17.5, L19 |
| [0003](0003-riverpod-state-management.md) | Stan w Riverpod z generatorem, routing w go_router | Przyjęta | §0, §5 |
| [0004](0004-lan-transport-policy.md) | Transport tylko w LAN i TransportPolicy | Przyjęta, odstępstwo: `10/8` we wszystkich flavorach | §9, L13, L14, D6, D17 |
| [0005](0005-appliance-fingerprint-single-profile.md) | Odcisk `initializedAt` i jeden profil | Przyjęta, doprecyzowanie: zmiana `deviceName` = zmiana nazwy; D1 czeka na właściciela | §7.1, §9.2, §9.3, D1 |
| [0006](0006-secure-storage-access-token.md) | Sekrety w secure storage; zapisywany access token | Przyjęta; D3 czeka na potwierdzenie właściciela | §7.1, D3 |
| [0007](0007-contract-stack-unmodified-backend.md) | Testy kontraktowe na własnym stosie Docker | Przyjęta, odstępstwo: tag `contract` zamiast `live` | §17.3, §18.2, D15, D20 |
| [0008](0008-feature-flags.md) | Typowane flagi funkcji per flavor, bez zdalnej konfiguracji | Przyjęta | §19.6, D8 |
| [0009](0009-switch-confirmation-semantics.md) | Potwierdzenia poleceń: LEGACY synchronicznie, GI Edge heartbeatem po `confirmedAt`, nigdy stan fizyczny | Przyjęta (okno 45 s, zgodnie z §12.2) | §12.2, §24 pkt 3, L15 |
| [0010](0010-schedule-clock-utc.md) | Zegar harmonogramów w UTC procesu gi-core, `ApiWeekday` = `dartWeekday % 7` | Przyjęta, potwierdzona S7 | §12.5, §13.4, D8 |
| [0011](0011-history-lttb-step-chart.md) | Historia: LTTB w izolacie po stronie klienta, wykres schodkowy, plastry dobowe | Przyjęta | §20 M3 pkt 3 |
| [0012](0012-etag-non-authoritative-cache.md) | ETag jako nieautorytatywny cache za flagą `conditionalGet` | Przyjęta, domyślnie wyłączona | §6.5, S4 |
| [0013](0013-feature-probing.md) | Sondowanie funkcji: tylko `HTTP_404` ukrywa funkcję | Przyjęta | §16 |
| [0014](0014-recovery-code-secure-display.md) | Bezpieczne wyświetlanie i kopiowanie kodu odzyskiwania | Przyjęta, odstępstwo: formularz resetu bez `SecureContent` | §7.7 |

## Odstępstwa od planu zapisane w ADR-ach

1. **TransportPolicy zostawia `10.0.0.0/8` we wszystkich flavorach**
   ([0004](0004-lan-transport-policy.md)): `10.0.2.2` emulatora leży w RFC 1918,
   a domy z podsiecią `10.x` nie mogą być zablokowane w beta i prod.
2. **Zmiana `deviceName` przy tym samym `initializedAt` to zmiana nazwy,
   nie inne urządzenie** ([0005](0005-appliance-fingerprint-single-profile.md)).
3. **Tag testów na żywo to `contract`, nie `live`**
   ([0007](0007-contract-stack-unmodified-backend.md)).
4. **Okno oczekiwania na heartbeat GI Edge to 45 s (jak w planie), nie 30 s;
   heartbeat liczy się, gdy `relayN.commanded` zgadza się z żądaniem**
   ([0009](0009-switch-confirmation-semantics.md)).

## Decyzje produktowe i sklepowe

Propozycje dla D1–D8 (oraz D12, D13) z planu czekają na decyzję
właściciela: [store-and-product-decisions.md](store-and-product-decisions.md).

## Nowy ADR

Kolejny numer (`0010-…`), plik `NNNN-krotki-tytul.md` z sekcjami Status,
Kontekst, Decyzja, Konsekwencje i odniesieniami do planu; dopisz wiersz do
tabeli powyżej.
