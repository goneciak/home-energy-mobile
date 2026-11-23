# 0016. Budżet żądań na Home: wolniejsze karty przy większej liczbie kotłów

- **Status:** Przyjęta (M4)
- **Data:** 2026-11-22
- **Plan:** M4 (budżet obciążenia), rozdział o obciążeniu GI Core, ADR 0012, ADR 0015

## Kontekst

GI Core działa na Raspberry Pi i obsługuje kilka telefonów oraz panel www.
Budżet na jeden telefon z otwartym Home to najwyżej 12 żądań na minutę.
Lista urządzeń kosztuje 2 żądania na minutę (co 30 s), a każda karta
ogrzewania 4 na minutę (co 15 s), czyli Home miał 2 + 4n żądań: 10 przy
dwóch kartach, 14 przy trzech i 18 przy czterech. Nic nie ograniczało liczby
kart, więc budżet dotrzymywał się tylko do dwóch kotłów. Domy z więcej niż
dwoma urządzeniami grzewczymi są rzadkie, ale to właśnie one najbardziej
obciążają Pi.

## Decyzja

Rozważone warianty: (a) wolniejsza kadencja każdej karty, gdy kart jest
więcej niż dwie; (b) limit żywych kart, reszta z danych listy z przyciskiem
„Odśwież”. Wybieramy (a).

- Kadencja karty to `max(15 s, n × 60 / (12 − 2) s)`, zaokrąglona w górę do
  pełnych sekund, gdzie n to liczba urządzeń grzewczych z ostatniej listy
  (`PollingBudget.heatingCardInterval`). Dla 1–2 kart bez zmian (15 s), dla
  3 kart 18 s, 4 kart 24 s, 5 kart 30 s, 8 kart 48 s. Home zawsze mieści się w
  12 żądaniach na minutę, także przy wielu kartach.
- Liczymy karty z listy, nie te aktualnie widoczne: kadencja nie skacze
  podczas przewijania, a budżet jest dotrzymany w najgorszym przypadku.
- Wolniejsza kadencja przesuwa też próg „Dane z HH:MM” karty (dwukrotność jej
  kadencji), żeby karta nie wyglądała na nieaktualną, gdy po prostu czeka na
  swoją kolej.
- Karty tej samej kadencji nie startują razem: `ForegroundPoller` dostał
  `phase`, przesunięcie w obrębie kadencji (n-ta karta o n/liczba kart
  kadencji, tylko pierwszy regularny przebieg po starcie lub powrocie na
  pierwszy plan). Dzięki temu żądania rozkładają się równo, a nie idą seriami
  (przy 8 kartach seria dawała 18 żądań w jednej minucie).
- Wszystkie kadencje mieszkają w jednym pliku bez zależności,
  `core/polling/polling_budget.dart`. Czytają go aplikacja (`FreshnessPolicy`,
  kontrolery poleceń), testy budżetu i narzędzie `tools/load`, więc liczby nie
  są kopiowane.
- Bezpieczeństwo bez zmian: potwierdzenie polecenia dalej sprawdza dane o
  kadencji bazowej (15 s, `FreshnessPolicy.heatingCard`), nie o wydłużonej.
  Wznowienie grzania z karty może więc przy wielu kotłach zgłosić zbyt stare
  dane, zamiast działać na starszych niż dotąd; pociąganie w dół odświeża
  kartę.

## Konsekwencje

- Pozytywne: budżet jest dotrzymany bez względu na liczbę kart i pilnuje go
  test regresji (`test/core/polling/request_budget_test.dart`: 1–8 kart, 10
  minut symulowanego czasu, szczyt minuty nie więcej niż 13, ciche tło, 12 i 4
  żądań na minutę na szczegółach, krótka seria po poleceniu, niedostępny host
  i `Retry-After`).
- Negatywne: przy 5 kartach i więcej odczyty kotłów starzeją się do 30 s i
  więcej. Dla ogrzewania to akceptowalne (stan zmienia się w minutach), a
  szczegóły urządzenia dalej odświeżają się co 5 s.
- Nie wiemy jeszcze, czy 12 żądań na minutę na telefon mieści się w limicie
  CPU Pi przy trzech telefonach i panelu www. To wymaga pomiaru na Pi (szablon:
  `docs/templates/load-test-pi-report.md`), którego nie da się zrobić bez
  sprzętu. Narzędzie `tools/load` daje tylko przybliżenie na komputerze.
