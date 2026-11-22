# Pomiar obciążenia na Raspberry Pi: raport

Szablon wyniku testu obciążenia GI Core na prawdziwym urządzeniu. Wypełnia
osoba, która wykonała pomiar; wynik dołącza się do dokumentacji wydania.
Kadencje i budżet: [load-budget.md](../load-budget.md). Narzędzie do symulacji
telefonów: [development.md](../development.md), sekcja „Obciążenie GI Core”.

## Kryterium zaliczenia

- Trzy telefony z otwartym Home i jedna otwarta sesja panelu www.
- Czas: co najmniej 30 minut ciągłej pracy.
- Zużycie CPU Raspberry Pi poniżej 50% (średnia z 1 minuty, w żadnej minucie
  powyżej 50%).
- Żadnych odpowiedzi 429 ani 5xx wywołanych obciążeniem.
- Każdy telefon w budżecie 12 żądań na minutę.

## Konfiguracja

| Pole | Wartość |
|---|---|
| Data i osoba wykonująca | |
| Model Raspberry Pi, RAM, karta SD lub dysk | |
| System operacyjny i wersja jądra | |
| Wersja GI Core (SHA z `contract/backend.lock` albo tag) | |
| Wersja aplikacji (wersja i numer kompilacji) | |
| Dodatkowe usługi na Pi (MQTT, baza, inne) | |
| Sieć (Wi-Fi lub Ethernet, router) | |
| Liczba urządzeń grzewczych w domu (kart na Home) | |

## Telefony

| Telefon | Model i system | Wersja aplikacji | Ekran w trakcie testu | Tryb (rzeczywiste telefony czy `tools/load`) |
|---|---|---|---|---|
| 1 | | | Home | |
| 2 | | | Home | |
| 3 | | | Home | |
| Panel www | przeglądarka | | | |

Jeżeli trzeci telefon albo kolejne zastępuje `tools/load/simulate_clients.dart`,
podaj komendę i dołącz `report.md`.

## Przebieg

| Pole | Wartość |
|---|---|
| Początek i koniec pomiaru | |
| Ile minut ciągłej pracy | |
| Czy ktoś w tym czasie używał szczegółów, poleceń, historii | |
| Jak mierzono CPU (`top`, `vmstat`, `docker stats`, Prometheus) | |

## CPU Raspberry Pi

Próbki co minutę (dopisz wiersze):

| Minuta | CPU całkowite, % | CPU `gi-core`, % | Pamięć, MiB | Uwagi |
|---|---|---|---|---|
| 1 | | | | |
| 5 | | | | |
| 10 | | | | |
| 15 | | | | |
| 20 | | | | |
| 25 | | | | |
| 30 | | | | |

| Podsumowanie | Wartość |
|---|---|
| Średnie CPU całkowite | |
| Szczyt CPU całkowitego (minuta) | |
| Średnie i szczyt CPU `gi-core` | |
| Temperatura Pi na końcu, throttling | |

## Żądania

| Telefon | Żądań na minutę (średnia) | Szczyt minuty | Kody inne niż 200 i 304 | p90 opóźnienia |
|---|---|---|---|---|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |

## Wynik

- [ ] Kryterium zaliczone (CPU poniżej 50%, 30 minut, budżet żądań).
- [ ] Kryterium niezaliczone. Powód i dalsze kroki:

Wnioski i uwagi (na przykład czy trzeba zwolnić kadencje albo zmniejszyć
liczbę kart):
