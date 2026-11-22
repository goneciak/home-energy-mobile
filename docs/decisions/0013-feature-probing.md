# 0013. Sondowanie funkcji: tylko `HTTP_404` ukrywa funkcję

- **Status:** Przyjęta (M3)
- **Data:** 2026-11-22
- **Plan:** §16 pkt 1–2

## Kontekst

Aplikacja ma działać z każdym wdrożonym Core. Nieznana trasa daje 404
`HTTP_404`, a brakujący zasób kod domenowy (`DEVICE_NOT_FOUND`,
`DEVICE_ENTITY_NOT_FOUND`, `HEATING_SCHEDULE_NOT_FOUND`, `RESOURCE_NOT_FOUND`),
więc te przypadki da się odróżnić.

## Decyzja

- `CapabilityProbe` (`packages/gi_core_api/lib/src/probe/capability_probe.dart`)
  wysyła jeden tani GET na funkcję, tylko dla ról dozwolonych w katalogu:
  `schedules`, `pvPlan`, `history` (`?limit=1`), `sessions`. Identyfikatory
  urządzenia i encji to nieistniejące wartości, więc sonda nie czyta danych.
- Klasyfikacja: 2xx, 404 z kodem domenowym albo 400 (`VALIDATION_FAILED`,
  `HTTP_400` z pipe'a) = **jest**; `HTTP_404` = **brak**; wszystko inne
  (offline, 5xx, timeout) = **nieznane**, funkcja zostaje widoczna.
- Pogody i `pv/forecast` **nie** sondujemy po statusie: ich 503/400 znaczą
  „brak danych”, nie „brak trasy”.
- Wynik per klient (instancja Core i połączenie) i użytkownik; ponowne
  sondowanie po zmianie `runningVersion` z `/appliance/updates/status`
  (OWNER/ADMIN, best effort).

## Konsekwencje

- Pozytywne: nieudana sonda nigdy nie chowa działającej funkcji.
- Negatywne: kilka dodatkowych żądań po zalogowaniu; proxy zwracające własne
  404 z kodem `HTTP_404` schowałoby funkcję (akceptowane).
