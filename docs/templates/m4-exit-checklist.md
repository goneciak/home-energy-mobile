# Lista kontrolna wyjścia M4 (v1.0)

Kryteria pochodzą z sekcji „M4” w [planie](../flutter-app-plan.md). Status:
„automatyczne” (zmierzone testami w repozytorium), „przygotowane” (dokument lub
szablon gotowy, pomiar czeka), „zablokowane” (wymaga urządzeń, ludzi albo
sklepów), „zrobione” (pomiar wykonany, dowód podlinkowany). Kolumnę dowodu
uzupełnia osoba odpowiedzialna po pomiarze.

| Kryterium | Jak mierzone | Dowód | Status | Właściciel |
|---|---|---|---|---|
| Zimny start do kondycji domu ≤ 5 s (p90) | 20 uruchomień, Pi w LAN, 10 urządzeń, średniej klasy Android, trace z `integration_test`; [szablon](cold-start-p90.md) | | zablokowane (Pi i telefon) | Dev |
| Budżet obciążenia: ≤ 12 żądań/min na Domu, ≤ 30 na szczegółach | test budżetu na fałszywym czasie; [budżet](../load-budget.md) | testy w `app/test` | automatyczne | Dev |
| CPU gi-core < 50% przez 30 min przy 3 telefonach i panelu www | pomiar na Pi; [szablon raportu](load-test-pi-report.md) | | zablokowane (Pi) | Dev |
| Ścieżki VoiceOver (pl): logowanie, wstrzymanie, zmiana celu, historia | ręcznie, [lista wydania](../release-checklist.md) | | zablokowane (urządzenia, tester) | QA |
| Ścieżki TalkBack (pl): to samo | ręcznie, [lista wydania](../release-checklist.md) | | zablokowane (urządzenia, tester) | QA |
| Skala tekstu 200% bez przepełnień, 48 dp, kontrast | `screenGoldens` i testy wytycznych dostępności | testy w `app/test` | automatyczne (zrzuty Linux do nagrania z CI) | Dev |
| Audyt stanów ekranów | [state-audit.md](../state-audit.md) i jego test | test w `app/test/tooling` | automatyczne | Dev |
| Sesje bez awarii ≥ 99,5% przez ≥ 14 dni | konsole sklepów; [raport tygodniowy](weekly-beta-report.md) | | zablokowane (beta) | Koordynator bety |
| Wymuszone ponowne logowanie < 1% sesji | raporty diagnostyczne bety | | zablokowane (beta) | Koordynator bety |
| Wyrównanie stron 16 KB | `tools/ci/check-16kb-alignment.sh` na AAB | wynik z CI | przygotowane | Dev |
| Artefakty prywatności (`PrivacyInfo.xcprivacy`, Data safety, etykiety Apple, strona prywatności) | przegląd i testy deklaracji; raport prywatności Xcode na archiwum | [docs/store](../store/data-safety.md) | przygotowane (raport Xcode wymaga macOS; dane operatora czekają na właściciela) | Właściciel |
| Deklaracja kompatybilności z backendem | [compatibility.md](../compatibility.md), `contract/backend.lock` | | przygotowane | Dev |
| Zgłoszenie do Google Play zaakceptowane | konsola Play; [dziennik](store-submission-log.md) | | zablokowane (sklep) | Właściciel |
| Zgłoszenie do App Store zaakceptowane | App Store Connect; [dziennik](store-submission-log.md) | | zablokowane (sklep) | Właściciel |
