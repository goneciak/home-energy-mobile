# Budżet obciążenia GI Core

GI Core działa na Raspberry Pi i obsługuje kilka telefonów oraz panel www.
Aplikacja odpytuje go (tylko żądania GET) zgodnie z kadencjami z jednego
pliku, `app/lib/src/core/polling/polling_budget.dart`. Ten dokument opisuje,
ile żądań wysyła każdy ekran, jakiej reguły pilnujemy i jak to sprawdzić.

## Reguła

Jeden telefon z otwartym Home wysyła **najwyżej 12 żądań na minutę**
(`PollingBudget.homeRequestsPerMinute`). Cel pomiarowy na sprzęcie: trzy
telefony i panel www przez 30 minut przy zużyciu CPU Raspberry Pi poniżej 50%
(szablon wyniku: [templates/load-test-pi-report.md](templates/load-test-pi-report.md)).

Pollery działają tylko na pierwszym planie, tylko dla widocznych ekranów, a
po błędach wspólnie wydłużają przerwy (5, 10, 30, 60 s albo `Retry-After`,
[ADR 0015](decisions/0015-network-change-no-write-replay.md)). Warunkowe GET
(ETag, odpowiedź 304, [ADR 0012](decisions/0012-etag-non-authoritative-cache.md))
obniżają koszt odpowiedzi, ale żądanie dalej się liczy.

## Co wysyła każdy ekran

| Ekran / źródło | Przerwa | Żądań na minutę | Źródło w kodzie |
|---|---|---|---|
| Home: lista urządzeń | 30 s | 2 | `PollingBudget.deviceList` |
| Home: karta ogrzewania, 1–2 karty | 15 s na kartę | 4 na kartę | `PollingBudget.heatingCard` |
| Home: karta ogrzewania, n > 2 kart | `max(15 s, n × 6 s)` na kartę | łącznie 10 | `PollingBudget.heatingCardInterval` ([ADR 0016](decisions/0016-home-card-cadence-request-budget.md)) |
| Home: pokoje | raz, przy otwarciu | 0 (jednorazowo) | `rooms_notifier.dart` |
| Szczegóły urządzenia, w użyciu | 5 s | 12 | `PollingBudget.deviceDetail` |
| Szczegóły urządzenia, bezczynność po 2 min | 15 s | 4 | `PollingBudget.deviceDetailIdle`, `deviceDetailIdleAfter` |
| Po poleceniu (przełącznik, wstrzymanie grzania) | 2 s, najwyżej 45 s | do 30 (krótka seria) | `PollingBudget.postCommandPoll` |
| Pogoda i PV, historia, lista „Uwaga” | bez odpytywania | 0 | ładowane przy otwarciu i po pociągnięciu w dół |
| Aplikacja w tle | brak | 0 | `ForegroundPoller` |

Home to lista plus karty:

| Kart ogrzewania | Przerwa karty | Home, żądań na minutę |
|---|---|---|
| 1 | 15 s | 6 |
| 2 | 15 s | 10 |
| 3 | 18 s | 12 |
| 4 | 24 s | 12 |
| 5 | 30 s | 12 |
| 8 | 48 s | 12 |

Szczegóły urządzenia same mieszczą się w budżecie (12 na minutę). Budżet 12
dotyczy Home; szczegóły są ekranem, na którym człowiek aktywnie obsługuje
urządzenie, i mają własną kadencję.

Pogoda i PV oraz historia nie mają odpytywania w kodzie (plan wspominał o
15 i 30 minutach dla pogody i PV oraz 60 s dla historii do 24 h). Dane
ładują się przy otwarciu ekranu i po pociągnięciu w dół, więc te ekrany
obciążają Core mniej niż w planie.

## Jak dotrzymujemy budżetu

- Karty ogrzewania zwalniają, gdy jest ich więcej niż dwie, i startują z
  przesunięciem w obrębie kadencji, żeby żądania nie szły seriami (ADR 0016).
- Liczba kart to liczba urządzeń grzewczych z ostatniej listy, nie liczba
  kart widocznych; Home buduje karty leniwie, więc rzeczywiste obciążenie
  bywa mniejsze.
- Najwyżej 3 żądania kart naraz (`heatingCardMaxConcurrency`) i najwyżej 4
  żądania naraz na urządzenie w kliencie API.
- Niedostępny host jest sondowany jednym żądaniem naraz przez wszystkie
  pollery razem; `Retry-After` obniża tempo, nie podnosi.
- Seria po poleceniu kończy się z poleceniem (potwierdzenie, limit czasu albo
  błąd) i nigdy nie powtarza zapisu.

## Test regresji

`app/test/core/polling/request_budget_test.dart` liczy żądania na atrapie
źródła przy sztucznym czasie, na prawdziwych kadencjach z `PollingBudget`:

- Home z 1, 2, 3, 4, 5 i 8 kartami przez 10 minut: średnia nie przekracza 12,
  szczyt jednej minuty nie przekracza 13, a średnia zgadza się z tabelą
  powyżej;
- Home w tle: 0 żądań;
- niedostępny host i `Retry-After`: tempo niższe niż zdrowe, nigdy wyższe;
- szczegóły: 12 na minutę w użyciu, 4 po 2 minutach bezczynności, 0 w tle;
- seria po poleceniu: najwyżej 30 s / 2 s żądań i koniec razem z poleceniem.

Przyspieszenie którejkolwiek kadencji (na przykład `heatingCard` do 5 s) kładzie
te testy. `polling_budget_test.dart` pilnuje arytmetyki (budżet dla dowolnej
liczby kart).

## Pomiar: `tools/load`

`tools/load/simulate_clients.dart` odtwarza kadencje N telefonów przeciw
stosowi kontraktowemu (tylko GET, jedno logowanie) i mierzy żądania na minutę,
percentyle opóźnień, odsetek odpowiedzi 304 oraz CPU kontenera `gi-core`
(`docker stats`). Opis użycia: [development.md](development.md), sekcja
„Obciążenie GI Core”. To przybliżenie na komputerze deweloperskim, nie pomiar
na Raspberry Pi.

## Czego jeszcze nie wiemy

- CPU Pi przy trzech telefonach i panelu www przez 30 minut.
- Czas zimnego startu (p90 z 20 uruchomień, limit 5 s) na telefonie w sieci Pi:
  szkielet pomiaru jest w `app/integration_test/perf/cold_start_benchmark_test.dart`,
  a wynik zapisuje się według [templates/cold-start-p90.md](templates/cold-start-p90.md).

Oba pomiary wymagają sprzętu.
