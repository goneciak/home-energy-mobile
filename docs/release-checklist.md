# Lista kontrolna wydania

Lista do przejścia przed każdym wydaniem produkcyjnym. Część techniczną
zamyka Dev, część ręczną (czytniki ekranu) tester na fizycznych urządzeniach.
Wyniki zapisujemy w sekcji „Zapis wyników” na dole, a kryteria wydania v1.0
śledzimy w [liście wyjścia M4](templates/m4-exit-checklist.md). Procedura
wydania: [release-runbook.md](release-runbook.md).

## 1. Część techniczna

- [ ] Wersja i numer builda podniesione w `app/pubspec.yaml`, zgodne z tagiem `v*`.
- [ ] `contract/backend.lock` skopiowany do artefaktów wydania, ref wpisany do
      tabeli w runbooku ([kompatybilność](compatibility.md)).
- [ ] Wyrównanie stron 16 KB: `tools/ci/check-16kb-alignment.sh` na AAB z CI przechodzi.
- [ ] Podpisanie: klucz wgrywania Play i certyfikat dystrybucyjny Apple działają,
      build pochodzi z CI, nie z maszyny dewelopera.
- [ ] Artefakty prywatności zgodne z kodem: `PrivacyInfo.xcprivacy`,
      `ITSAppUsesNonExemptEncryption`, [Data safety](store/data-safety.md),
      [etykiety Apple](store/apple-privacy-labels.md), [site/privacy.md](../site/privacy.md).
- [ ] Golden: CI na Linuksie zielone, bez zmian nagranych lokalnie na Windows.
- [ ] `flutter analyze` bez uwag, `flutter test` zielone, bramki pokrycia przechodzą.
- [ ] Testy kontraktowe na stosie z przypiętym refem backendu zielone.
- [ ] Notatki dla recenzentów aktualne ([review-notes](store/review-notes.md)).
- [ ] Wpis w [dzienniku zgłoszeń](templates/store-submission-log.md).

## 2. Czytniki ekranu: ścieżki ręczne

**Status: RĘCZNE. Wymagane przed wydaniem produkcyjnym. Zablokowane na
urządzeniach fizycznych: w środowisku deweloperskim na Windows nie da się ich
wykonać, a testy automatyczne (zrzuty przy skali tekstu 200%, kontrola
rozmiarów dotykowych i kontrastu, testy drzewa semantyki) ich nie zastępują.**
Zakres opisuje [ADR 0017](decisions/0017-accessibility-verification-strategy.md).

Każdą ścieżkę wykonujemy po polsku, osobno z TalkBack (Android) i z VoiceOver
(iOS), na wersji kandydującej do wydania, połączonej z prawdziwym urządzeniem
GI Home (ścieżki 3 i 4 wymagają roli właściciela albo administratora).
Oczekiwane komunikaty to teksty z `app_pl.arb`; czytnik może dodać własne
określenie roli (przycisk, nagłówek), co nie jest błędem. Wartość zapisana w
cudzysłowie z kluczem w nawiasie musi zgadzać się z plikiem (pilnuje tego test
`release_docs_test`).

### Ścieżka 1: logowanie

1. Otwórz aplikację po wylogowaniu. Przesuń palcem w prawo do pola e-mail.
   Oczekiwane: „E-mail” (`loginEmailLabel`).
2. Przejdź do pola hasła. Oczekiwane: „Hasło” (`loginPasswordLabel`).
3. Przejdź do przycisku odsłaniania hasła. Oczekiwane: „Pokaż hasło” (`loginShowPassword`).
4. Wpisz błędne hasło i aktywuj „Zaloguj” (`loginSubmit`). Oczekiwane
   ogłoszenie błędu: „Nieprawidłowy e-mail lub hasło.” (`loginErrorInvalidCredentials`).
5. Wpisz poprawne dane i zaloguj. Oczekiwane: fokus ląduje na ekranie „Dom”
   (`homeTitle`).

- [ ] TalkBack: przeszło
- [ ] VoiceOver: przeszło

### Ścieżka 2: połączenie z urządzeniem

1. Na świeżej instalacji znajdź nagłówek „Połącz z GI Home” (`connectTitle`).
2. Przejdź do pola adresu. Oczekiwane: „Adres GI Home” (`connectAddressLabel`).
3. Uruchom wyszukiwanie. Oczekiwany komunikat o postępie: „Szukam GI Home…” (`connectSearching`).
4. Przy znalezionym urządzeniu przejdź do pytania „Czy to Twój GI Home?”
   (`connectConfirmTitle`) i aktywuj „Tak, połącz” (`connectConfirmYes`).

- [ ] TalkBack: przeszło
- [ ] VoiceOver: przeszło

### Ścieżka 3: wstrzymanie ogrzewania

