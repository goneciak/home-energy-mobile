# 0012. ETag jako nieautorytatywna pamięć podręczna

- **Status:** Przyjęta (M3), domyślnie wyłączona flagą `conditionalGet`
- **Data:** 2026-11-22
- **Plan:** §6.5 pkt 4, §8.3, spike S4

## Kontekst

Express zwraca słaby ETag `W/"…"` dla JSON GET, a `If-None-Match` daje 304
bez body (spike [S4](../spikes/s4-conditional-get.md), sprawdzone dla
`/devices` i `/devices/:id`). ETag nie zależy od `Authorization`. Dla urządzeń
LEGACY zmienia się co ~30 s, więc zysk jest mały.

## Decyzja

- Tylko `GET /devices` i `GET /devices/:id` (`EtagCache` w `GiCoreClient`),
  za flagą `conditionalGet` (we wszystkich flavorach domyślnie `false`).
- Klucz: zakres profilu i zalogowany użytkownik; cache czyszczony przy każdym
  wyjściu z sesji (logout, logout-all, odwołana albo wygasła sesja).
- 304 znaczy wyłącznie „użyj zapamiętanego body”; świeżość (`fetchedAt`) i
  reguły bezpieczeństwa liczymy jak dla 200. Żadna logika poprawności nie
  zależy od ETag; brak wpisu albo błąd cache to zwykłe żądanie.

## Konsekwencje

- Pozytywne: mniej transferu przy pollingu; wyłączenie flagi przywraca
  zachowanie M2.
- Negatywne: ETag nowych endpointów M3 nie jest sprawdzony, więc ich nie
  obejmujemy (kontraktowy test 304 dotyczy tylko urządzeń).
