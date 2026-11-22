# 0011. Historia: LTTB po stronie klienta i wykres schodkowy

- **Status:** Przyjęta (M3)
- **Data:** 2026-11-22
- **Plan:** §5.2, §12.9, §20 M3 pkt 3

## Kontekst

`GET /devices/:d/entities/:e/history` zwraca próbki rosnąco po `recordedAt`,
bez kursora i bez agregacji (`limit` 1..5000, zakres `gte from, lte to`); przy
obcięciu dostajemy **najstarsze** próbki. Próbki zapisywane są tylko przy
zmianie wartości, więc seria to dziennik zmian, a nie pomiary w stałych
odstępach. 7 dni to dziesiątki tysięcy punktów.

## Decyzja

- Okna 1 h, 6 h, 24 h i 7 d (`HistoryWindow`). Długi zakres dzielimy na
  plastry dobowe czytane równolegle; plaster stronicujemy, ustawiając
  następne `from` na ostatnie `at` i usuwając duplikat z granicy
  (`features/history/data/history_source.dart`).
- Wykres schodkowy: wartość trwa do następnej zmiany i do końca okna.
- Redukcja punktów LTTB (`domain/lttb.dart`) do szerokości wykresu w
  pikselach, w krótkim izolacie (`Isolate.run`,
  `application/history_downsampler.dart`).
- Dostępność: Semantics z podsumowaniem i „Pokaż jako tabelę”.

## Konsekwencje

- Pozytywne: brak zmian w backendzie; płynny wykres 7 d.
- Negatywne: LTTB może zgubić pojedynczy krótki skok (tabela pokazuje dane
  surowe); koszt sieci 7 d rośnie z liczbą zmian. Budżet ≤ 3 s mierzą
  `app/test/features/history/lttb_benchmark_test.dart` (host) i
  `app/integration_test/perf/history_7d_benchmark_test.dart` (urządzenie;
  wynik z fizycznego Androida jeszcze niezebrany).
