# 0009. Semantyka potwierdzeń poleceń: LEGACY synchronicznie, GI Edge heartbeatem, nigdy stan fizyczny

- **Status:** Przyjęta (M2).
- **Data:** 2026-11-21
- **Plan:** §3.6, §12.1, §12.2, §12.3, §21 (L15, L16), §24 pkt 3

## Kontekst

`PUT /devices/:id/entities/:entityId/state` ma dwie ścieżki w GI Core
(`esphome-switch-command.service.ts`), a odpowiedź
`{entityId, state, availability, confirmedAt}` wygląda na obu tak samo:

- **LEGACY_ESPHOME:** Core wywołuje urządzenie synchronicznie i sprawdza echo
  (klucz i stan). 200 oznacza, że urządzenie przyjęło polecenie; błędy to
  502 `ESPHOME_COMMAND_REJECTED` / `…_UNCONFIRMED`, 503
  `ESPHOME_DEVICE_UNREACHABLE`, 504 `ESPHOME_COMMAND_TIMEOUT`. `dryRun` jest
  na tej ścieżce ignorowany.
- **GI_EDGE_V1:** Core kolejkuje TURN_ON/TURN_OFF przez MQTT (TTL 30 s, bez
  ID polecenia w API) i od razu odpowiada 200. Bez `dryRun` encja jest
  zapisywana **optymistycznie** (żądana wartość, `lastSeenAt` = czas
  żądania). Z `dryRun` encja nie jest zapisywana, a odpowiedź niesie
  **stary** stan.
- Każdy heartbeat GI Edge zapisuje `Device.lastSeenAt` zegarem serwera i
  nadpisuje encje przekaźników z `diagnostics.relayN.{output, commanded}`.
- Tryb rozpoznajemy po `communicationMode` z `GET /devices/:id`; odpowiedź
  PUT go nie zawiera.
- Firmware nie ma sprzętowego potwierdzenia styku (`docs/safety.md`:
  `confirmed_physical_state` zawsze UNKNOWN).

## Decyzja

1. `response.state` nigdy nie jest traktowane jako nowy stan. Po każdym 2xx
   aplikacja ponownie czyta szczegóły.
2. **LEGACY_ESPHOME:** 200 to „Urządzenie potwierdziło polecenie”
   (`SwitchLegacyConfirmed`), z dopiskiem, że fizyczny stan nie jest
   weryfikowany.
3. **GI_EDGE_V1:** 200 to „Zlecono · czeka na potwierdzenie”
   (`SwitchAwaitingHeartbeat`). `entity.value` i `entity.lastSeenAt` są
   ignorowane. Za potwierdzenie uznajemy dopiero **poziom urządzenia**
   `lastSeenAt` **ściśle późniejszy** niż `confirmedAt` z odpowiedzi PUT
   (oba z zegara serwera). Wtedy pokazujemy, co zgłosił sterownik:
   `relayN.commanded` i `relayN.output` (`SwitchHeartbeatObserved`), albo
   „nieznane”, gdy diagnostyka ich nie ma. Przy `dryRun` stan to
   `SwitchDryRunRecorded`. Heartbeat liczy się dopiero, gdy
   `relayN.commanded` równa się żądanemu stanowi: heartbeat i dostarczenie
   polecenia to osobne kanały, więc heartbeat sprzed zastosowania polecenia
   niesie stary `commanded`. Okno to 45 s, jak w planie §12.2 (interwał
   heartbeatu 30 s plus polle; TTL polecenia 30 s to osobne pojęcie). Po
   nim pokazujemy ostatni heartbeat po `confirmedAt` taki, jaki jest, a bez
   żadnego – `SwitchTimedOut`. Wcześniejsze okno 30 s (= interwał
   heartbeatu) gubiło heartbeaty z końca okna i zostało wycofane.
4. Wstrzymanie (`PATCH {heatingSuspended}`) potwierdzamy polem
   `heatingSuspended` w szczegółach; dla GI Edge dodatkowo raportem
   przekaźników z heartbeatu po czasie PATCH (`relayReportAfter`), gdy
   żaden przekaźnik nie ma już `commanded: true`. Na
   LEGACY Core nie wysyła TURN_OFF, więc nie twierdzimy, że przekaźniki
   zostały wyłączone.
5. Żaden tekst nie mówi, że przekaźnik fizycznie się przełączył.

## Konsekwencje

- Pozytywne: zapis optymistyczny Core nie może dać fałszywego
  „Potwierdzone”; porównania czasu nie zależą od zegara telefonu.
- Negatywne: heartbeat po poleceniu nie dowodzi, że zmianę spowodowało
  *nasze* polecenie (brak ID). Raportujemy fakt, nie przyczynę.
- Flaga `switchControlByIntegration` (ADR [0008](0008-feature-flags.md),
  §19.6) istnieje, ale M2 jej nie używa: logika potwierdzeń zależy od
  `communicationMode`, a dostępność przełącznika od `SafetyPolicy`. ADR 0008
  pozostaje bez zmian.
- Ścieżki GI Edge nie są osiągalne na urządzeniu fake stosu kontraktowego
  (tylko LEGACY); pokrywają je testy jednostkowe z fixture'ami i
  `tools/mock_core`, a na sprzęcie lista ręczna (runbook §1).

## Kod i testy

- `app/lib/src/features/devices/application/switch_command_controller.dart`,
  `app/lib/src/features/devices/domain/switch_command_state.dart`,
  `app/lib/src/features/devices/application/heating_suspension_controller.dart`.
- `app/test/features/devices/switch_command_controller_test.dart`,
  `app/test/features/devices/heating_command_controllers_test.dart`,
  `packages/gi_core_api/test/m2_writes_test.dart`.
- Mapa reguł bezpieczeństwa: [docs/safety-review.md](../safety-review.md).