1. Otwórz szczegóły urządzenia grzewczego i przejdź do sekcji „Sterowanie ogrzewaniem” (`heatingControlSection`).
2. Przejdź do przycisku wstrzymania. Oczekiwane: „Przytrzymaj, aby wstrzymać ogrzewanie” (`suspendHoldAction`).
3. Dotknij raz. Oczekiwane: nic się nie zmienia, podpowiedź „Przytrzymaj przycisk – zwykłe dotknięcie niczego nie zmienia.” (`suspendHoldHint`).
4. Przytrzymaj do potwierdzenia i potwierdź w oknie „Wstrzymać ogrzewanie?” (`suspendConfirmTitle`) przyciskiem „Wstrzymaj ogrzewanie” (`suspendConfirmAction`).
5. Oczekiwane: ogłoszenie stanu oczekiwania, nie sukcesu: „Wysłano · czekamy, aż GI Home potwierdzi wstrzymanie” (`suspendAwaiting`).
6. Po potwierdzeniu: baner „Ogrzewanie jest wstrzymane.” (`heatingSuspendedBanner`).
   Komunikat nie może twierdzić, że przekaźnik fizycznie się przełączył.
7. Wznów: „Wznów ogrzewanie” (`heatingResumeAction`), arkusz „Wznowić ogrzewanie?” (`resumeSheetTitle`).

- [ ] TalkBack: przeszło
- [ ] VoiceOver: przeszło

### Ścieżka 4: zmiana celu

1. Na szczegółach urządzenia aktywuj „Zmień ustawienia sterowania” (`strategyEditAction`).
2. Edytor ma tytuł „Ustawienia sterowania” (`strategyEditorTitle`); przejdź do pola „Temperatura docelowa (°C)” (`strategyTargetLabel`).
3. Wpisz tekst zamiast liczby. Oczekiwane: komunikat błędu odczytany przy polu: „Wpisz liczbę” (`strategyErrorNotANumber`).
4. Przejdź do pola „Histereza (°C)” (`strategyHysteresisLabel`) i do wyboru „Tryb sterowania” (`strategyModeLabel`).
5. Zapisz przyciskiem „Zapisz” (`strategySave`), potwierdź „Zapisz zmiany” (`strategyConfirmSave`).
6. Oczekiwane: „Zapisano w GI Home” (`strategySavedTitle`).

- [ ] TalkBack: przeszło
- [ ] VoiceOver: przeszło

### Ścieżka 5: odczyt historii (dzień, tydzień, tabela)

1. Otwórz historię temperatury. Nagłówek: „Historia” (`historyTitle`).
2. Przejdź do wyboru zakresu: „Zakres” (`historyWindowLabel`); wybierz „24 h” (`historyWindowDay`), potem „7 dni” (`historyWindowWeek`).
3. Wykres odczytuje podsumowanie według `historyChartSemantics` (nazwa,
   zakres, minimum, maksimum, ostatnia wartość, liczba zmian). Sprawdź, że
   wszystkie liczby zostały wypowiedziane.
4. Aktywuj „Pokaż jako tabelę” (`historyShowTable`). Oczekiwane nagłówki kolumn: „Czas” (`historyTableTime`) i „Wartość” (`historyTableValue`).
5. Wiersze czytane jako czas i wartość (`historyTableRowSemantics`). Przyciski stron: „Starsze” (`historyTableOlder`) i „Nowsze” (`historyTableNewer`).

- [ ] TalkBack: przeszło
- [ ] VoiceOver: przeszło

### Ścieżka 6: lista „Uwaga”

1. Przejdź zakładką „Uwaga” (`navAttention`) na ekran „Uwaga” (`attentionTitle`).
2. Dla urządzenia ze starymi danymi oczekiwane: „Brak świeżych danych z urządzenia” (`attentionStale`).
3. Aktywacja pozycji prowadzi do szczegółów urządzenia, fokus na jego nagłówku.

- [ ] TalkBack: przeszło
- [ ] VoiceOver: przeszło

## 3. Zapis wyników

Jeden wiersz na przebieg. Przed zamknięciem wydania wszystkie ścieżki mają
wynik „przeszło” na obu czytnikach albo zgłoszenie z uzasadnieniem.

| Ścieżka | Czytnik | Wersja czytnika | Urządzenie | System | Wersja aplikacji | Tester | Data | Wynik | Uwagi |
|---|---|---|---|---|---|---|---|---|---|
| 1 logowanie | TalkBack | | | | | | | | |
| 1 logowanie | VoiceOver | | | | | | | | |
| 2 połączenie | TalkBack | | | | | | | | |
| 2 połączenie | VoiceOver | | | | | | | | |
| 3 wstrzymanie | TalkBack | | | | | | | | |
| 3 wstrzymanie | VoiceOver | | | | | | | | |
| 4 zmiana celu | TalkBack | | | | | | | | |
| 4 zmiana celu | VoiceOver | | | | | | | | |
| 5 historia | TalkBack | | | | | | | | |
| 5 historia | VoiceOver | | | | | | | | |
| 6 uwaga | TalkBack | | | | | | | | |
| 6 uwaga | VoiceOver | | | | | | | | |

Wady znalezione podczas przejścia zapisujemy jako zgłoszenia z etykietą
„dostępność”, z numerem ścieżki i krokiem.
