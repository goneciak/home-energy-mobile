# 0010. Zegar harmonogramów: UTC procesu gi-core i mapowanie `ApiWeekday`

- **Status:** Przyjęta (M3), potwierdzona spike'iem S7
- **Data:** 2026-11-22
- **Plan:** §12.5, §13.3, §13.4, D8

## Kontekst

Core rozstrzyga, który harmonogram działa, w `windowMatches`
(`heating-schedule-reconciliation.service.ts:158-191`) przez
`now.getHours()/getMinutes()/getDay()`, czyli na **zegarze procesu gi-core**.
Kontener nie ma `TZ` (`node:22-alpine`, brak w compose i `contract.env`),
więc to UTC (spike [S7](../spikes/s7-schedule-clock.md)). `timezone` z
`/settings/system` nie jest tu używane. Dni tygodnia w API to `0 = niedziela
… 6 = sobota` (JS `getDay`), a Dart ma `1 = poniedziałek … 7 = niedziela`.
Core nie zwraca „aktywnego harmonogramu” i nie sprawdza nakładania się okien,
`start == end` ani unikalności nazw.

## Decyzja

- `ApiWeekday` (`features/schedules/domain/api_weekday.dart`):
  `coreDay = dartWeekday % 7`; UI zaczyna tydzień od poniedziałku.
- `ScheduleClock` jest wierną repliką `windowMatches` w UTC, z dokładnością
  do minuty: start włącznie, koniec wyłącznie; `s == e` to okno całodobowe
  (sprawdzany tylko dzień); `s > e` to okno przez północ zakotwiczone w dniu
  startu (gałąź „wczoraj” przed godziną końca). Koniec `00:00` przy starcie
  `22:00` działa więc 22:00–23:59 tylko w dniu startu.
- Aktywny harmonogram to pierwszy włączony pasujący według `createdAt`
  rosnąco; `mode` zawsze z bazowej strategii, `heatingSuspended` wygrywa.
  Etykieta „wywnioskowane”, bo to obliczenie klienta.
- Czasy pokazujemy w UTC z drugim czasem w strefie domu (albo telefonu dla
  USER, który nie czyta `/settings/system`). Edycja w czasie domu tylko za
  flagą `scheduleClockConversion` (D8), z dzisiejszym offsetem i banerem
  zmiany czasu. Nigdy nie przepisujemy harmonogramów po cichu.
- Ostrzeżenie o nakładaniu się okien liczy wyłącznie klient
  (`schedule_window.dart`).

## Konsekwencje

- Pozytywne: zgodność z serwerem testowana na granicach okna (testy
  jednostkowe i kontraktowy test rekoncyliacji na stosie Docker w UTC).
- Negatywne: jeśli wdrożenie ustawi kiedyś `TZ` dla gi-core, etykiety UTC
  będą błędne. Ryzyko zapisane, bez obejścia po stronie aplikacji.
