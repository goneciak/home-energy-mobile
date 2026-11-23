# 0018. Program beta i metryki

- **Status:** Przyjęta (M4); realizacja czeka na gospodarstwa i urządzenia
- **Data:** 2026-11-22
- **Plan:** M4, Exit M4, §19

## Kontekst

Exit M4 wymaga stabilności zmierzonej w prawdziwych domach: sesje bez awarii
co najmniej 99,5% przez 14 dni i wymuszone ponowne logowanie poniżej 1%.
Aplikacja nie ma zdalnej telemetrii (ADR 0008), a sklepowe konsole nie
pokazują przyczyn wylogowań.

## Decyzja

- Beta obejmuje 3–5 gospodarstw na prawdziwych Raspberry Pi, w tym iOS i
  Androida oraz przynajmniej jedno gospodarstwo z więcej niż dwoma kotłami.
- Awarie bierzemy z Play Android vitals i Xcode Organizer, a wymuszone
  logowania oraz błędy połączeń z cotygodniowych raportów diagnostycznych
  wysyłanych przez uczestników po jawnej zgodzie.
- Raport zbiera koordynator według szablonu
  [tygodniowego raportu](../templates/weekly-beta-report.md); definicje metryk i
  zasady zatrzymania są w [runbooku](../release-runbook.md).
- Testerzy dostają build `prod` (odstępstwo opisane w
  [decyzjach sklepowych](store-and-product-decisions.md)), bo ścieżka beta nie
  istnieje w pipeline.

## Konsekwencje

- Metryki wymagają ludzi i czasu, więc zostają „zablokowane” do rozpoczęcia
  bety; repozytorium dostarcza tylko procedurę i szablony.
- Brak zdalnej telemetrii oznacza zależność od rzetelności raportów
  uczestników; mała próba nie daje istotności statystycznej, a próg 1% należy
  czytać razem z przyczynami z raportów.
- Awaria sterowania ogrzewaniem zatrzymuje betę niezależnie od metryk.
